return {

    "nvim-lua/plenary.nvim",
    "gpanders/editorconfig.nvim",
    "tpope/vim-fugitive",


    {
        "numToStr/Comment.nvim",
        config = function()
            require('Comment').setup()
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        }

    },
    -- fun
    -- "github/copilot.vim",
    -- "eandrju/cellular-automaton.nvim",
}
