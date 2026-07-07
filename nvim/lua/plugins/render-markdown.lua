return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        render_modes = true,
        win_options = {
            conceallevel = { default = vim.o.conceallevel, rendered = 2 },
            concealcursor = { default = vim.o.concealcursor, rendered = "nc" },
        },
    },
}
