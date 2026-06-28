local M = {}

M.group = vim.api.nvim_create_augroup("valorl", {})

vim.api.nvim_create_augroup("MkdirOnWrite", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "MkdirOnWrite",
  callback = function(event)
    local file = event.match
    local dir = vim.fn.fnamemodify(file, ":h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

return M
