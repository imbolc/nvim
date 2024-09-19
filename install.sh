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

# Grammar
cargo install harper-ls --locked

# Markdown
cargo install -q comrak # renderer

# Lua
cargo install -q stylua # formatter

# Toml
cargo install -q taplo-cli # formatter

# Python
# TODO: consider using Ruff instead after it's published to crates.io:
# https://github.com/astral-sh/ruff/issues/43
pipx install black # formatter
pipx install isort # imports sorter
