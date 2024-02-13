return {
    "nvim-telescope/telescope.nvim",

    branch = "0.1.x",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({})

        local builtin = require('telescope.builtin')
        local opts = { noremap = true }

        vim.keymap.set("n", "<C-p>", function() builtin.git_files({show_untracked = true}) end, opts)
        vim.keymap.set("n", "<leader>pc", builtin.builtin, opts)
        vim.keymap.set("n", "<leader>pf", builtin.find_files, opts)
        vim.keymap.set("n", "<leader>pg", builtin.live_grep, opts)

        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end, opts)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end, opts)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, opts)
        vim.keymap.set('n', '<leader>ph', builtin.help_tags, opts)
    end
}
