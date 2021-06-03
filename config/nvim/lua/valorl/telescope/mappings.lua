local nnoremap = vim.keymap.nnoremap
local telescope = require('telescope.builtin')

nnoremap { "<C-p>", telescope.git_files }
nnoremap { "<leader>fc", require('telescope.command').load_command }
nnoremap { "<leader>ff", telescope.find_files }
nnoremap { "<leader>fg", telescope.live_grep }
