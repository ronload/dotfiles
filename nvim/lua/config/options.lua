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

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = true,
  },
  signs = true,
  underline = true,
})

-- Statusline helpers
local function stl_git_branch()
  local branch = vim.b.gitsigns_head
  if not branch or branch == "" then
    return ""
  end
  return " " .. branch .. " "
end

local function stl_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return ""
  end
  local icon = devicons.get_icon_by_filetype(vim.bo.filetype, { default = true })
  return icon and (icon .. " ") or ""
end

_G.Stl_git_branch = stl_git_branch
_G.Stl_icon = stl_icon

vim.opt.statusline = table.concat({
  "%<",
  "%{v:lua.Stl_icon()}",
  "%t %h%w%m%r",
  " %{% v:lua.require('vim._core.util').term_exitcode() %}",
  "%=",
  "%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}",
  "%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}",
  "%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}",
  "%{% &busy > 0 ? '◐ ' : '' %}",
  "%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}",
  "%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%)' : &rulerformat ) : '' %}",
  " %{v:lua.Stl_git_branch()}",
})
