# Nvim config

## Install via SSH (editing)
```sh
git clone git@github.com:imbolc/nvim.git ~/.config/nvim
git clone git@github.com:imbolc/notes.git ~/Documents/notes
```

## Install via HTTPS (read-only)
```sh
git clone https://github.com/imbolc/nvim ~/.config/nvim
git clone https://github.com/imbolc/notes.git ~/Documents/notes
```

## Packer

- install plugins and exit: `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`

## TODO

- https://github.com/nvim-treesitter/nvim-treesitter#quickstart
    daf - delete outside function
    [m - move to the next method

Bugs:

- Auto-completion: first tab hit selects the second item

Stuff to consider:

- <https://github.com/FeiyouG/command_center.nvim>
- <https://github.com/renerocksai/telekasten.nvim>
- rust tools
- <https://github.com/nvim-pack/nvim-spectre>
- <https://github.com/chaoren/vim-wordmotion>
- <https://github.com/jose-elias-alvarez/null-ls.nvim>
- <https://github.com/folke/trouble.nvim>
