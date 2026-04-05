vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      local lines = {
        "",
        "",
        " ████████    ██████   ██████  █████ █████ ████  █████████████  ",
        "░░███░░███  ███░░███ ███░░███░░███ ░░███ ░░███ ░░███░░███░░███ ",
        " ░███ ░███ ░███████ ░███ ░███ ░███  ░███  ░███  ░███ ░███ ░███ ",
        " ░███ ░███ ░███░░░  ░███ ░███ ░░███ ███   ░███  ░███ ░███ ░███ ",
        " ████ █████░░██████ ░░██████   ░░█████    █████ █████░███ █████",
        "░░░░ ░░░░░  ░░░░░░   ░░░░░░     ░░░░░    ░░░░░ ░░░░░ ░░░ ░░░░░ ",
        "",
        "",
        "",
        " Explorer                            󱁐 + e ",
        " Find                                󱁐 + ff",
        "󰘧 Grep                                󱁐 + fg",
        "󱋢 Recent                              󱁐 + fr",
        "󰈆 Quit                                󰘶 + q ",
        "",
        "",
        "",
        "",
        "",
        "",
      }

      local function center(str)
        local width = vim.api.nvim_win_get_width(0)
        local shift = math.floor((width - vim.fn.strdisplaywidth(str)) / 2)
        return string.rep(" ", shift) .. str
      end

      local centered = vim.tbl_map(center, lines)

      local pad = math.floor((vim.o.lines - #centered) / 2)
      local padded = {}
      for _ = 1, pad do
        table.insert(padded, "")
      end
      for _, l in ipairs(centered) do
        table.insert(padded, l)
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)

      vim.api.nvim_set_hl(0, "DashboardDim", { link = "Comment" })
      for i, line in ipairs(padded) do
        local row = i - 1
        if
          line:find("Explorer")
          or line:find("Find")
          or line:find("Grep")
          or line:find("Recent")
          or line:find("Quit")
        then
          vim.api.nvim_buf_add_highlight(buf, -1, "DashboardDim", row, 0, -1)
        end
      end

      vim.bo[buf].modifiable = false
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].swapfile = false

      local opts = { buffer = buf, silent = true }
      vim.keymap.set("n", "f", ":Telescope find_files<CR>", opts)
      vim.keymap.set("n", "r", ":Telescope oldfiles<CR>", opts)
      vim.keymap.set("n", "q", ":qa<CR>", opts)
    end
  end,
})
