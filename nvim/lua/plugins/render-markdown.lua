return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    win_options = {
      wrap = { default = false, rendered = true },
      linebreak = { default = false, rendered = true },
      breakindent = { default = false, rendered = true },
    },
  },
}
