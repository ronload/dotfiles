// ZMK Studio client for macOS over Bluetooth LE.
//
//   zmk-studio-cli dump|check|apply <keymap.json>
//
// The keymap file names the keyboard, its physical layout, and the bindings to
// change from the stock keymap. check reports which of them the keyboard has;
// apply writes the missing ones, saves them to flash, and reads them back. A
// binding that matches neither its "from" nor its "to" value stops the run
// before anything is written.
//
// zmk/studio.sh launches this app through `open`, which does not report the
// exit status, so the last output line is "RESULT: OK" or "RESULT: FAIL ...".
//
// Protocol: app/src/studio in zmkfirmware/zmk (msg_framing.c and
// gatt_rpc_transport.c) and the zmk-studio-messages protobufs.

import CoreBluetooth
import Foundation

setvbuf(stdout, nil, _IOLBF, 0)

func die(_ message: String) -> Never {
    print("RESULT: FAIL \(message)")
    exit(1)
}

func hex(_ bytes: [UInt8]) -> String {
    bytes.map { String(format: "%02x", $0) }.joined(separator: " ")
}

// MARK: - Protobuf wire format

struct ProtoWriter {
    private(set) var bytes: [UInt8] = []

    mutating func varint(_ value: UInt64) {
        var remaining = value
        while remaining >= 0x80 {
            bytes.append(UInt8(truncatingIfNeeded: remaining) | 0x80)
            remaining >>= 7
        }
        bytes.append(UInt8(remaining))
    }

    mutating func key(_ field: Int, _ wireType: Int) {
        varint(UInt64(field << 3 | wireType))
    }

    mutating func uint(_ field: Int, _ value: UInt64, always: Bool = false) {
        guard always || value != 0 else { return }
        key(field, 0)
        varint(value)
    }

    mutating func int32(_ field: Int, _ value: Int32) {
        guard value != 0 else { return }
        key(field, 0)
        varint(UInt64(bitPattern: Int64(value)))
    }

    mutating func sint32(_ field: Int, _ value: Int32) {
        guard value != 0 else { return }
        key(field, 0)
        varint(UInt64(UInt32(bitPattern: (value << 1) ^ (value >> 31))))
    }

    mutating func flag(_ field: Int) {
        uint(field, 1, always: true)
    }

    mutating func message(_ field: Int, _ build: (inout ProtoWriter) -> Void) {
        var inner = ProtoWriter()
        build(&inner)
        key(field, 2)
        varint(UInt64(inner.bytes.count))
        bytes += inner.bytes
    }
}

enum ProtoError: Error {
    case malformed(String)
}

func readVarint(_ data: [UInt8], _ index: inout Int) throws -> UInt64 {
    var result: UInt64 = 0
    var shift: UInt64 = 0
    while true {
        guard index < data.count, shift < 64 else { throw ProtoError.malformed("varint") }
        let byte = data[index]
        index += 1
        result |= UInt64(byte & 0x7F) << shift
        if byte & 0x80 == 0 { return result }
        shift += 7
    }
}

enum WireValue {
    case varint(UInt64)
    case bytes([UInt8])
    case fixed
}

struct ProtoField {
    let number: Int
    let value: WireValue
}

struct ProtoMessage {
    let fields: [ProtoField]

    init(_ data: [UInt8]) throws {
        var parsed: [ProtoField] = []
        var index = 0
        while index < data.count {
            let key = try readVarint(data, &index)
            let number = Int(key >> 3)
            switch key & 7 {
            case 0:
                let value = try readVarint(data, &index)
                parsed.append(ProtoField(number: number, value: .varint(value)))
            case 1, 5:
                let width = key & 7 == 1 ? 8 : 4
                guard index + width <= data.count else { throw ProtoError.malformed("fixed") }
                index += width
                parsed.append(ProtoField(number: number, value: .fixed))
            case 2:
                let length = try readVarint(data, &index)
                guard length <= UInt64(data.count - index) else { throw ProtoError.malformed("length") }
                let end = index + Int(length)
                parsed.append(ProtoField(number: number, value: .bytes(Array(data[index..<end]))))
                index = end
            default:
                throw ProtoError.malformed("wire type \(key & 7)")
            }
        }
        fields = parsed
    }

    func varint(_ number: Int) -> UInt64? {
        for field in fields.reversed() where field.number == number {
            if case .varint(let value) = field.value { return value }
        }
        return nil
    }

    func bytes(_ number: Int) -> [UInt8]? {
        for field in fields.reversed() where field.number == number {
            if case .bytes(let value) = field.value { return value }
        }
        return nil
    }

    func has(_ number: Int) -> Bool {
        fields.contains { $0.number == number }
    }

    func uint32(_ number: Int) -> UInt32 {
        UInt32(truncatingIfNeeded: varint(number) ?? 0)
    }

    func sint32(_ number: Int) -> Int32 {
        let raw = UInt32(truncatingIfNeeded: varint(number) ?? 0)
        return Int32(bitPattern: (raw >> 1) ^ (0 &- (raw & 1)))
    }

    func string(_ number: Int) -> String {
        String(decoding: bytes(number) ?? [], as: UTF8.self)
    }

    func message(_ number: Int) -> ProtoMessage? {
        guard let raw = bytes(number) else { return nil }
        do {
            return try ProtoMessage(raw)
        } catch {
            die("malformed nested message in field \(number): \(error)")
        }
    }

    func messages(_ number: Int) -> [ProtoMessage] {
        fields.compactMap { field -> ProtoMessage? in
            guard field.number == number, case .bytes(let raw) = field.value else { return nil }
            do {
                return try ProtoMessage(raw)
            } catch {
                die("malformed repeated message in field \(number): \(error)")
            }
        }
    }

    func repeatedVarints(_ number: Int) -> [UInt64] {
        var values: [UInt64] = []
        for field in fields where field.number == number {
            switch field.value {
            case .varint(let value):
                values.append(value)
            case .bytes(let raw):
                var index = 0
                while index < raw.count {
                    guard let value = try? readVarint(raw, &index) else {
                        die("malformed packed field \(number)")
                    }
                    values.append(value)
                }
            case .fixed:
                break
            }
        }
        return values
    }
}

// MARK: - Framing

let frameStart: UInt8 = 0xAB
let frameEscape: UInt8 = 0xAC
let frameEnd: UInt8 = 0xAD

func frame(_ payload: [UInt8]) -> [UInt8] {
    var framed: [UInt8] = [frameStart]
    for byte in payload {
        if byte == frameStart || byte == frameEscape || byte == frameEnd {
            framed.append(frameEscape)
        }
        framed.append(byte)
    }
    framed.append(frameEnd)
    return framed
}

struct Deframer {
    private enum State {
        case idle
        case data
        case escaped
        case error
    }

    private var state = State.idle
    private var buffer: [UInt8] = []

    mutating func feed(_ byte: UInt8) -> [UInt8]? {
        switch state {
        case .idle, .error:
            if byte == frameStart {
                state = .data
                buffer = []
            } else if byte == frameEnd {
                state = .idle
            }
        case .data:
            switch byte {
            case frameStart:
                state = .error
            case frameEscape:
                state = .escaped
            case frameEnd:
                state = .idle
                return buffer
            default:
                buffer.append(byte)
            }
        case .escaped:
            buffer.append(byte)
            state = .data
        }
        return nil
    }
}

// MARK: - Keymap model

struct Binding: Equatable {
    var behavior: Int32
    var param1: UInt32
    var param2: UInt32
}

struct Layer {
    let id: UInt32
    let name: String
    let bindings: [Binding]
}

struct KeyGeometry {
    let position: Int
    let x: Int32
    let y: Int32
}

struct PhysicalLayout {
    let name: String
    let keys: [KeyGeometry]
}

// ZMK key names for the HID keyboard page (0x07).
let keyboardUsageNames: [UInt32: String] = {
    var names: [UInt32: String] = [:]
    for (offset, letter) in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".enumerated() {
        names[0x04 + UInt32(offset)] = String(letter)
    }
    for (offset, digit) in "1234567890".enumerated() {
        names[0x1E + UInt32(offset)] = "N\(digit)"
    }
    for index in 0..<12 {
        names[0x3A + UInt32(index)] = "F\(index + 1)"
    }
    let named: [UInt32: String] = [
        0x28: "RET", 0x29: "ESC", 0x2A: "BSPC", 0x2B: "TAB", 0x2C: "SPACE",
        0x2D: "MINUS", 0x2E: "EQUAL", 0x2F: "LBKT", 0x30: "RBKT", 0x31: "BSLH",
        0x32: "NUHS", 0x33: "SEMI", 0x34: "SQT", 0x35: "GRAVE", 0x36: "COMMA",
        0x37: "DOT", 0x38: "FSLH", 0x39: "CAPS", 0x46: "PSCRN", 0x47: "SLCK",
        0x48: "PAUSE_BREAK", 0x49: "INS", 0x4A: "HOME", 0x4B: "PG_UP", 0x4C: "DEL",
        0x4D: "END", 0x4E: "PG_DN", 0x4F: "RIGHT", 0x50: "LEFT", 0x51: "DOWN",
        0x52: "UP", 0x64: "NUBS", 0x65: "K_APP",
        0xE0: "LCTRL", 0xE1: "LSHFT", 0xE2: "LALT", 0xE3: "LGUI",
        0xE4: "RCTRL", 0xE5: "RSHFT", 0xE6: "RALT", 0xE7: "RGUI",
    ]
    names.merge(named) { _, new in new }
    return names
}()

let keyboardUsageIDs = Dictionary(uniqueKeysWithValues: keyboardUsageNames.map { ($0.value, $0.key) })

func usageName(_ value: UInt32) -> String {
    let page = (value >> 16) & 0xFF
    let id = value & 0xFFFF
    let modifiers = value >> 24
    var name: String
    if page == 0x07, let known = keyboardUsageNames[id] {
        name = known
    } else {
        name = String(format: "page%02X:%04X", page, id)
    }
    if modifiers != 0 {
        name += String(format: "+mods%02X", modifiers)
    }
    return name
}

func label(_ binding: Binding, _ names: [Int32: String]) -> String {
    let name = names[binding.behavior] ?? "behavior \(binding.behavior)"
    if name == "Key Press" {
        return "&kp " + usageName(binding.param1)
    }
    if binding.param1 == 0 && binding.param2 == 0 {
        return name
    }
    return "\(name)(\(binding.param1), \(binding.param2))"
}

// MARK: - Keymap file

struct KeymapFile: Decodable {
    struct Change: Decodable {
        let layer: UInt32
        let position: Int
        let from: String
        let to: String
        let note: String?
    }

    let device: String
    let layout: String
    let bindings: [Change]
}

struct PlannedChange {
    let layer: UInt32
    let position: Int
    let from: UInt32
    let to: UInt32
    let place: String
}

func keyPressUsage(_ text: String) -> UInt32 {
    let words = text.split(separator: " ")
    guard words.count == 2, words[0] == "&kp", let id = keyboardUsageIDs[String(words[1])] else {
        die("unsupported binding \"\(text)\"; expected &kp with a keyboard key, such as \"&kp GRAVE\"")
    }
    return 0x0007_0000 | id
}

func loadKeymapFile(_ path: String) -> (KeymapFile, [PlannedChange]) {
    let file: KeymapFile
    do {
        file = try JSONDecoder().decode(KeymapFile.self, from: Data(contentsOf: URL(fileURLWithPath: path)))
    } catch {
        die("cannot read \(path): \(error)")
    }
    let changes = file.bindings.map { change in
        PlannedChange(
            layer: change.layer,
            position: change.position,
            from: keyPressUsage(change.from),
            to: keyPressUsage(change.to),
            place: "layer \(change.layer) position \(change.position)" + (change.note.map { " (\($0))" } ?? "")
        )
    }
    return (file, changes)
}

// MARK: - Bluetooth transport

let studioServiceUUID = CBUUID(string: "00000000-0196-6107-C967-C5CFB1C2482A")
let studioRPCUUID = CBUUID(string: "00000001-0196-6107-C967-C5CFB1C2482A")

enum Subsystem: Int {
    case core = 3
    case behaviors = 4
    case keymap = 5
}

func describe(_ state: CBManagerState) -> String {
    switch state {
    case .unknown: return "unknown"
    case .resetting: return "resetting"
    case .unsupported: return "unsupported"
    case .unauthorized: return "unauthorized"
    case .poweredOff: return "powered off"
    case .poweredOn: return "powered on"
    @unknown default: return "state \(state.rawValue)"
    }
}

func describe(_ authorization: CBManagerAuthorization) -> String {
    switch authorization {
    case .notDetermined: return "not determined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .allowedAlways: return "allowed"
    @unknown default: return "authorization \(authorization.rawValue)"
    }
}

func metaError(_ code: UInt32) -> String {
    switch code {
    case 0: return "GENERIC"
    case 1: return "UNLOCK_REQUIRED"
    case 2: return "RPC_NOT_FOUND"
    case 3: return "MSG_DECODE_FAILED"
    case 4: return "MSG_ENCODE_FAILED"
    default: return "code \(code)"
    }
}

final class StudioClient: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let namePrefix: String
    private let queue = DispatchQueue(label: "zmk-studio-cli.ble")
    private var central: CBCentralManager!
    private var managerState = CBManagerState.unknown
    private var scanned: [CBPeripheral] = []
    private var keyboard: CBPeripheral?
    private var rpcCharacteristic: CBCharacteristic?
    private var connected = false
    private var closing = false
    private var failure: String?
    private var servicesDiscovered = false
    private var characteristicsDiscovered = false
    private var indicationsEnabled = false
    private var writeAcknowledged = false
    private var deframer = Deframer()
    private var responses: [UInt32: ProtoMessage] = [:]
    private var lastRequestID: UInt32 = 0

    init(namePrefix: String) {
        self.namePrefix = namePrefix
        super.init()
        central = CBCentralManager(delegate: self, queue: queue)
    }

    private func waitUntil(_ what: String, timeout: TimeInterval, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while true {
            if queue.sync(execute: condition) { return }
            if let failure = queue.sync(execute: { self.failure }) {
                die("\(what): \(failure)")
            }
            if Date() >= deadline {
                die("timed out waiting for \(what)")
            }
            usleep(20_000)
        }
    }

    func connect() {
        let deadline = Date().addingTimeInterval(180)
        var reportedWaiting = false
        while queue.sync(execute: { managerState }) != .poweredOn {
            let authorization = CBManager.authorization
            if authorization == .denied || authorization == .restricted {
                die("Bluetooth access is \(describe(authorization)); allow ZMK Studio CLI in System Settings > Privacy & Security > Bluetooth")
            }
            let state = queue.sync { managerState }
            if state == .poweredOff || state == .unsupported {
                die("Bluetooth is \(describe(state))")
            }
            if Date() >= deadline {
                die("timed out waiting for Bluetooth access")
            }
            if authorization == .notDetermined && !reportedWaiting {
                print("waiting for Bluetooth access; allow it if macOS asks")
                reportedWaiting = true
            }
            usleep(100_000)
        }

        var candidate: CBPeripheral?
        let serviceSets: [[CBUUID]] = [
            [studioServiceUUID],
            [CBUUID(string: "180F"), CBUUID(string: "180A")],
            [CBUUID(string: "1812")],
        ]
        for services in serviceSets where candidate == nil {
            let found = queue.sync { central.retrieveConnectedPeripherals(withServices: services) }
            candidate = found.first { ($0.name ?? "").hasPrefix(namePrefix) }
        }
        if candidate == nil {
            print("\(namePrefix) is not connected to this Mac; scanning for 15s")
            queue.sync { central.scanForPeripherals(withServices: [studioServiceUUID], options: nil) }
            let scanDeadline = Date().addingTimeInterval(15)
            while candidate == nil, Date() < scanDeadline {
                candidate = queue.sync { scanned.first { ($0.name ?? "").hasPrefix(namePrefix) } }
                usleep(100_000)
            }
            queue.sync { central.stopScan() }
        }
        guard let target = candidate else {
            die("no Bluetooth keyboard named \(namePrefix) found")
        }

        queue.sync {
            keyboard = target
            target.delegate = self
            central.connect(target, options: nil)
        }
        waitUntil("connection", timeout: 20) { connected }

        queue.sync { target.discoverServices([studioServiceUUID]) }
        waitUntil("service discovery", timeout: 20) { servicesDiscovered }
        guard let service = queue.sync(execute: { target.services?.first(where: { $0.uuid == studioServiceUUID }) }) else {
            die("ZMK Studio is not enabled in the keyboard firmware")
        }

        queue.sync { target.discoverCharacteristics([studioRPCUUID], for: service) }
        waitUntil("characteristic discovery", timeout: 20) { characteristicsDiscovered }
        guard let characteristic = queue.sync(execute: { service.characteristics?.first(where: { $0.uuid == studioRPCUUID }) }) else {
            die("ZMK Studio RPC characteristic not found")
        }

        queue.sync {
            rpcCharacteristic = characteristic
            target.setNotifyValue(true, for: characteristic)
        }
        waitUntil("enabling indications", timeout: 20) { indicationsEnabled }
        print("connected to \(target.name ?? namePrefix)")
    }

    func call(_ subsystem: Subsystem, timeout: TimeInterval = 20, _ build: (inout ProtoWriter) -> Void) -> ProtoMessage {
        let requestID: UInt32 = queue.sync {
            lastRequestID += 1
            return lastRequestID
        }
        var request = ProtoWriter()
        request.uint(1, UInt64(requestID), always: true)
        request.message(subsystem.rawValue, build)
        let framed = frame(request.bytes)
        let (target, characteristic) = queue.sync { (keyboard!, rpcCharacteristic!) }
        // The firmware handles each write on its own (no long writes), so split
        // frames at the negotiated write size.
        let chunkSize = max(20, queue.sync { target.maximumWriteValueLength(for: .withoutResponse) })
        var offset = 0
        while offset < framed.count {
            let end = min(offset + chunkSize, framed.count)
            let chunk = Data(framed[offset..<end])
            queue.sync {
                writeAcknowledged = false
                target.writeValue(chunk, for: characteristic, type: .withResponse)
            }
            waitUntil("write acknowledgement for request \(requestID)", timeout: 10) { writeAcknowledged }
            offset = end
        }
        waitUntil("response to request \(requestID)", timeout: timeout) { responses[requestID] != nil }
        let response = queue.sync { responses.removeValue(forKey: requestID)! }
        if let meta = response.message(2), meta.has(2) {
            die("request \(requestID) rejected: \(metaError(meta.uint32(2)))")
        }
        return response
    }

    func close() {
        let (target, characteristic): (CBPeripheral?, CBCharacteristic?) = queue.sync {
            closing = true
            return (keyboard, rpcCharacteristic)
        }
        guard let target else { return }
        if let characteristic {
            queue.sync { target.setNotifyValue(false, for: characteristic) }
            usleep(300_000)
        }
        queue.sync { central.cancelPeripheralConnection(target) }
        usleep(200_000)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        managerState = central.state
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !scanned.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        scanned.append(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        failure = "connect failed: \(error?.localizedDescription ?? "unknown error")"
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        if !closing {
            failure = "disconnected: \(error?.localizedDescription ?? "no error")"
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            failure = "service discovery failed: \(error.localizedDescription)"
        } else {
            servicesDiscovered = true
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            failure = "characteristic discovery failed: \(error.localizedDescription)"
        } else {
            characteristicsDiscovered = true
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            if !closing {
                failure = "enabling indications failed: \(error.localizedDescription)"
            }
        } else {
            indicationsEnabled = characteristic.isNotifying
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            failure = "write failed: \(error.localizedDescription)"
        } else {
            writeAcknowledged = true
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            failure = "indication failed: \(error.localizedDescription)"
            return
        }
        guard let value = characteristic.value else { return }
        for byte in value {
            guard let payload = deframer.feed(byte) else { continue }
            receive(payload)
        }
    }

    private func receive(_ payload: [UInt8]) {
        guard let response = try? ProtoMessage(payload) else {
            print("warning: undecodable frame: \(hex(payload))")
            return
        }
        // Field 2 holds notifications (lock state, unsaved changes); commands
        // query that state directly when they need it.
        if let requestResponse = response.message(1) {
            responses[requestResponse.uint32(1)] = requestResponse
        }
    }
}

// MARK: - Commands

func fetchBehaviorNames(_ client: StudioClient) -> [Int32: String] {
    let list = client.call(.behaviors, { $0.flag(1) }).message(4)?.message(1)
    var names: [Int32: String] = [:]
    for id in list?.repeatedVarints(1) ?? [] {
        let details = client.call(.behaviors, { request in
            request.message(2) { $0.uint(1, id) }
        }).message(4)?.message(2)
        names[Int32(truncatingIfNeeded: id)] = details?.string(2) ?? "?"
    }
    return names
}

func fetchKeymap(_ client: StudioClient) -> [Layer] {
    guard let keymap = client.call(.keymap, timeout: 40, { $0.flag(1) }).message(5)?.message(1) else {
        die("keyboard did not return a keymap")
    }
    return keymap.messages(1).map { layer in
        Layer(
            id: layer.uint32(1),
            name: layer.string(2),
            bindings: layer.messages(3).map {
                Binding(behavior: $0.sint32(1), param1: $0.uint32(2), param2: $0.uint32(3))
            }
        )
    }
}

func fetchPhysicalLayouts(_ client: StudioClient) -> (layouts: [PhysicalLayout], active: Int) {
    guard let response = client.call(.keymap, timeout: 40, { $0.flag(6) }).message(5)?.message(6) else {
        die("keyboard did not return its physical layouts")
    }
    let layouts = response.messages(2).map { layout in
        PhysicalLayout(
            name: layout.string(1),
            keys: layout.messages(2).enumerated().map { item in
                KeyGeometry(position: item.offset, x: item.element.sint32(3), y: item.element.sint32(4))
            }
        )
    }
    let active = Int(response.uint32(1))
    guard layouts.indices.contains(active) else {
        die("active physical layout \(active) is out of range")
    }
    return (layouts, active)
}

func hasUnsavedChanges(_ client: StudioClient) -> Bool {
    client.call(.keymap, { $0.flag(3) }).message(5)?.varint(3) == 1
}

func binding(in layers: [Layer], layer: UInt32, position: Int) -> Binding? {
    guard let bindings = layers.first(where: { $0.id == layer })?.bindings,
          bindings.indices.contains(position)
    else {
        return nil
    }
    return bindings[position]
}

// Returns the SetLayerBindingResponse code; 0 means success.
func setBinding(_ client: StudioClient, layer: UInt32, position: Int, to binding: Binding) -> UInt32? {
    let response = client.call(.keymap, { request in
        request.message(2) { setRequest in
            setRequest.uint(1, UInt64(layer))
            setRequest.int32(2, Int32(position))
            setRequest.message(3) { value in
                value.sint32(1, binding.behavior)
                value.uint(2, UInt64(binding.param1))
                value.uint(3, UInt64(binding.param2))
            }
        }
    })
    return response.message(5)?.uint32(2)
}

func runDump(_ client: StudioClient, _ names: [Int32: String]) {
    print("behaviors: " + names.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
    let (layouts, active) = fetchPhysicalLayouts(client)
    for (index, layout) in layouts.enumerated() {
        print("physical layout \(index): \(layout.name), \(layout.keys.count) keys\(index == active ? " (active)" : "")")
    }
    let rows = Dictionary(grouping: layouts[active].keys, by: { $0.y })
        .sorted { $0.key < $1.key }
        .map { row in row.value.sorted { $0.x < $1.x } }
    for layer in fetchKeymap(client) {
        print("layer \(layer.id)\(layer.name.isEmpty ? "" : " \"\(layer.name)\""):")
        for row in rows {
            let cells = row.map { key -> String in
                let text = layer.bindings.indices.contains(key.position) ? label(layer.bindings[key.position], names) : "?"
                return "\(key.position) \(text)"
            }
            print("  " + cells.joined(separator: " | "))
        }
    }
    print("unsaved changes: \(hasUnsavedChanges(client))")
}

func runSync(_ client: StudioClient, _ file: KeymapFile, _ changes: [PlannedChange], _ names: [Int32: String], apply: Bool) {
    guard let keyPress = names.first(where: { $0.value == "Key Press" })?.key else {
        die("the firmware has no Key Press behavior")
    }
    func kp(_ usage: UInt32) -> Binding {
        Binding(behavior: keyPress, param1: usage, param2: 0)
    }

    let (layouts, active) = fetchPhysicalLayouts(client)
    guard layouts[active].name == file.layout else {
        die("the active physical layout is \(layouts[active].name), not \(file.layout); nothing changed")
    }

    let layers = fetchKeymap(client)
    var pending: [PlannedChange] = []
    var conflicts = 0
    for change in changes {
        guard let current = binding(in: layers, layer: change.layer, position: change.position) else {
            die("layer \(change.layer) has no position \(change.position); nothing changed")
        }
        if current == kp(change.to) {
            print("ok        \(change.place): \(label(current, names))")
        } else if current == kp(change.from) {
            print("pending   \(change.place): \(label(current, names)) -> \(label(kp(change.to), names))")
            pending.append(change)
        } else {
            print("conflict  \(change.place): \(label(current, names)), expected \(label(kp(change.from), names)) or \(label(kp(change.to), names))")
            conflicts += 1
        }
    }
    guard conflicts == 0 else {
        die("\(conflicts) binding(s) match neither their from nor their to value; nothing changed")
    }

    let unsaved = hasUnsavedChanges(client)
    guard apply else {
        guard pending.isEmpty else { die("\(pending.count) binding(s) not applied") }
        guard !unsaved else { die("the keyboard has unsaved changes") }
        print("all \(changes.count) bindings applied")
        return
    }

    for change in pending {
        guard setBinding(client, layer: change.layer, position: change.position, to: kp(change.to)) == 0 else {
            _ = client.call(.keymap, { $0.flag(5) })
            die("setting \(change.place) failed; discarded unsaved changes")
        }
    }
    // Also save when only earlier changes are pending, so the bindings that
    // already read back correctly survive a power cycle.
    if !pending.isEmpty || unsaved {
        let saved = client.call(.keymap, timeout: 40, { $0.flag(4) }).message(5)?.message(4)
        guard let saved, saved.varint(1) == 1 else {
            die("saving to flash failed: \(saved.map { "error \($0.uint32(2))" } ?? "no response")")
        }
        print("saved to keyboard flash")
    }
    let after = fetchKeymap(client)
    for change in changes where binding(in: after, layer: change.layer, position: change.position) != kp(change.to) {
        die("\(change.place) did not read back as \(label(kp(change.to), names))")
    }
    guard !hasUnsavedChanges(client) else {
        die("the keyboard still reports unsaved changes")
    }
    print(pending.isEmpty ? "nothing to apply" : "applied \(pending.count) binding(s)")
}

// MARK: - Main

// Older macOS versions pass a -psn_ argument to apps launched through `open`.
let arguments = Array(CommandLine.arguments.dropFirst().filter { !$0.hasPrefix("-psn_") })
guard arguments.count == 2, ["dump", "check", "apply"].contains(arguments[0]) else {
    die("usage: zmk-studio-cli dump|check|apply <keymap.json>")
}
let command = arguments[0]
let (keymapFile, plannedChanges) = loadKeymapFile(arguments[1])

let client = StudioClient(namePrefix: keymapFile.device)
client.connect()
guard client.call(.core, { $0.flag(2) }).message(3)?.uint32(2) == 1 else {
    die("ZMK Studio is locked on the keyboard; unlock it and retry")
}
let behaviorNames = fetchBehaviorNames(client)

if command == "dump" {
    runDump(client, behaviorNames)
} else {
    runSync(client, keymapFile, plannedChanges, behaviorNames, apply: command == "apply")
}

client.close()
print("RESULT: OK")
exit(0)
