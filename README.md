# Nvim config

Revisiting my nvim settings while moving the config to Lua

- reloading the config: `:source lua.vim`

## Packer

- run `:PackerCompile` after changing a plugin configuration
- install plugins and exit: `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`

## TODO

Stuff from the previous config:

[ ] <https://github.com/neovim/nvim-lspconfig>
[ ] <https://github.com/nvim-lua/lsp_extensions.nvim>
[ ] <https://github.com/lifepillar/pgsql.vim>

Stuff to consider:

[ ] <https://github.com/renerocksai/telekasten.nvim>
[ ] rust tools
[ ] <https://github.com/nvim-pack/nvim-spectre>
[ ] <https://github.com/chaoren/vim-wordmotion>
