# Nvim config

Revisiting my nvim settings while moving the config to Lua

- reloading the config: `:source lua.vim`

## Packer

- run `:PackerCompile` after changing a plugin configuration
- install plugins and exit: `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`
