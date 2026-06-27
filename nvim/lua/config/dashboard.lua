---@class winsize
---@field row integer
---@field col integer
---@field xpixel integer
---@field ypixel integer

local CONFIG = {
    IMAGE_MAX_WIDTH = 40,
    IMAGE_MAX_HEIGHT = 20,
    MENU_GAP = 3,
}

local MENU_LINES = {
    " Find                                󱁐 + ff",
    "󰘧 Grep                                󱁐 + fg",
    "󱋢 Recent                              󱁐 + fr",
}

local function avatar_path()
    local config_dir = vim.fn.resolve(vim.fn.stdpath("config"))
    return vim.fn.fnamemodify(config_dir, ":h") .. "/assets/avatar-ascii.png"
end

--@param ffi ffilib
---@return winsize
local function new_winsize(ffi)
    ---@diagnostic disable-next-line: return-type-mismatch
    return ffi.new("winsize")
end

local function get_term_cell_size()
    local ok, ffi = pcall(require, "ffi")
    if not ok then
        return nil
    end
    pcall(
        ffi.cdef,
        [[
    typedef struct {
      unsigned short row;
      unsigned short col;
      unsigned short xpixel;
      unsigned short ypixel;
    } winsize;
    int ioctl(int, int, ...);
  ]]
    )
    local TIOCGWINSZ
    if vim.fn.has("mac") == 1 or vim.fn.has("bsd") == 1 then
        TIOCGWINSZ = 0x40087468
    elseif vim.fn.has("linux") == 1 then
        TIOCGWINSZ = 0x5413
    else
        return nil
    end
    local sz = new_winsize(ffi)
    if ffi.C.ioctl(1, TIOCGWINSZ, sz) ~= 0 then
        return nil
    end
    if sz.col == 0 or sz.row == 0 then
        return nil
    end
    local xpixel, ypixel = sz.xpixel, sz.ypixel
    -- TIOCGWINSZ returns 0 over SSH; fall back to a typical 8x16 cell.
    if xpixel == 0 or ypixel == 0 then
        xpixel = sz.col * 8
        ypixel = sz.row * 16
    end
    return { cell_width = xpixel / sz.col, cell_height = ypixel / sz.row }
end

local function adjust_to_aspect_ratio(cell, img_w, img_h, max_w, max_h)
    local aspect = img_w / img_h
    local px_w = max_w * cell.cell_width
    local px_h = max_h * cell.cell_height
    if px_h / img_h > px_w / img_w then
        return max_w, math.ceil(px_w / aspect / cell.cell_height)
    else
        return math.ceil(px_h * aspect / cell.cell_width), max_h
    end
end

local function compute_image_cells(path)
    local out = vim.fn.system({ "magick", "identify", "-format", "%w %h", path })
    if vim.v.shell_error ~= 0 then
        return CONFIG.IMAGE_MAX_WIDTH, CONFIG.IMAGE_MAX_HEIGHT
    end
    local iw, ih = out:match("(%d+)%s+(%d+)")
    if not iw then
        return CONFIG.IMAGE_MAX_WIDTH, CONFIG.IMAGE_MAX_HEIGHT
    end
    local cell = get_term_cell_size()
    if not cell then
        return CONFIG.IMAGE_MAX_WIDTH, CONFIG.IMAGE_MAX_HEIGHT
    end
    return adjust_to_aspect_ratio(cell, tonumber(iw), tonumber(ih), CONFIG.IMAGE_MAX_WIDTH, CONFIG.IMAGE_MAX_HEIGHT)
end

local function should_render()
    if vim.api.nvim_buf_get_name(0) ~= "" then
        return false
    end
    if vim.bo.buftype ~= "" then
        return false
    end
    if vim.b.is_dashboard then
        return false
    end
    if vim.fn.line2byte("$") ~= -1 then
        return false
    end
    return true
end

local function repeat_line(t, s, n)
    for _ = 1, n do
        t[#t + 1] = s
    end
end

local function compute_layout(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    local function center(str)
        local shift = math.floor((win_width - vim.fn.strdisplaywidth(str)) / 2)
        return string.rep(" ", math.max(shift, 0)) .. str
    end
    local centered_menu = vim.tbl_map(center, MENU_LINES)

    local image_width, image_height = compute_image_cells(avatar_path())
    local image_x = math.max(math.floor((win_width - image_width) / 2), 0)
    -- image.nvim resolves x via vim.fn.screenpos on the buffer line, so
    -- the line must extend at least to image_x or screenpos collapses to
    -- the start of the line and the image renders flush left.
    local image_row = string.rep(" ", image_x)

    local total = image_height + CONFIG.MENU_GAP + #centered_menu
    local pad_top = math.max(math.floor((win_height - total) / 3), 0)

    local lines = {}
    repeat_line(lines, "", pad_top)
    local image_y = #lines
    repeat_line(lines, image_row, image_height)
    repeat_line(lines, "", CONFIG.MENU_GAP)
    vim.list_extend(lines, centered_menu)

    return {
        lines = lines,
        image_x = image_x,
        image_y = image_y,
        image_width = image_width,
        image_height = image_height,
    }
end

local function fill_buffer(buf, layout)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, layout.lines)

    vim.api.nvim_set_hl(0, "DashboardDim", { link = "Comment" })
    local ns = vim.api.nvim_create_namespace("dashboard")
    for i, line in ipairs(layout.lines) do
        if line:find("Find") or line:find("Grep") or line:find("Recent") then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                line_hl_group = "DashboardDim",
            })
        end
    end

    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
end

local function schedule_image(buf, win, layout)
    vim.schedule(function()
        local ok, image_api = pcall(require, "image")
        if not ok then
            return
        end
        local img = image_api.from_file(avatar_path(), {
            id = "dashboard_avatar",
            window = win,
            buffer = buf,
            x = layout.image_x,
            y = layout.image_y,
            width = layout.image_width,
            height = layout.image_height,
        })
        if img then
            img:render()
        end
    end)
end

local function render_dashboard()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.b[buf].is_dashboard = true
    vim.api.nvim_set_current_buf(buf)
    local win = vim.api.nvim_get_current_win()

    -- image.nvim measures x from the text area (post-gutter), while
    -- nvim_win_get_width includes the gutter; clearing both keeps the
    -- math consistent and centers the avatar against the window.
    vim.wo[win][0].number = false
    vim.wo[win][0].relativenumber = false
    vim.wo[win][0].signcolumn = "no"

    local layout = compute_layout(win)
    fill_buffer(buf, layout)
    schedule_image(buf, win, layout)
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
    callback = function(args)
        if args.event == "VimEnter" and vim.fn.argc() ~= 0 then
            return
        end
        if vim.v.vim_did_enter == 0 then
            return
        end
        if not should_render() then
            return
        end
        render_dashboard()
    end,
})
