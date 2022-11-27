local nnoremap = require("valorl.keymap").nnoremap
local silent = { silent = true }

local builtin = require('telescope.builtin')

nnoremap("<C-p>", function()
  builtin.git_files({show_untracked = true})
end, silent)
nnoremap("<leader>pc", builtin.builtin)
nnoremap("<leader>pf", builtin.find_files)

nnoremap("<leader>pg", builtin.live_grep)
nnoremap("<leader>ps", function()
  builtin.grep_string({search = vim.fn.input("Search For: ")})
end)
-- grep current word
nnoremap("<leader>pw", function()
  builtin.grep_string({search = vim.fn.expand("<cword>")})
end)

nnoremap("<leader>pb", builtin.buffers)
