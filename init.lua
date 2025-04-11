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
			-- Fix Telescope selection color
			-- https://github.com/pappasam/papercolor-theme-slim/issues/10#issuecomment-2706602161
			-- vim.defer_fn(function()
			-- 	vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "CursorLine" })
			-- end, 1500)

			vim.cmd([[colorscheme PaperColorSlim]])
			-- Fix Telescope selection color
			-- https://github.com/pappasam/papercolor-theme-slim/issues/10#issuecomment-2706602161
			vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "CursorLine" })
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
			-- ft("sql"):fmt({
			-- 	cmd = "sleek",
			-- 	stdin = true,
			-- })
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
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				pickers = { find_files = { hidden = true } },
				defaults = {
					file_ignore_patterns = { "%.git", "node_modules" },
					layout_strategy = "horizontal",
					layout_config = {
						width = vim.o.columns,
						height = vim.o.lines,
						preview_width = 0.5,
					},
					mappings = {
						i = {
							["<cr>"] = actions.select_tab,
							["<C-o>"] = function(prompt_bufnr)
								actions.close(prompt_bufnr)
								require("oil").open()
							end,
						},
					},
				},
			})

			vim.keymap.set(
				"n",
				"<leader>f",
				"<cmd>lua require('telescope.builtin').find_files()<cr>",
				{ silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>n",
				"<cmd>lua require('telescope.builtin').find_files({search_dirs={'~/Documents/notes'}})<cr>",
				{ silent = true }
			)
			vim.keymap.set("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { silent = true })
		end,
	},
	{
		--- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer", -- Completion based on the content of the current buffer
			"hrsh7th/cmp-cmdline", -- Completion in Vim's command line
			"hrsh7th/cmp-nvim-lsp", -- LSP-based completion
			"hrsh7th/cmp-path", -- File system paths
			"ray-x/cmp-treesitter", -- Treesitter-based completion
			"hrsh7th/cmp-nvim-lsp-signature-help", -- Shows function signatures as you type
			-- "zjp-CN/nvim-cmp-lsp-rs", -- TODO: better sorting for Rust suggestions
		},
		config = function()
			-- Checks if there are non-whitespace characters before the cursor in the current line
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "treesitter" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = {
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
					-- ["<CR>"] = cmp.mapping.confirm({ select = true }),
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
		end,
	},
	{
		"preservim/vim-markdown",
		dependencies = { "godlygeek/tabular" },
		config = function()
			vim.g.vim_markdown_folding_disabled = 1
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
					virtual_text = true,
					signs = true,
					update_in_insert = true,
				})

			-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
			--
			-- vim.lsp.handlers["textDocument/signatureHelp"] =
			-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

			local on_attach = function(client, bufnr)
				local function map(...)
					vim.api.nvim_buf_set_keymap(bufnr, ...)
				end

				-- Mappings
				local opts = { noremap = true, silent = true }

				-- See `:help vim.lsp.*` for documentation on any of the below functions
				map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
				map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
				map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
				map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
				map("n", "<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
				map("n", "<space>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
				map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
				map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
				map("n", "<space>q", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)
				map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

				require("lsp_signature").on_attach({
					doc_lines = 0,
					hint_enable = false,
					zindex = 50, -- signature behind completion items
					handler_opts = {
						border = "none",
					},
				})
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.bashls.setup({
				cmd = { "/usr/bin/node", "/usr/local/bin/bash-language-server", "start" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			lspconfig.typos_lsp.setup({})
			lspconfig.biome.setup({
				cmd = { "/usr/bin/node", "/usr/local/bin/biome", "lsp-proxy" },
				single_file_support = true,
				capabilities = capabilities,
				on_attach = on_attach,
			})
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				flags = {
					debounce_text_changes = 150,
				},
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						-- completion = {
						-- 	postfix = {
						-- 		enable = false,
						-- 	},
						-- },
						-- rustfmt = {
						--     overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
						-- },
						-- procMacro = {
						--     ignored = {
						--         leptos_macro = {
						--             -- optional: --
						--             -- "component",
						--             "server",
						--         },
						--     },
						-- },
					},
				},
			})
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "require" },
						},
					},
				},
			})
			lspconfig.marksman.setup({
				on_attach = on_attach,
			})
			lspconfig.ruff.setup({
				on_attach = on_attach,
			})
			lspconfig.vuels.setup({
				on_attach = on_attach,
				cmd = { "/usr/bin/node", "/usr/local/bin/vls" },
			})
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
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				-- List of available servers: https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
				ensure_installed = {
					"lua_ls",
					"marksman",
				},
				automatic_installation = true,
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
	-- {
	-- 	"alopatindev/cargo-limit",
	-- 	build = "cargo install --locked cargo-limit nvim-send",
	-- },
})
