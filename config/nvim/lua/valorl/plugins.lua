return require("packer").startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Themes
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'tomasiser/vim-code-dark'
  use 'gruvbox-community/gruvbox'
  use 'eddyekofo94/gruvbox-flat.nvim'

  -- Not yet ?
  -- https://github.com/tjdevries/astronauta.nvim/issues/1
  use 'tjdevries/astronauta.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'tjdevries/lsp_extensions.nvim'
  use 'hrsh7th/nvim-compe'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  use { 'glepnir/lspsaga.nvim', requires = {'neovim/nvim-lspconfig'} }


  -- Lua
  use 'tjdevries/nlua.nvim'
  use 'euclidianAce/BetterLua.vim'

  -- DAP
  use 'mfussenegger/nvim-dap'

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'kyazdani42/nvim-web-devicons'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    'nvim-treesitter/playground',
    requires = {'nvim-treesitter/nvim-treesitter'}
  }
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = {'nvim-treesitter/nvim-treesitter'}
  }

  -- Comments
  use 'tpope/vim-commentary'

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
end)
