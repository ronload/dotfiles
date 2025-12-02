return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Tokyonight palette
      local c = {
        blue = "#7aa2f7",
        cyan = "#7dcfff",
        green = "#9ece6a",
        magenta = "#bb9af7",
        orange = "#ff9e64",
        red = "#f7768e",
        yellow = "#e0af68",
        comment = "#565f89",
        fg = "#c0caf5",
      }

      -- Header with gradient effect
      dashboard.section.header.val = {
        [[                                                    ]],
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
        [[                                                    ]],
        [[                                                    ]],
      }

      -- Buttons with icons
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("l", "  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      -- Set button colors
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      -- Footer
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "Loaded " .. stats.loaded .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      -- Layout
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)

      -- Highlight groups with tokyonight colors
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = c.blue })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = c.cyan })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = c.magenta, bold = true })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = c.comment, italic = true })
    end,
  },
}
