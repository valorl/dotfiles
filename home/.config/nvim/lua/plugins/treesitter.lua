local treesitter = prequire("nvim-treesitter.configs")
if treesitter then
  treesitter.setup({
    ensure_installed = "all",
    ignore_install = { "kcl" },
    sync_install = false,
    auto_install = true,
    indent = {
      enable = false,
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "markdown" },
    },
  })

  vim.treesitter.language.register("bash", "zsh")
end
