return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      -- Tokyonight colors
      local c = {
        bg_dark = "#16161e",
        bg_highlight = "#292e42",
        blue = "#7aa2f7",
        cyan = "#7dcfff",
        magenta = "#bb9af7",
        orange = "#ff9e64",
        comment = "#565f89",
        fg = "#c0caf5",
      }

      -- Noice highlight groups
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = c.bg_dark })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = c.blue, bg = c.bg_dark })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = c.cyan, bg = c.bg_dark })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = c.magenta })
      vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = c.bg_dark })
      vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = c.blue, bg = c.bg_dark })

      require("noice").setup({
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          format = {
            cmdline = { icon = ">" },
            search_down = { icon = "/" },
            search_up = { icon = "?" },
            filter = { icon = "$" },
            lua = { icon = "" },
            help = { icon = "?" },
          },
        },
        views = {
          cmdline_popup = {
            position = {
              row = "50%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
        },
        messages = {
          enabled = true,
        },
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = {
            enabled = true,
          },
          signature = {
            enabled = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      })

      -- nvim-notify tokyonight colors
      require("notify").setup({
        background_colour = c.bg_dark,
      })
    end,
  },
}
