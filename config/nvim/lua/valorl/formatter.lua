require('formatter').setup({
  filetype = {
    go = {
      -- Go
      function()
        return { exe = "goimports", stdin = true }
      end
    },
  }
})


vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.go FormatWrite
augroup END
]], true)
