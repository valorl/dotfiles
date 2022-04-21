local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        prompt_prefix = "❯ ",
        color_devicons = true,

        file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
        grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
        qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

        mappings = {
            i = {
                ["<C-x>"] = false,
                ["<C-q>"] = actions.send_to_qflist,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,                      -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,     -- override the file sorter
                case_mode = "smart_case",        -- or "ignore_case" or "respect_case"

            }
        }
    }
}

require('telescope').load_extension('fzf')
require("telescope").load_extension "file_browser"
