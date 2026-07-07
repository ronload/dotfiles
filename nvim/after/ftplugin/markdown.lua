vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.breakindentopt = "list:-1"

local opts = { buffer = true, expr = true, silent = true }
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", opts)
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", opts)
