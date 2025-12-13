vim.keymap.set({ "i", "c" }, "jk", "<Esc>", { desc = "Exit to normal mode" })

-- Window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate to window above" })

-- Quit fzf
vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>")

-- File Operations
vim.keymap.set("n", "Q", ":q!<CR>")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>wq", ":wq<CR>")

-- Fold
vim.keymap.set("n", "<Tab>", "za")

-- New empty line
vim.keymap.set("n", "<leader>o", "o<Esc>")
vim.keymap.set("n", "<leader>O", "O<Esc>")

-- Force new line
vim.keymap.set("i", "<S-CR>", "<C-e><CR>")
