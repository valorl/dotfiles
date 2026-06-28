# ADR 0001: Neovim 2026 Target Setup

## Status

Accepted

## Context

The Neovim config is being rewritten from scratch into a simpler modern structure. Full feature parity with the previous `lazy.nvim` based setup is not required.

The target Neovim version is `0.12+`, which provides the built-in `vim.pack` plugin manager and the modern LSP APIs based on `vim.lsp.config` and `vim.lsp.enable`.

The previous config used `lazy.nvim`, `nvim-cmp`, `mason.nvim`, `mason-lspconfig.nvim`, and direct `require("lspconfig").server.setup(...)` calls.

## Decision

Use this target structure:

- `init.lua` as a lean entrypoint.
- `lua/config/` for options, keymaps, commands, autocmds, and LSP enablement.
- `lua/plugins/` for plugin installation and plugin setup.
- `lsp/` for per-server LSP configuration.
- Existing standard runtime paths such as `after/` and `queries/` remain unchanged.

Use `vim.pack` for plugin installation instead of `lazy.nvim`.

Use `blink.cmp` for completion instead of `nvim-cmp`.

Use `snacks.nvim` for picker/search UI instead of `telescope.nvim`.

Use `vim.lsp.config` and `vim.lsp.enable` for LSP setup instead of `require("lspconfig").server.setup(...)`.

Keep Mason, but limit its responsibility:

- `mason.nvim` installs external editor tools and adds Mason binaries to Neovim's `PATH`.
- `mason-lspconfig.nvim` installs configured LSP servers via `ensure_installed`.
- LSP server enablement remains explicit in `lua/config/lsp.lua`.
- `mason-lspconfig.nvim` should use `automatic_enable = false`.

## Rationale

Explicit LSP enablement keeps startup behavior deterministic and readable. Mason state should not implicitly decide which servers start.

Using `vim.pack` removes the external plugin manager dependency and matches Neovim `0.12+`.

Using `lsp/*.lua` follows the current `nvim-lspconfig` direction and keeps server-specific settings isolated.

Using `blink.cmp` satisfies the rewrite requirement and avoids carrying over the old `nvim-cmp` dependency graph unless a concrete need appears.

Using `snacks.nvim` keeps picker/search functionality under a smaller modern plugin surface and avoids carrying over Telescope-specific dependency/configuration unless a concrete need appears.

## Consequences

Lazy-loading behavior from `lazy.nvim` is intentionally dropped unless a plugin has a concrete startup or side-effect problem.

Plugins with previous `build`, `cmd`, or `ft` behavior need explicit handling. Known examples:

- `markdown-preview.nvim` needs an explicit install/build step.
- `nvim-treesitter` needs explicit parser update handling.
- `sqlua.nvim` should not run expensive or credential-related setup at startup.
- Python-only tools such as `venv-selector.nvim` may need manual lazy behavior or acceptance of eager loading.

Mason will automatically download listed LSP servers, but it will not manage every external tool. Formatters, linters, and DAP tools may require either manual Mason installs or a later decision to add a tool installer.

Some language servers may not be Mason-managed and need special handling, especially:

- `kcl`
- `roslyn`
- possibly `jqls`

## Target Mason Setup

```lua
require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "gopls",
    "pyright",
    "yamlls",
    "rust_analyzer",
    "ts_ls",
    "terraformls",
    "tflint",
    "helm_ls",
    "jqls",
  },
  automatic_enable = false,
})
```

## Target LSP Enablement

```lua
vim.lsp.enable({
  "lua_ls",
  "gopls",
  "pyright",
  "yamlls",
  "rust_analyzer",
  "ts_ls",
  "terraformls",
  "tflint",
  "helm_ls",
  "jqls",
})
```

## Verification

After implementation:

- `nvim --headless '+lua print("config ok")' '+qa'`
- `:checkhealth vim.lsp`
- `:checkhealth mason`
- Open representative Lua, Go, Python, YAML, Terraform, TypeScript, Rust, C#, KCL, and Helm files.
- Verify completion, diagnostics, LSP attach mappings, formatter behavior, and Mason-installed server startup.
