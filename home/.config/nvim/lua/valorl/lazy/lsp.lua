local function create_autocmd_format(group, bufnr, client)
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    buffer = bufnr,
    callback = function()
      -- goimports
      -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
      if client.name == 'gopls' then
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        -- buf_request_sync defaults to a 1000ms timeout. Depending on your
        -- machine and codebase, you may want longer. Add an additional
        -- argument after params if you find that you have to write the file
        -- twice for changes to be saved.
        -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end
      end
      vim.lsp.buf.format { async = false }
    end,
  })
end

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neodev.nvim", opts = {} },
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
    "aznhe21/actions-preview.nvim",

    "seblj/roslyn.nvim",
    "towolf/vim-helm",
  },

  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = require("valorl.autocmd").group,
      callback = function(args)
        local bufnr = args.buf

        local opts = {
          buffer = bufnr,
          noremap = true
        }
        vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)

        vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, opts)

        vim.keymap.set("n", "<leader>grr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>grn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)
        -- vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>gca", require("actions-preview").code_actions, opts)
        vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>dh", vim.diagnostic.open_float, opts)


        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)

        local group = vim.api.nvim_create_augroup("valorl-lsp-attach-format", {})
        create_autocmd_format(group, bufnr, client)
      end

    })


    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    local default_handler = function(server_name)
      return function()
        require("lspconfig")[server_name].setup {
          capabilities = capabilities
        }
      end
    end


    local handlers = {
      ["terraformls"] = default_handler("terraformls"),
      ["pyright"] = default_handler("pyright"),
      ["yamlls"] = default_handler("yamlls"),
      ["rust_analyzer"] = default_handler("rust_analyzer"),
      ["ts_ls"] = default_handler("ts_ls"),

      ["kcl"] = function()
        require("lspconfig").kcl.setup({
          cmd = { "kcl-language-server" },
          filetypes = { "kcl" },
          root_dit = require("lspconfig.util").root_pattern(".git")
        })
      end,

      ["gopls"] = function()
        require("lspconfig").gopls.setup {
          capabilities = capabilities,
          settings = {
            gopls = {
              gofumpt = true,
              experimentalPostfixCompletions = true,
              staticcheck = true,
            }
          },
          -- TODO: How to navigate these when they appear ?
          -- init_options = {
          --   usePlaceholders = true
          -- }
        }
      end,

      -- ["golangci_lint_ls"] = function()
      --   require("lspconfig").golangci_lint_ls.setup {
      --     -- exclude "typecheck" double noise
      --     handlers = {
      --       ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
      --         local filtered = {}
      --         for _, d in ipairs(result["diagnostics"]) do
      --           if d["source"] ~= "typecheck" then
      --             table.insert(filtered, d)
      --           end
      --         end
      --
      --         result["diagnostics"] = filtered
      --         vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
      --       end
      --     }
      --   }
      -- end,

      ["lua_ls"] = function()
        require("lspconfig").lua_ls.setup {
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "it", "describe", "before_each", "after_each" },
                disable = { "missing-fields" }
              }
            }
          }
        }
      end,

      ["tflint"] = function()
        require("lspconfig").tflint.setup {
          capabilities = capabilities,
          cmd = { "tflint", "--langserver", "--disable-rule=terraform_required_providers" }
        }
      end,

      ["helm_ls"] = function()
        require("lspconfig").helm_ls.setup {
          capabilities = capabilities,
          settings = {
            ["helm-ls"] = {
              yamlls = {
                enable = false
                -- path = "/Users/vao/.local/share/nvim/mason/bin/yaml-language-server"
              }
            }
          }
        }
      end
    }

    for _, f in pairs(handlers) do
      f()
    end



    require("fidget").setup({})
    require("mason").setup()
    -- require("mason-lspconfig").setup()

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
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
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

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      { border = "single" }
    )

    -- roslyn.nvim
    require("roslyn").setup({
      config = {
        -- Here you can pass in any options that that you would like to pass to `vim.lsp.start`
        -- The only options that I explicitly override are, which means won't have any effect of setting here are:
        --     - `name`
        --     - `cmd`
        --     - `root_dir`
        --
        --     - `on_init`
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
        },
      },
      -- NOTE: Set `filewatching` to false if you experience performance problems.
      -- Defaults to true, since turning it off is a hack.
      -- If you notice that the server is _super_ slow, it is probably because of file watching
      -- I noticed that neovim became super unresponsive on some large codebases, and that was because
      -- it schedules the file watching on the event loop.
      -- This issue went away by disabling that capability. However, roslyn will fallback to its own
      -- file watching, which can make the server super slow to initialize.
      -- Setting this option to false will indicate to the server that neovim will do the file watching.
      -- However, in `hacks.lua` I will also just don't start off any watchers, which seems to make the server
      -- a lot faster to initialize.
      filewatching = true,
    })
  end
}
