return {
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    keys = {
      { "<leader>-", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
      { "<leader>e", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
      { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
      { "<C-Up>", "<cmd>Yazi toggle<cr>", desc = "Resume last Yazi" },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
      integrations = {
        grep_in_directory = "telescope",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
