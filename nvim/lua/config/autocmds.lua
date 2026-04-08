vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Input method auto-switch (requires: brew install macism)
local im_english = "com.apple.keylayout.ABC"
local im_prev = im_english

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    im_prev = vim.trim(vim.fn.system("macism"))
    if im_prev ~= im_english then
      vim.fn.system({ "macism", im_english })
    end
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    if im_prev ~= im_english then
      vim.fn.system({ "macism", im_prev })
    end
  end,
})
