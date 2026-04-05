return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<CMD>NvimTreeToggle<CR>", desc = "Open NvimTree" },
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          side = "left",
          width = 40,
        },
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        renderer = {
          root_folder_label = false,
          highlight_git = "all",
          indent_markers = {
            enable = true,
          },
          icons = {
            git_placement = "after",
          },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local opts = { buffer = bufnr, noremap = true, silent = true }

          api.config.mappings.default_on_attach(bufnr)

          vim.keymap.set("n", "l", api.node.open.edit, opts)
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts)
        end,
      })
    end,
  },
}
