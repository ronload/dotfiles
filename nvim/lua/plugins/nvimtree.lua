return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
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
          width = 30,
        },
      })
    end,
  },
}
