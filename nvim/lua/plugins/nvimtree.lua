return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<CMD>NvimTreeToggle<CR>", desc = "Open NvimTree" },
    },
    config = function()
      -- Tokyonight colors
      local c = {
        bg_dark = "#16161e",
        bg_highlight = "#292e42",
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

      -- NvimTree highlight groups
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = c.bg, fg = c.fg })
      vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = c.bg, fg = c.fg })
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = c.bg, fg = c.comment })
      vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = c.blue })
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = c.blue, bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = c.blue })
      vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = c.magenta, bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = c.orange })
      vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = c.green })
      vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = c.red })
      vim.api.nvim_set_hl(0, "NvimTreeSpecialFile", { fg = c.yellow })
      vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = c.comment })
      vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = c.bg_highlight })
      vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { fg = "#6b708a" })

      require("nvim-tree").setup({
        view = {
          side = "left",
          width = 40,
        },
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        renderer = {
          root_folder_label = false,
          highlight_git = "all",
          indent_markers = {
            enable = true,
          },
          icons = {
            git_placement = "after",
          },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local opts = { buffer = bufnr, noremap = true, silent = true }

          api.config.mappings.default_on_attach(bufnr)

          vim.keymap.set("n", "l", api.node.open.edit, opts)
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts)
        end,
      })
    end,
  },
}
