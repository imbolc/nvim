-- Install dependencies: ./install.sh
vim.g.mapleader = ","

vim.opt.mouse = ""

vim.opt.autowrite = true -- automatically :write before running a commands
vim.opt.spell = true
vim.opt.spelllang = "en,ru"

-- Backup
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "no" -- do dot display sign column to have more horizontal space

vim.api.nvim_command("autocmd ColorScheme * highlight VertSplit guibg=bg guifg=white")

-- Wrapping
vim.opt.wrap = false -- disable soft wrapping at the edge of the screen
vim.opt.textwidth = 0 -- disable hard wrapping
vim.opt.linebreak = true -- do not wrap in the middle of a word when soft wrapping is enabled
vim.opt.breakindent = true -- preserve indentation of softly wrapped lines
-- move through softly wrapped lines more naturally
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Search / substitute
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split" -- preview substitutions
vim.opt.gdefault = true

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Decrease update time
vim.opt.updatetime = 100

-- Don't lose selection when shifting blocks
vim.keymap.set("x", "<", "<gv", { silent = true })
vim.keymap.set("x", ">", ">gv", { silent = true })

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

vim.keymap.set("n", "<C-Up>", ":resize +3<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -3<CR>", { silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize +3<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize -3<CR>", { silent = true })

-- disable ex mode
vim.keymap.set("n", "Q", "<nop>", { silent = true })
vim.keymap.set("n", "q:", "<nop>", { silent = true })

-- Switching between tabs by <tab> / <shift-tab>
vim.keymap.set("n", "<tab>", "gt", { silent = true })
vim.keymap.set("n", "<s-tab>", "gT", { silent = true })

-- Show status line only if there are at least two windows
vim.opt.laststatus = 1

-- Hide command line until typing a command or recording a script
vim.opt.cmdheight = 0
vim.cmd("autocmd RecordingEnter * set cmdheight=1")
vim.cmd("autocmd RecordingLeave * set cmdheight=0")

-- Templates
vim.api.nvim_exec(
	[[
    augroup templates
        autocmd BufNewFile *.sh 0r ~/.config/nvim/templates/skeleton.sh
    augroup END
    ]],
	true
)

vim.diagnostic.config({
	virtual_text = true, -- single-line errors
	-- virtual_lines = true, -- multi-line errors
})

--------------------------------
-- File type related settings --
--------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.bo.commentstring = "-- %s"
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>r", ":w|!psql -a -f %<CR>", { noremap = true, silent = true })
	end,
})
vim.cmd([[au FileType lua map <buffer> <leader>r :w\| :source  %<cr>]])
vim.cmd([[au FileType rust map <buffer> <leader>r :w\|! DATABASE_URL=postgres:/// rust-script %<cr>]])
vim.cmd([[au FileType sh map <buffer> <leader>r :w\|!sh %<cr>]])
vim.cmd([[au FileType python map <buffer> <leader>r :w\|!python3 %<cr>]])
vim.cmd([[au FileType html map <buffer> <leader>r :w\|!open %<cr>]])
vim.cmd([[au FileType javascript map <buffer> <leader>r :w\|!node %<cr>]])
vim.cmd([[
    au FileType markdown setlocal wrap
    au FileType markdown setlocal spell
    au FileType markdown setlocal conceallevel=0
    " au FileType markdown setlocal colorcolumn=80
    au FileType markdown map <buffer> <leader>r :w\|!comrak --unsafe -e table -e footnotes % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
    au FileType markdown TSBufDisable highlight
    " hard wrapping
    " au FileType markdown setlocal textwidth=80 formatoptions+=t
]])
vim.cmd([[
    au FileType yaml setlocal wrap
    au FileType yaml setlocal spell
]])
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Force commentstring to include spaces",
	-- group = ...,
	callback = function(event)
		local cs = vim.bo[event.buf].commentstring
		vim.bo[event.buf].commentstring = cs:gsub("(%S)%%s", "%1 %%s"):gsub("%%s(%S)", "%%s %1")
	end,
})

function OpenTodo(in_split, show_errors)
	local possible_files = { ".todo", ".todo.txt", ".todo.md", "var/todo.txt", "var/todo.md" }
	local existing_files = {}
	local function error(msg)
		if show_errors then
			vim.notify(msg, vim.log.levels.ERROR)
		end
	end

	---@param fname string
	---@return string
	function resolve_symlink(fname)
		local expanded = vim.uv.fs_realpath(fname)
		if expanded ~= nil then
			return expanded
		end
		return fname
	end

	for _, filename in ipairs(possible_files) do
		-- filename = vim.uv.fs_realpath(filename) or filename
		if vim.fn.filereadable(filename) == 1 then
			vim.print(filename)
			table.insert(existing_files, filename)
		end
	end

	if #existing_files == 0 then
		error("No TODO file found, tried:\n" .. table.concat(possible_files, "\n"))
	elseif #existing_files > 1 then
		error("Multiple TODO files found:\n" .. table.concat(existing_files, "\n"))
	else
		vim.cmd((in_split and "vsplit" or "edit") .. " " .. existing_files[1])
	end
end

vim.keymap.set("n", "<leader>t", "<cmd>lua OpenTodo(true, true)<cr>", { silent = true })
vim.keymap.set("n", "<leader>T", "<cmd>vs ~/Documents/todo.md<cr>", { silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.defer_fn(function()
				OpenTodo(false, false)
			end, 0)
		end
	end,
})

function FindLabRs()
	local function find_file(dir)
		local handle = vim.loop.fs_scandir(dir)
		if handle then
			while true do
				local name, type = vim.loop.fs_scandir_next(handle)
				if not name then
					break
				end

				local path = dir .. "/" .. name
				if type == "file" and name == "lab.rs" then
					return path
				elseif type == "directory" then
					local result = find_file(path)
					if result then
						return result
					end
				end
			end
		end
	end

	local current_dir = vim.fn.getcwd()
	local lab_rs_path = find_file(current_dir)

	if lab_rs_path then
		vim.cmd("tabnew " .. lab_rs_path)
	else
		vim.notify("lab.rs not found", vim.log.levels.ERROR)
	end
end

vim.keymap.set("n", "<leader>l", "<cmd>lua FindLabRs()<cr>", { silent = true })

-- Auto change theme
function AutoTheme()
	local file = vim.fn.expand("~/.config/nvim/theme.lua")
	vim.system({ "touch", file })

	local event = vim.loop.new_fs_event()
	event:start(
		file,
		{},
		vim.schedule_wrap(function(err, _, events)
			if err then
				vim.notify("Error watching theme file: " .. err, vim.log.levels.ERROR)
				event:stop()
				return
			end
			if events.change then
				dofile(file)
			end
		end)
	)

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			if event then
				event:stop()
			end
		end,
	})
end
AutoTheme()

-------------
-- Plugins --
-------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"rust-lang/rust.vim",
	"mechatroner/rainbow_csv",
	"ConradIrwin/vim-bracketed-paste", -- Auto paste mode
	"junegunn/vim-slash", -- Automatically remove search selection
	{
		-- Show function signature when you type
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
	"Xuyuanp/sqlx-rs.nvim",
	{
		"pappasam/papercolor-theme-slim",
		config = function()
			vim.cmd([[colorscheme PaperColorSlim]])
		end,
	},
	{
		-- Tables
		"dhruvasagar/vim-table-mode",
		config = function()
			vim.g.table_mode_corner = "|" -- markdown-compatible corners
		end,
	},
	{
		"GutenYe/json5.vim",
		config = function()
			vim.api.nvim_command("autocmd BufWritePost *.json5 set filetype=json5")
		end,
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				view_options = {
					show_hidden = true,
				},
			})
			vim.keymap.set("n", "<leader>d", ":Oil --preview<cr>", { silent = true })
		end,
	},
	{
		-- Formatters
		"nvimdev/guard.nvim",
		-- "guard.nvim",
		-- dir = "/home/imbolc/0/open/guard.nvim",
		dependencies = {
			"nvimdev/guard-collection",
		},
		config = function()
			local ft = require("guard.filetype")
			local fm = require("guard-collection.formatter")

			-- Use global version of prettier
			local global_prettier = {
				cmd = "/usr/bin/nodejs",
				args = { "/usr/local/bin/prettier", "--stdin-filepath" },
				fname = true,
				stdin = true,
			}

			local rustfmt_nightly = {
				cmd = "rustup",
				args = { "run", "nightly", "rustfmt", "--edition", "2024", "--emit", "stdout" },
				stdin = true,
			}

			ft("sh"):fmt(fm.shfmt)
			ft("lua"):fmt(fm.stylua)
			ft("rust"):fmt(rustfmt_nightly)
			ft("css,scss,html,javascript,json,json5,vue,yaml"):fmt(global_prettier)
			ft("markdown"):fmt({
				cmd = "/usr/bin/nodejs",
				args = {
					"/usr/local/bin/prettier",
					"--print-width",
					"80",
					"--prose-wrap",
					"always",
					"--stdin-filepath",
				},
				fname = true,
				stdin = true,
			})
			ft("toml"):fmt(fm.taplo)
			ft("python"):fmt(fm.ruff)
			ft("sql"):fmt({
				cmd = "sleek",
				stdin = true,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"comment",
					"css",
					"html",
					"javascript",
					"json",
					"json5",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"rust",
					"svelte",
					"toml",
					"typescript",
					"vue",
					"yaml",
					"query", -- Treesitter
					"scss",
					"sql",
				},
				highlight = {
					enable = true,
					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
				injections = {
					enable = true,
				},
			})
		end,
	},
	-- Ensure this file is placed correctly for lazy.nvim, e.g., lua/plugins/fzf-lua.lua
	{
		"ibhagwan/fzf-lua",
		config = function()
			local fzf_lua = require("fzf-lua")
			local actions = require("fzf-lua.actions")

			fzf_lua.setup({
				fzf_bin = "sk", -- use skim instead of fzf
				actions = {
					files = {
						true, -- inherit default bindings
						["enter"] = actions.file_tabedit, -- open in a tab on Enter
					},
				},
				defaults = {
					file_icons = false,
				},
			})

			vim.keymap.set("n", "<leader>f", function()
				fzf_lua.files()
			end, { silent = true, desc = "Find Files" })

			vim.keymap.set("n", "<leader>n", function()
				fzf_lua.files({ cwd = vim.fn.expand("~/Documents/notes") })
			end, { silent = true, desc = "Find Notes" })

			vim.keymap.set("n", "<leader>g", function()
				fzf_lua.live_grep()
			end, { silent = true, desc = "Live Grep" })
		end,
	},
	{
		--- Autocompletion
		"saghen/blink.cmp",
		dependencies = "rafamadriz/friendly-snippets",
		version = "v0.*",
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					buffer = {
						name = "Buffer",
						module = "blink.cmp.sources.buffer",
					},
				},
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
			},
			signature = {
				enabled = true,
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"preservim/vim-markdown",
		dependencies = { "godlygeek/tabular" },
		config = function()
			vim.g.vim_markdown_folding_disabled = 1
		end,
	},
	{
		-- Native LSP configuration (Neovim 0.11+)
		-- This replaces nvim-lspconfig with Neovim's built-in LSP configuration system
		-- LSP server configs are loaded from ~/.config/nvim/lsp/*.lua files
		-- Uses vim.lsp.config() and vim.lsp.enable() for cleaner, more maintainable setup
		name = "native-lsp",
		dir = vim.fn.stdpath("config"),
		config = function()
			-- Configure diagnostics
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				update_in_insert = true,
			})

			-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
			-- vim.lsp.handlers["textDocument/signatureHelp"] =
			-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

			-- Global LSP configuration that applies to all servers
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- Set up LspAttach autocommand for keybindings
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local bufnr = ev.buf
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					local function map(mode, lhs, rhs, opts)
						opts = opts or {}
						opts.buffer = bufnr
						opts.noremap = true
						opts.silent = true
						vim.keymap.set(mode, lhs, rhs, opts)
					end

					-- LSP keybindings
					map("n", "gD", vim.lsp.buf.declaration)
					map("n", "gd", vim.lsp.buf.definition)
					map("n", "gi", vim.lsp.buf.implementation)
					map("n", "<C-k>", vim.lsp.buf.signature_help)
					map("n", "<space>D", vim.lsp.buf.type_definition)
					map("n", "<space>r", vim.lsp.buf.rename)
					map("n", "<space>a", vim.lsp.buf.code_action)
					map("n", "gr", vim.lsp.buf.references)
					map("n", "<space>e", vim.diagnostic.open_float)
					map("n", "<space>q", vim.diagnostic.setloclist)
					map("n", "<space>f", function()
						vim.lsp.buf.format({ async = true })
					end)

					-- Set up lsp_signature
					require("lsp_signature").on_attach({
						doc_lines = 0,
						hint_enable = false,
						zindex = 50, -- signature behind completion items
						handler_opts = {
							border = "none",
						},
					}, bufnr)
				end,
			})

			-- Enable LSP servers using native configuration
			local servers = {
				"bashls",
				"biome",
				"lua_ls",
				"marksman",
				"ruff",
				"rust_analyzer",
				"typos_lsp",
				"vuels",
				"harper_ls",
			}

			for _, server in ipairs(servers) do
				vim.lsp.enable(server)
			end
		end,
	},
	{
		-- Installer for LSP servers, linters, etc
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		-- Automatic installation of LSP servers, linters, etc
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				-- List of available servers: https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"bashls",
					"biome",
					"marksman",
					"ruff",
					"vuels",
					"typos_lsp",
				},
				automatic_installation = true,
				-- Disable automatic LSP setup since we're using native vim.lsp.enable()
				automatic_enable = false,
			})
		end,
	},
	{
		--- LSP progress at the bottom-right
		"j-hui/fidget.nvim",
		tag = "v1.4.1",
		config = function()
			require("fidget").setup()
		end,
	},
	{
		--- Replace in multiple files, use `:Spectre` command
		"nvim-pack/nvim-spectre",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"alopatindev/cargo-limit",
		build = "cargo install --locked cargo-limit nvim-send",
	},
})
