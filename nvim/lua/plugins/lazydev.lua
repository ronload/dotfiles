return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "blink.cmp", words = { "blink%.cmp" } },
      { path = "yazi.nvim", words = { "Yazi" } },
    },
  },
}
