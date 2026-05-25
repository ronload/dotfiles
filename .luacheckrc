-- Luacheck config for Neovim dotfiles.
std = "luajit"

globals = {
  "vim",
}

max_line_length = 120
max_cyclomatic_complexity = 15

unused_args = true
redefined = true
