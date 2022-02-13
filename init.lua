local keymap = vim.api.nvim_set_keymap
local keyopts = { noremap = true, silent = true }

vim.g.mapleader = ","

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Wrapping
vim.o.wrap = false
vim.o.breakindent = true
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 100

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

keymap("n", "<C-h>", "<C-w>h", keyopts)
keymap("n", "<C-j>", "<C-w>j", keyopts)
keymap("n", "<C-k>", "<C-w>k", keyopts)
keymap("n", "<C-l>", "<C-w>l", keyopts)

keymap("n", "<C-Up>", ":resize +3<CR>", keyopts)
keymap("n", "<C-Down>", ":resize -3<CR>", keyopts)
keymap("n", "<C-Left>", ":vertical resize +3<CR>", keyopts)
keymap("n", "<C-Right>", ":vertical resize -3<CR>", keyopts)

-- disable ex mode
keymap("n", "Q", "<nop>", keyopts)
keymap("n", "q:", "<nop>", keyopts)

-- Colorscheme
vim.o.termguicolors = true
vim.o.background = "light"
vim.cmd [[colorscheme PaperColor]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Switching between tabs by <tab> / <shift-tab>
keymap("n", "<tab>", "gt", { noremap = true })
keymap("n", "<s-tab>", "gT", { noremap = true })

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

-- Install packer
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
	use("wbthomason/packer.nvim")

	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	}

	use {
		'mhartington/formatter.nvim',
		config = function()
			require('formatter').setup()
			vim.api.nvim_exec([[
			augroup FormatAutogroup
				autocmd!
				autocmd BufWritePost * silent! FormatWrite
			augroup END
			]], true)
		end
	}

	use "NLKNguyen/papercolor-theme"

			use({
			"nvim-telescope/telescope.nvim",
			requires = "nvim-lua/plenary.nvim",
			module = "telescope",
			after = {
				"telescope-fzf-native.nvim",
				"telescope-packer.nvim",
			},
			config = function()
				local telescope = require("telescope")

						telescope.setup({
							defaults = {
								file_ignore_patterns = { ".git", "node_modules" },
							},
							extensions = {
								fzf = {
									fuzzy = true,
									override_generic_sorter = true,
									override_file_sorter = true,
								}
							}
						})

						telescope.load_extension("fzf")
						telescope.load_extension("packer")
			end,
		})
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
		use("nvim-telescope/telescope-packer.nvim")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

