local snacks = prequire("snacks")
if snacks then
  snacks.setup({
    picker = { enabled = true },
  })

  local opts = { noremap = true }

  vim.keymap.set("n", "<C-p>", function() Snacks.picker.git_files() end, opts)
  vim.keymap.set("n", "<leader>pc", function() Snacks.picker.commands() end, opts)
  vim.keymap.set("n", "<leader>pf", function() Snacks.picker.files() end, opts)
  vim.keymap.set("n", "<leader>pg", function() Snacks.picker.grep() end, opts)
  vim.keymap.set("n", "<leader>pws", function() Snacks.picker.grep_word() end, opts)
  vim.keymap.set("n", "<leader>pWs", function()
    Snacks.picker.grep({ search = vim.fn.expand("<cWORD>") })
  end, opts)
  vim.keymap.set("n", "<leader>ps", function()
    Snacks.picker.grep({ search = vim.fn.input("Grep > ") })
  end, opts)
  vim.keymap.set("n", "<leader>ph", function() Snacks.picker.help() end, opts)
end
