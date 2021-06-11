require'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "c_sharp", "yaml" },
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  indent = {
    enable = true,
  }
}
