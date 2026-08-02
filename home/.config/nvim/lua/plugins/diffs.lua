vim.g.diffs = {
  integrations = {
    fugitive = true,
  },
}

vim.pack.add({
  "https://github.com/barrettruth/diffs.nvim",
}, { confirm = false, load = true })
