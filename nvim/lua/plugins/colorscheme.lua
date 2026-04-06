return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      transparent = true,
      on_highlights = function(hl, c)
        -- Telescope
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.comment }
        hl.TelescopePromptNormal = { bg = c.bg_dark, fg = c.fg }
        hl.TelescopePromptBorder = { bg = c.bg_dark, fg = c.comment }
        hl.TelescopePromptTitle = { bg = c.blue, fg = c.bg_dark }
        hl.TelescopePreviewTitle = { bg = c.green, fg = c.bg_dark }
        hl.TelescopeResultsTitle = { bg = c.magenta, fg = c.bg_dark }
        hl.TelescopeSelection = { bg = c.bg_highlight, fg = c.fg }
        hl.TelescopeSelectionCaret = { bg = c.bg_highlight, fg = c.magenta }
        hl.TelescopeMatching = { fg = c.cyan, bold = true }

        -- NvimTree
        hl.NvimTreeNormal = { bg = c.bg, fg = c.fg }
        hl.NvimTreeNormalNC = { bg = c.bg, fg = c.fg }
        hl.NvimTreeWinSeparator = { bg = c.bg, fg = c.comment }
        hl.NvimTreeFolderName = { fg = c.blue }
        hl.NvimTreeOpenedFolderName = { fg = c.blue, bold = true }
        hl.NvimTreeFolderIcon = { fg = c.blue }
        hl.NvimTreeRootFolder = { fg = c.magenta, bold = true }
        hl.NvimTreeGitDirty = { fg = c.orange }
        hl.NvimTreeGitNew = { fg = c.green }
        hl.NvimTreeGitDeleted = { fg = c.red }
        hl.NvimTreeSpecialFile = { fg = c.yellow }
        hl.NvimTreeIndentMarker = { fg = c.comment }
        hl.NvimTreeCursorLine = { bg = c.bg_highlight }
        hl.NvimTreeGitIgnored = { fg = c.dark3 }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
      vim.api.nvim_set_hl(0, "StatusLine", { link = "ModeMsg" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { link = "ModeMsg" })
    end,
  },
}
