vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.titlestring = "%t - nvim"
vim.opt.scrolloff = 999
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldenable = true
vim.opt.foldlevel = 99

-- status line
local mode_map = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  R = "REPLACE",
  t = "TERMINAL",
}
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = true,
  },
  signs = true,
  underline = true,
})
vim.opt.statusline = "%!v:lua.Statusline()"

function Statusline()
  local mode = mode_map[vim.fn.mode()] or vim.fn.mode()
  local branch = vim.b.gitsigns_head or ""
  local filename = "%t %m%r"
  local filetype = "%y"
  return string.format(" %s │ %s │ %s%%=%s ", mode, filename, branch, filetype)
end
