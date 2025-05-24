#!/usr/bin/env sh
set -eux

# JS / CSS
sudo npm install -g prettier@latest yaml-unist-parser@latest
sudo npm install -g @biomejs/biome@latest

# Vue
sudo npm install -g vls@latest

# Sh
sudo apt install -y shellcheck # linter, used automatically by bash-language-server
sudo apt install -y shfmt      # formatter
sudo npm install -g bash-language-server@latest

# Spelling / Grammar
cargo install --locked --quiet typos-cli
cargo install --locked harper-ls

# Markdown
cargo install --locked --quiet comrak # renderer

# Lua
cargo install --locked --quiet stylua # formatter

# Toml
cargo install --locked --quiet taplo-cli # formatter

# Python
pipx install ruff # linter, formatter and LSP

# `fzf-lua`
cargo install --locked --quiet bat fd-find ripgrep skim

# Sql
# cargo install sleek # formatter
