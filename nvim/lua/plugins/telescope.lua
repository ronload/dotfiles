return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    config = function()
      -- tokyonight-night palette
      local c = {
        bg = "#1a1b26",
        bg_dark = "#16161e",
        bg_highlight = "#292e42",
        fg = "#c0caf5",
        fg_dark = "#a9b1d6",
        comment = "#565f89",
        blue = "#7aa2f7",
        cyan = "#7dcfff",
        green = "#9ece6a",
        magenta = "#bb9af7",
        orange = "#ff9e64",
        red = "#f7768e",
        yellow = "#e0af68",
      }

      local hl = vim.api.nvim_set_hl
      hl(0, "TelescopeNormal", { bg = c.bg_dark, fg = c.fg })
      hl(0, "TelescopeBorder", { bg = c.bg_dark, fg = c.comment })
      hl(0, "TelescopePromptNormal", { bg = c.bg_dark, fg = c.fg })
      hl(0, "TelescopePromptBorder", { bg = c.bg_dark, fg = c.comment })
      hl(0, "TelescopePromptTitle", { bg = c.blue, fg = c.bg_dark })
      hl(0, "TelescopePreviewTitle", { bg = c.green, fg = c.bg_dark })
      hl(0, "TelescopeResultsTitle", { bg = c.magenta, fg = c.bg_dark })
      hl(0, "TelescopeSelection", { bg = c.bg_highlight, fg = c.fg })
      hl(0, "TelescopeSelectionCaret", { bg = c.bg_highlight, fg = c.magenta })
      hl(0, "TelescopeMatching", { fg = c.cyan, bold = true })

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
            n = {
              ["<Esc>"] = "close",
              ["q"] = "close",
            },
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}
