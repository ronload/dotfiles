return {
    {
        "saghen/blink.cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = { preset = "super-tab" },

            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            snippets = { preset = "default" },

            signature = { enabled = true },
        },
    },
}
