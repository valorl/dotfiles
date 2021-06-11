local nnoremap = vim.keymap.nnoremap
local dap = require('dap')

nnoremap { "<leader>dc", dap.continue }
nnoremap { "<leader>do", dap.step_over }
nnoremap { "<leader>di", dap.step_into }
nnoremap { "<leader>dO", dap.step_out }
nnoremap { "<leader>db", dap.toggle_breakpoint }
nnoremap { "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end}
nnoremap { "<leader>dr", dap.repl.open }
