return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      local colors = {
        bg = "NONE",
        fg = "#c0caf5",
        yellow = "#e0af68",
        cyan = "#7dcfff",
        darkblue = "#7aa2f7",
        green = "#9ece6a",
        orange = "#ff9e64",
        violet = "#bb9af7",
        magenta = "#bb9af7",
        blue = "#7aa2f7",
        red = "#f7768e",
      }

      return {
        options = {
          theme = {
            normal = {
              a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            insert = {
              a = { fg = colors.bg, bg = colors.green, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            visual = {
              a = { fg = colors.bg, bg = colors.magenta, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            replace = {
              a = { fg = colors.bg, bg = colors.red, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            command = {
              a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            inactive = {
              a = { fg = colors.fg, bg = colors.bg },
              b = { fg = colors.fg, bg = colors.bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
          },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      }
    end,
  },
}
