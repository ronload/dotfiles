return {
    -- Mason: LSP/DAP/Linter/Formatter installer
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Mason-lspconfig bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "gopls",
                "ts_ls",
                "pyright",
                "rust_analyzer",
                "lua_ls",
                "prismals",
            },
        },
    },

    -- LSP config
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            -- Advertise blink.cmp capabilities (incl. snippet support) to all LSP servers
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
            })

            -- Key mappings and completion on LSP attach
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = { buffer = args.buf }

                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "[d", function()
                        vim.diagnostic.jump({ count = -1 })
                    end, opts)
                    vim.keymap.set("n", "]d", function()
                        vim.diagnostic.jump({ count = 1 })
                    end, opts)
                end,
            })

            -- Go
            vim.lsp.config.gopls = {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_markers = { "go.work", "go.mod", ".git" },
                settings = {
                    gopls = {
                        gofumpt = true,
                        analyses = {
                            unusedparams = true,
                            unusedwrite = true,
                        },
                        staticcheck = true,
                    },
                },
            }

            -- TypeScript/JavaScript
            vim.lsp.config.ts_ls = {
                cmd = { "typescript-language-server", "--stdio" },
                filetypes = {
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                },
                root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
            }

            -- Python
            vim.lsp.config.pyright = {
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                root_markers = { "pyproject.toml", "setup.py", "pyrightconfig.json", ".git" },
            }

            -- Rust
            vim.lsp.config.rust_analyzer = {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml", ".git" },
            }

            -- Lua
            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            }

            -- Prisma
            vim.lsp.config.prismals = {
                cmd = { "prisma-language-server", "--stdio" },
                filetypes = { "prisma" },
                root_markers = { "schema.prisma", ".git" },
            }

            vim.lsp.enable({ "gopls", "ts_ls", "pyright", "rust_analyzer", "lua_ls", "prismals" })
        end,
    },
}
