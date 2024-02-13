return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {"folke/neodev.nvim", opts = {}},
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",

        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",

        "j-hui/fidget.nvim",
    },

    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = require("valorl.autocmd").group,
            callback = function(e)
                local opts = {
                    buffer = e.buf,
                    noremap = true
                }
                vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)

                vim.keymap.set("i", "<c-\\>", vim.lsp.buf.signature_help, opts)

                vim.keymap.set("n", "<leader>grr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>gdp", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "<leader>gdn", vim.diagnostic.goto_next, opts)
            end

        })


        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "terraformls", "tflint",
                "gopls", "golangci_lint_ls",
                "pyright",
                "yamlls",
                "lua_ls",
                "rust_analyzer",
                "tsserver",
            },
            handlers = {
                function(server_name) -- default handler (optional)

                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
