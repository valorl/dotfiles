vim.pack.add({
  "https://github.com/linux-cultist/venv-selector.nvim",
}, { confirm = false, load = false })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  once = true,
  callback = function()
    vim.cmd.packadd("venv-selector.nvim")
  end,
})
