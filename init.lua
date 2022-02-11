vim.g.mapleader = ","

-- Switching between tabs by <tab> / <shift-tab>
vim.api.nvim_set_keymap("n", "<tab>", "gt", { noremap = true })
vim.api.nvim_set_keymap("n", "<s-tab>", "gT", { noremap = true })
