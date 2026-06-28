# 2020 Config Rewrite

The neovim config should be completely rewritten from scratch into a fresh, more modern structure.
100% feature parity is not the goal.

## Structure

The new structure should be a simple structure consisting of:
* `init.lua` - lean entrypoint
* `lua/config` - general options / keymaps / commands, etc
* `lua/plugins` - plugin installation / instantiation using vim.pack
* `lsp/` - configs for each individual LSP according to https://github.com/neovim/nvim-lspconfig

Existing usage of other standard paths outside of `lua/` should be kept as is.

## Plugin management

Plugins should no longer be managed using lazy.nvim, but instead use built in `vim.pack` functionality.
Any lazy-loading capabilities, if currently utilized, can be dropped in favor of the simpler initialization via `vim.pack`. 

Should there be suspicion about any other functionality that may have been used/present in the exising lazy.nvim config,
and would be lost by simply moving it to `vim.pack`, the course of action should be investigated and brought up for review until a specific solution is found and approved.

## LSP config management

LSP configuration should be managed according to the latest recommended, built-in approach `vim.lsp.config`, as documented in https://github.com/neovim/nvim-lspconfig and `:h lsp-config`.
It is assumed that installing the `neovim/nvim-lspconfig` plugin makes all the nvim-lspconfig configs ready to be used as long as they are `vim.lsp.enable`d.
In that case, it is desired and should be installed (`lua/plugins`).

LSPs should be enabled (`vim.lsp.enable`) in `lua/config/lsp.lua`.

blink.cmp should be installed and used for autocompletion 
