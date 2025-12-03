return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  opt = {
    mappings = { "C-u", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
    hide_cursor = true,
    stop_eof = true,
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
  },
}
