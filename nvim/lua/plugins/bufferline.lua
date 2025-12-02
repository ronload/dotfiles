return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        indicator = {
          style = "none",
        },
        separator_style = { "", "" },
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = {
          {
            filetype = "NvimTree",
            text = function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            end,
            highlight = "Directory",
            separator = true,
          },
        },
      },
      highlights = {
        buffer_selected = {
          bold = true,
          italic = false,
          fg = "#7aa2f7",
        },
        background = {
          fg = "#565f89",
        },
        offset_separator = {
          fg = "#565f89",
        },
      },
    },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
    },
  },
}
