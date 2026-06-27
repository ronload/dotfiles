return {
    "stevearc/oil.nvim",
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    keys = {
        { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    lazy = false,
}
