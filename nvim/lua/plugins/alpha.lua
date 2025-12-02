return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
        [[                                                    ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"

      -- Footer
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          dashboard.section.footer.val = "Loaded " .. stats.loaded .. " plugins"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      alpha.setup(dashboard.opts)

      -- Tokyonight colors for alpha
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#9ece6a" })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89" })
    end,
  },
}
