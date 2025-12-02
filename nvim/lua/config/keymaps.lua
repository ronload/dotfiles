vim.keymap.set({ "i", "v", "c" }, "jk", "<Esc>", { desc = "Exit to normal mode" })

-- Window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate to window above" })
