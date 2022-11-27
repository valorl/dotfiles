return require("packer").startup(function(use)
  use 'wbthomason/packer.nvim'

  -- LOCAL
  use { '/home/vao/repos/local/github.com/valorl/vcslink.nvim',
    requires = {"nvim-lua/plenary.nvim"}
  }

  -- Themes
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'tomasiser/vim-code-dark'
  use 'gruvbox-community/gruvbox'
  use 'eddyekofo94/gruvbox-flat.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'tjdevries/lsp_extensions.nvim'
  use 'hrsh7th/nvim-compe'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  use { 'glepnir/lspsaga.nvim', requires = {'neovim/nvim-lspconfig'} }
  use { "ray-x/lsp_signature.nvim" }

  use {
    "cuducos/yaml.nvim",
    ft = {"yaml"},
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim"
    },
    config = function () require("yaml_nvim").init() end,
  }

  use 'Hoffs/omnisharp-extended-lsp.nvim'

  -- Lua
  use 'tjdevries/nlua.nvim'
  use 'euclidianAce/BetterLua.vim'

  -- DAP
  use 'mfussenegger/nvim-dap'
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use 'theHamsta/nvim-dap-virtual-text'
  use "mfussenegger/nvim-dap-python"

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'kyazdani42/nvim-web-devicons'
  use 'nvim-telescope/telescope-file-browser.nvim'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    'nvim-treesitter/playground',
    requires = {'nvim-treesitter/nvim-treesitter'}
  }
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = {'nvim-treesitter/nvim-treesitter'}
  }

  use {
    'romgrk/nvim-treesitter-context',
    requires = {'nvim-treesitter/nvim-treesitter'}
  }

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-treesitter/nvim-treesitter"}
    }
  }

  -- Comments
  use 'tpope/vim-commentary'

  -- Surround
  use 'tpope/vim-surround'

  -- Color preview
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }
  use 'hashivim/vim-terraform'
  -- use 'OmniSharp/omnisharp-vim'
  -- use 'tweekmonster/gofmt.vim'
  -- use 'jremmen/vim-ripgrep'
  use 'tpope/vim-fugitive'
  use 'shumphrey/fugitive-gitlab.vim'
  use 'mbbill/undotree'
  use 'qpkorr/vim-renamer'
  -- use 'tpope/vim-markdown'
  use 'flw-cn/vim-markdown'

  use 'tjdevries/colorbuddy.vim'
  use 'tjdevries/gruvbuddy.nvim'

  use 'pprovost/vim-ps1'
  use "rhysd/git-messenger.vim"

  use 'google/vim-jsonnet'
  use 'towolf/vim-helm'
  use "lukas-reineke/indent-blankline.nvim"

  use 'psliwka/vim-smoothie'

  use 'jjo/vim-cue'

  use 'L3MON4D3/LuaSnip'

  -- use {
  --   "ThePrimeagen/harpoon",
  --   requires = {{"nvim-lua/plenary.nvim"}}
  -- }
  --
  -- install without yarn or npm
  use({
      "iamcco/markdown-preview.nvim",
      run = function() vim.fn["mkdp#util#install"]() end,
  })

  use 'junegunn/vim-easy-align'
end)