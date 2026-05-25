local IMAGE_MAX_WIDTH = 40
local IMAGE_MAX_HEIGHT = 20

local function avatar_path()
  local source = debug.getinfo(1, "S").source:sub(2)
  local real = (vim.uv or vim.loop).fs_realpath(source) or source
  return vim.fn.fnamemodify(real, ":h:h:h:h") .. "/assets/avator-ascii.png"
end

local function compute_image_cells(path)
  local out = vim.fn.system({ "magick", "identify", "-format", "%w %h", path })
  if vim.v.shell_error ~= 0 then
    return IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT
  end
  local iw, ih = out:match("(%d+)%s+(%d+)")
  if not iw then
    return IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT
  end
  iw, ih = tonumber(iw), tonumber(ih)

  local ok_term, term = pcall(require, "image.utils.term")
  local ok_math, math_utils = pcall(require, "image.utils.math")
  if not ok_term or not ok_math then
    return IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT
  end
  local term_size = term.get_size()
  if not term_size or term_size.cell_width == 0 or term_size.cell_height == 0 then
    return IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT
  end

  return math_utils.adjust_to_aspect_ratio(term_size, iw, ih, IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      local menu_lines = {
        " Find                                󱁐 + ff",
        "󰘧 Grep                                󱁐 + fg",
        "󱋢 Recent                              󱁐 + fr",
        "󰈆 Quit                                󰘶 + q ",
      }

      local function center(str)
        local width = vim.api.nvim_win_get_width(0)
        local shift = math.floor((width - vim.fn.strdisplaywidth(str)) / 2)
        return string.rep(" ", shift) .. str
      end

      local centered_menu = vim.tbl_map(center, menu_lines)

      local image_width, image_height = compute_image_cells(avatar_path())

      local win_width = vim.api.nvim_win_get_width(0)
      local image_x = math.max(math.floor((win_width - image_width) / 2), 0)
      local image_padding = string.rep(" ", image_x)

      local MENU_GAP = 3

      local total = image_height + MENU_GAP + #centered_menu
      local pad_top = math.max(math.floor((vim.o.lines - total) / 3), 0)

      local padded = {}
      for _ = 1, pad_top do
        table.insert(padded, "")
      end
      local image_y = #padded
      for _ = 1, image_height do
        table.insert(padded, image_padding)
      end
      for _ = 1, MENU_GAP do
        table.insert(padded, "")
      end
      for _, l in ipairs(centered_menu) do
        table.insert(padded, l)
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)

      vim.api.nvim_set_hl(0, "DashboardDim", { link = "Comment" })
      local ns = vim.api.nvim_create_namespace("dashboard")
      for i, line in ipairs(padded) do
        local row = i - 1
        if
            line:find("Explorer")
            or line:find("Find")
            or line:find("Grep")
            or line:find("Recent")
            or line:find("Quit")
        then
          vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
            line_hl_group = "DashboardDim",
          })
        end
      end

      vim.bo[buf].modifiable = false
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].swapfile = false

      local opts = { buffer = buf, silent = true }
      vim.keymap.set("n", "f", ":Telescope find_files<CR>", opts)
      vim.keymap.set("n", "r", ":Telescope oldfiles<CR>", opts)
      vim.keymap.set("n", "q", ":qa<CR>", opts)

      vim.schedule(function()
        local ok, image_api = pcall(require, "image")
        if not ok then
          return
        end

        local img = image_api.from_file(avatar_path(), {
          id = "dashboard_avatar",
          window = vim.api.nvim_get_current_win(),
          buffer = buf,
          x = image_x,
          y = image_y,
          width = image_width,
          height = image_height,
        })
        if img then
          img:render()
        end
      end)
    end
  end,
})
