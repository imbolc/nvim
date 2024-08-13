#!/usr/bin/env bash
set -eux

# JS / CSS
sudo npm install -g prettier yaml-unist-parser

# Bash
sudo apt install -y shfmt # formatter

# Markdown
cargo install -q comrak # renderer

# Lua
cargo install -q stylua # formatter

# Toml
cargo install -q taplo-cli # formatter

# Python
pipx install black # formatter
pipx install isort # imports sorter
