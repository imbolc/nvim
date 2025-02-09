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
cargo install typos-cli

# Markdown
cargo install -q comrak # renderer

# Lua
cargo install -q stylua # formatter

# Toml
cargo install -q taplo-cli # formatter

# Python
pipx install ruff # linter, formatter and lsp

# Sql
# cargo install sleek # formatter
