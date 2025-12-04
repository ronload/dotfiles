return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      fold = { enable = true },
      ensure_installed = {
        "go",
        "gomod",
        "gosum",
        "typescript",
        "tsx",
        "javascript",
        "python",
        "rust",
        "lua",
        "json",
        "yaml",
        "html",
        "css",
        "markdown",
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
