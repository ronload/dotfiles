-- vim-tpipeline embeds nvim's statusline into the tmux status bar, so the
-- native statusline must stay hidden (laststatus=0). lualine re-runs setup()
-- (which forces laststatus back to 2) on every ColorScheme and background
-- change -- and it does so from inside its own autocmds, so a plain
-- `OptionSet laststatus` guard never fires (autocmds don't nest by default).
-- The background change in particular fires after startup on terminals that
-- probe the background colour (e.g. ghostty), which is why the duplicate bar
-- reappears. So hook the same events lualine uses and re-hide after it: the
-- synchronous call avoids a flicker, the scheduled one wins even if lualine
-- re-registers its handler after ours. Outside tmux, leave lualine's bar alone.
if vim.env.TMUX then
  local grp = vim.api.nvim_create_augroup("tpipeline_force_laststatus", { clear = true })
  local function hide()
    if vim.o.laststatus ~= 0 then
      vim.o.laststatus = 0
    end
  end
  local function rehide()
    hide()
    vim.schedule(hide)
  end
  vim.api.nvim_create_autocmd("ColorScheme", { group = grp, callback = rehide })
  vim.api.nvim_create_autocmd("OptionSet", { group = grp, pattern = "background", callback = rehide })
  hide()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 8
    vim.opt_local.shiftwidth = 8
    vim.opt_local.softtabstop = 8
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Auto-reload files changed outside Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.WARN)
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
