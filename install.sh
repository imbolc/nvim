#!/usr/bin/env sh
set -eux

# JS / CSS
sudo npm install -g prettier yaml-unist-parser
sudo npm install -g @biomejs/biome

# Vue
sudo npm install -g vls

# Sh
sudo apt install -y shellcheck # linter, used automatically by bash-language-server
sudo apt install -y shfmt      # formatter
sudo npm install -g bash-language-server

# Spelling
cargo install --locked --quiet typos-cli

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
