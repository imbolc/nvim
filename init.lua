-- sudo npm install -g prettier lua-fmt yaml-unist-parser
-- pip3 install black isort ueberzug
-- cargo install taplo-cli stylua comrak rust-script

vim.g.mapleader = ","

vim.opt.mouse = ""

vim.opt.autowrite = true -- automatically :write before running a commands
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

-- --  Display tab characters
-- vim.wo.list = true
-- vim.opt.listchars:append("tab:>·")

-- Decrease update time
vim.opt.updatetime = 100

-- Don't lose selection when shifting
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

-- Colorscheme
vim.opt.termguicolors = true
vim.opt.background = "light"

-- Set completeopt to have a better completion experience
-- vim.opt.completeopt = "menuone,noselect"

-- Switching between tabs by <tab> / <shift-tab>
vim.keymap.set("n", "<tab>", "gt", { silent = true })
vim.keymap.set("n", "<s-tab>", "gT", { silent = true })

-- Show command line only with filename in it
vim.opt.laststatus = 1
vim.opt.rulerformat = "%15(%=%l,%c %P%)"
vim.api.nvim_exec(
	[[
    function! _get_commandline_filename()
        let filename = @% =~ '^\/' ? @% : './' . @%
        " window width - pressed keys place - ruller, so it fits into a line
        let max = winwidth(0) - 11 - 16
        if len(filename) > max
            let filename = "<" . strcharpart(filename, len(filename) - max + 1)
        endif
        return filename
    endfunction
    augroup CmdLineFile
        autocmd!
        autocmd BufEnter * redraw! | echo _get_commandline_filename()
    augroup END
]],
	true
)

-- Templates
vim.api.nvim_exec(
	[[
    augroup templates
        autocmd BufNewFile *.sh 0r ~/.config/nvim/templates/skeleton.sh
        autocmd BufNewFile *.vue 0r ~/.config/nvim/templates/skeleton.vue
        autocmd BufNewFile *.svelte 0r ~/.config/nvim/templates/skeleton.svelte
    augroup END
]],
	true
)

-- Netrw file manager
-- I use it with a minimal setup, but prefer a Ranger-like layout with files preview
vim.keymap.set("n", "<leader>d", ":tabe %:p:h<cr>:echo 'D - delete | d - mkdir | % - new file'<cr>", { silent = true })

vim.cmd([[au FileType lua map <buffer> <leader>r :w\| :source  %<cr>]])
vim.cmd([[au FileType rust map <buffer> <leader>r :w\|! DATABASE_URL=postgres:/// rust-script %<cr>]])
vim.cmd([[au FileType sh map <buffer> <leader>r :w\|!bash %<cr>]])
vim.cmd([[au FileType python map <buffer> <leader>r :w\|!python3 %<cr>]])
vim.cmd([[au FileType sql map <buffer> <leader>r :w\|!psql -f %<cr>]])
vim.cmd([[au FileType html map <buffer> <leader>r :w\|!open %<cr>]])
vim.cmd([[au FileType javascript map <buffer> <leader>r :w\|!node %<cr>]])
vim.cmd([[
    au FileType markdown setlocal wrap
    " au FileType markdown setlocal textwidth=80
    au FileType markdown setlocal spell
    au FileType markdown setlocal conceallevel=0
    au FileType markdown vnoremap g gq
    au FileType markdown map <buffer> <leader>r :w\|!comrak --unsafe -e table -e footnotes % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
    au FileType markdown TSBufDisable highlight
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
	"ray-x/lsp_signature.nvim", --- Show function signature when you type
	"onsails/lspkind-nvim",
	"Xuyuanp/sqlx-rs.nvim",
	-- "evanleck/vim-svelte",
	-- "posva/vim-vue",
	{
		"NLKNguyen/papercolor-theme",
		config = function()
			-- vim.cmd([[colorscheme PaperColor]])
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
		end,
	},
	{
		-- Formatters
		"nvimdev/guard.nvim",
		dependencies = {
			"nvimdev/guard-collection",
		},
		config = function()
			local ft = require("guard.filetype")
			local fm = require("guard-collection.formatter")

			ft("lua"):fmt(fm.stylua)
			ft("rust"):fmt(fm.rustfmt)
			ft("css,html,javascript,json,json5,vue,yaml"):fmt(fm.prettier)
			ft("toml"):fmt(fm.taplo)
			ft("python"):fmt({
				cmd = "isort",
				args = { "--profile", "black", "-" },
				stdin = true,
			})

			require("guard").setup({
				fmt_on_save = true,
				lsp_as_default_formatter = true,
			})
		end,
	},
	-- {
	-- 	"mhartington/formatter.nvim",
	-- 	config = function()
	-- 		local function prettier(...)
	-- 			local args = { ... }
	-- 			return function()
	-- 				table.insert(args, "--stdin-filepath")
	-- 				table.insert(args, vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)))
	-- 				return {
	-- 					exe = "/usr/bin/node /usr/local/bin/prettier", -- use global node version
	-- 					args = args,
	-- 					stdin = true,
	-- 				}
	-- 			end
	-- 		end
	-- 		local function exe_args_stdin(exe, ...)
	-- 			local args = { ... }
	-- 			return function()
	-- 				-- print("args=", vim.inspect(args))
	-- 				return {
	-- 					exe = exe,
	-- 					args = args,
	-- 					stdin = true,
	-- 				}
	-- 			end
	-- 		end
	-- 		require("formatter").setup({
	-- 			filetype = {
	-- 				-- html = { prettier("--tab-width", 4) }, -- doesn't work with jinja
	-- 				json = { prettier() },
	-- 				json5 = { prettier() },
	-- 				yaml = { prettier() },
	-- 				css = { prettier() },
	-- 				scss = { prettier() },
	-- 				vue = { prettier() },
	-- 				svelte = { prettier() },
	-- 				typescript = { prettier() },
	-- 				-- markdown = { prettier() },
	-- 				javascript = { prettier() },
	-- 				lua = { exe_args_stdin("stylua", "-") },
	-- 				rust = { exe_args_stdin("rustfmt", "--emit=stdout", "--edition=2021") },
	-- 				-- rust = { exe_args_stdin("leptosfmt", "--stdin") },
	-- 				toml = { exe_args_stdin("taplo", "fmt", "-") },
	-- 				python = { exe_args_stdin("isort", "--profile", "black", "-"), exe_args_stdin("black", "-") },
	-- 			},
	-- 		})
	-- 		-- autocmd BufWritePost *.rs,*.py,*.html,*.lua FormatWrite
	-- 		vim.api.nvim_exec(
	-- 			[[
	--                augroup FormatAutogroup
	--                autocmd!
	--                autocmd BufWritePost * silent! FormatWrite
	--                augroup END
	--                ]],
	-- 			true
	-- 		)
	-- 	end,
	-- },
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
					"query", -- treesitter
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
				defaults = {
					file_ignore_patterns = { "%.git", "node_modules" },
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
		end,
	},
	{
		--- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-calc",
			"kdheepak/cmp-latex-symbols",
			"ray-x/cmp-treesitter",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
		},
		config = function()
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			local ls = require("luasnip")
			local s = ls.snippet
			local t = ls.text_node
			local i = ls.insert_node

			s("iferr", {
				t("if err != nil {"),
				i(1),
				t("}"),
			})

			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif ls.expand_or_locally_jumpable() then
							ls.expand_or_jump()
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
						elseif ls.jumpable(-1) then
							ls.jump(-1)
						else
							fallback()
						end
					end, {
						"i",
						"s",
					}),
					["<C-Space>"] = cmp.mapping.complete(),
					["<ESC>"] = cmp.mapping(function(fallback)
						cmp.close()
						fallback()
					end),
					-- ["<CR>"] = cmp.mapping.confirm({
					-- 	behavior = cmp.ConfirmBehavior.Insert,
					-- 	select = true,
					-- }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer", keyword_length = 4 },
					{ name = "path" },
					{ name = "nvim_lua" },
					{ name = "calc" },
				},
				completion = {
					completeopt = "menu,menuone,noselect",
				},
				formatting = {
					format = require("lspkind").cmp_format({
						with_text = true,
						maxwidth = 50,
						menu = {
							buffer = "Buffer",
							nvim_lsp = "LSP",
							luasnip = "LuaSnip",
							nvim_lua = "Lua",
							latex_symbols = "Latex",
						},
					}),
				},
			})

			cmp.setup.cmdline("/", {
				sources = cmp.config.sources({
					{ name = "nvim_lsp_document_symbol" },
				}, {
					{ name = "buffer" },
				}),
				completion = {
					completeopt = "menu,menuone,noselect",
				},
			})

			cmp.setup.cmdline("?", {
				sources = cmp.config.sources({
					{ name = "nvim_lsp_document_symbol" },
				}, {
					{ name = "buffer" },
				}),
				completion = {
					completeopt = "menu,menuone,noselect",
				},
			})

			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				completion = {
					completeopt = "menu,menuone,noselect",
				},
			})
		end,
	},
	"L3MON4D3/LuaSnip", -- TODO: remove or configure
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
			lspconfig.pyright.setup({
				on_attach = on_attach,
			})
			lspconfig.quick_lint_js.setup({
				on_attach = on_attach,
			})
			-- lspconfig.eslint.setup({
			-- 	on_attach = on_attach,
			-- })
			lspconfig.vuels.setup({
				on_attach = on_attach,
			})
			lspconfig.cssls.setup({
				on_attach = on_attach,
			})
			lspconfig.sqlls.setup({
				on_attach = on_attach,
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"cssls",
					"jsonls",
					"lua_ls",
					"marksman",
					"pyright",
					"quick_lint_js",
					"rust_analyzer",
					"sqlls",
					"svelte",
					"taplo",
					"volar",
					"vuels",
					"yamlls",
					-- "stylua", -- TODO: ?
				},
				-- automatic_installation = true,
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
})
