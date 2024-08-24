#!/usr/bin/env bash
set -eux

# JS / CSS
sudo npm install -g prettier yaml-unist-parser

# Bash
sudo apt install -y shfmt # formatter
sudo npm install bash-language-server

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
