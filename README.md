# Nvim config

Revisiting my nvim settings while moving the config to Lua

- reloading the config: `:source lua.vim`

## Packer

- install plugins and exit: `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`

## TODO

- https://github.com/nvim-treesitter/nvim-treesitter#quickstart
    daf - delete outside function
    [m - move to the next method

Bugs:

- Auto-completion: first tab hit selects the second item
- Auto completion of files - how to select a folder with tab?

Features:

- Open git grep in a quickfix list
- Open clippy suggestions in a quickfix list

Stuff from the previous config:

- <https://github.com/neovim/nvim-lspconfig>
- <https://github.com/nvim-lua/lsp_extensions.nvim>
- <https://github.com/lifepillar/pgsql.vim>

Stuff to consider:

- <https://github.com/FeiyouG/command_center.nvim>
- <https://github.com/renerocksai/telekasten.nvim>
- rust tools
- <https://github.com/nvim-pack/nvim-spectre>
- <https://github.com/chaoren/vim-wordmotion>
- <https://github.com/jose-elias-alvarez/null-ls.nvim>
- <https://github.com/folke/trouble.nvim>
