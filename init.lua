-- sudo npm install -g prettier lua-fmt yaml-unist-parser
-- pip3 install black isort ueberzug
-- cargo install taplo-cli stylua comrak rust-script

local keymap = vim.api.nvim_set_keymap
local keyopts = { noremap = true, silent = true }

vim.g.mapleader = ","

-- vim.o.cursorline = true -- higlight cursor line
vim.o.autowrite = true -- automatically :write before running a commands
vim.o.spelllang = "ru,en"

-- set shortmess+=c  " Avoid showing extra messages when using completion

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Wrapping
vim.o.wrap = false
vim.o.breakindent = true
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Search / substitute
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split" -- preview substitutions
vim.o.gdefault = true

-- Indentation
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4

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

-- Set completeopt to have a better completion experience
-- vim.o.completeopt = "menuone,noselect"

-- Switching between tabs by <tab> / <shift-tab>
keymap("n", "<tab>", "gt", keyopts)
keymap("n", "<s-tab>", "gT", keyopts)

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

-- Show command line only with filename in it
vim.o.laststatus = 1
vim.o.rulerformat = "%15(%=%l,%c %P%)"
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
        autocmd BufNewFile *.sh 0r ~/.vim/templates/skeleton.sh
        autocmd BufNewFile *.vue 0r ~/.vim/templates/skeleton.vue
        autocmd BufNewFile *.svelte 0r ~/.vim/templates/skeleton.svelte
    augroup END
]],
	true
)

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	-- Treesitter
	use({ "/nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

	-- Json5
	use("GutenYe/json5.vim")
	vim.api.nvim_command("autocmd BufWritePost *.json5 set filetype=json5")

	-- Ranger
	use({ "kevinhwang91/rnvimr", run = "pip3 install ranger-fm pynvim ueberzug" })
	vim.g.rnvimr_enable_ex = 1
	vim.g.rnvimr_enable_picker = 1
	vim.g.rnvimr_action = { ["<cr>"] = "NvimEdit tabedit" }
	keymap("n", "<leader>t", ":RnvimrToggle<cr>", keyopts)
	keymap("n", "<leader>nc", ":e ~/Documents/scroll<cr>", keyopts)

	-- Rust
	use("rust-lang/rust.vim")
	vim.cmd([[au FileType rust map <buffer> <leader>r :w\|!rust-script %<cr>]])

	-- Tables
	use("dhruvasagar/vim-table-mode")
	vim.g.table_mode_corner = "|" -- markdown-compatible corners

	-- CSV
	use("mechatroner/rainbow_csv")

	-- Auto paste mode
	use("ConradIrwin/vim-bracketed-paste")

	-- Tmux splits integration
	use("christoomey/vim-tmux-navigator")

	-- Bash
	vim.cmd([[au FileType sh map <buffer> <leader>r :w\|!bash %<cr>]])

	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	use("junegunn/vim-slash") -- automatically remove search selection

	-- install https://github.com/grwlf/xkb-switch
	use("lyokha/vim-xkbswitch") -- automatically switch layout back leaving insert mode
	vim.g.XkbSwitchEnabled = 1

	use({
		"mhartington/formatter.nvim",
		config = function()
			local function prettier(...)
				local args = { ... }
				return function()
					table.insert(args, "--stdin-filepath")
					table.insert(args, vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)))
					return {
						exe = "prettier",
						args = args,
						stdin = true,
					}
				end
			end
			local function exe_args_stdin(exe, ...)
				local args = { ... }
				return function()
					-- print("args=", vim.inspect(args))
					return {
						exe = exe,
						args = args,
						stdin = true,
					}
				end
			end
			require("formatter").setup({
				filetype = {
					-- html = { prettier("--tab-width", 4) }, -- doesn't work with jinja
					json = { prettier() },
					json5 = { prettier() },
					yaml = { prettier() },
					css = { prettier() },
					vue = { prettier() },
					svelte = { prettier() },
					-- markdown = { prettier() },
					javascript = { prettier("--tab-width", 4) },
					lua = { exe_args_stdin("stylua", "-") },
					rust = { exe_args_stdin("rustfmt", "--emit=stdout", "--edition=2021") },
					toml = { exe_args_stdin("taplo", "fmt", "-") },
					python = { exe_args_stdin("isort", "--profile", "black", "-"), exe_args_stdin("black", "-") },
				},
			})
			-- autocmd BufWritePost *.rs,*.py,*.html,*.lua FormatWrite
			vim.api.nvim_exec(
				[[
                augroup FormatAutogroup
                autocmd!
                autocmd BufWritePost * silent! FormatWrite
                augroup END
                ]],
				true
			)
		end,
	})

	use({
		"NLKNguyen/papercolor-theme",
		config = function()
			vim.cmd([[colorscheme PaperColor]])
		end,
	})
	use("clinstid/eink.vim")

	-- Show version updates in `Cargo.toml`
	use({
		"saecki/crates.nvim",
		tag = "v0.1.0",
		event = { "BufRead Cargo.toml" },
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup()
		end,
	})

	-- Telescope
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
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					file_ignore_patterns = { ".git", "node_modules" },
					mappings = {
						i = {
							["<cr>"] = actions.select_tab,
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						-- override_generic_sorter = true,
						-- override_file_sorter = true,
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("packer")
		end,
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use("nvim-telescope/telescope-packer.nvim")

	keymap("n", "<leader>f", "<cmd>lua require('telescope.builtin').find_files()<cr>", keyopts)
	keymap("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", keyopts)
	keymap(
		"n",
		"<leader>n",
		"<cmd>lua require('telescope.builtin').find_files{search_dirs={'~/Documents/scroll'}}<cr>",
		-- "<cmd>lua require('telescope.builtin').live_grep{search_dirs={'~/Documents/scroll'}}<cr>",
		keyopts
	)

	--- Autocompletion
	use({
		"hrsh7th/nvim-cmp",
		requires = {
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
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Insert,
						select = true,
					}),
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
	})
	vim.cmd("au FileType toml lua require('cmp').setup.buffer { sources = { { name = 'crates' } } }")
	use("L3MON4D3/LuaSnip")

	use("editorconfig/editorconfig-vim")
	use("evanleck/vim-svelte")

	--- Grep and replacement in multiple files: lua require('spectre').open()
	use({
		"windwp/nvim-spectre",
		requires = { "nvim-lua/plenary.nvim" },
	})

	--- Postgres
	vim.cmd([[au FileType sql map <buffer> <leader>r :w\|!psql -f %<cr>]])

	--- Markdown
	vim.cmd([[
    au FileType markdown setlocal wrap
    au FileType markdown setlocal spell
    au FileType markdown setlocal conceallevel=2
    au FileType markdown vnoremap g gq
    au FileType markdown map <buffer> <leader>r :w\|!comrak --unsafe -e table % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
    ]])

	--- Yaml
	vim.cmd([[
    au FileType yaml setlocal wrap
    au FileType yaml setlocal spell
    ]])

	--- Vue
	use("posva/vim-vue")

	--- Jinja
	use("Glench/Vim-Jinja2-Syntax")

	--- Distraction free writing
	use({
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({
				window = {
					width = 80,
				},
			})
		end,
	})

	--- LSP
	use({
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
				vim.lsp.handlers.signature_help,
				{ border = "single" }
			)

			local lspSignatureCfg = {
				hint_enable = false,
				handler_opts = {
					border = "single",
				},
				zindex = 50, -- signatureHelp behind completion items
			}
			local on_attach = function(client, bufnr)
				local function map(...)
					vim.api.nvim_buf_set_keymap(bufnr, ...)
				end

				require("lsp_signature").on_attach(lspSignatureCfg)

				-- mappings.
				local opts = { noremap = true, silent = true }
				map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
				map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
				map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
				map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
				map("n", "<space>k", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				map("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
				map("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
				map("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
				map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
				map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
				map("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
				map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
				map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
				map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
				map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
				map("n", "<space>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

				-- Set some keybinds conditional on server capabilities
				if client.resolved_capabilities.document_formatting then
					map("n", "<space>f", ":lua vim.lsp.buf.formatting()<CR>", opts)
					vim.cmd([[
                    augroup lsp_format
                    autocmd! * <buffer>
                    autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting_sync()
                    augroup END
                    ]])
				elseif client.resolved_capabilities.document_range_formatting then
					map("n", "<space>rf", ":lua vim.lsp.buf.range_formatting_sync()<CR>", opts)
				end
			end

			local function make_config()
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
				return {
					capabilities = capabilities,
					on_attach = on_attach,
				}
			end

			require("nvim-lsp-installer").on_server_ready(function(server)
				local config = make_config()

				if server.name == "sumneko_lua" then
					local runtime_path = vim.split(package.path, ";")
					table.insert(runtime_path, "lua/?.lua")
					table.insert(runtime_path, "lua/?/init.lua")
					config.root_dir = require("lspconfig.util").root_pattern(".git", "init.lua")
					config.settings = {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
								-- Setup your lua path
								path = runtime_path,
							},
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = { "vim" },
							},
							-- Do not send telemetry data containing a randomized but unique identifier
							telemetry = {
								enable = false,
							},
						},
					}
				end

				if server.name == "rust_analyzer" then
					config.on_attach = function(client, bufnr)
						client.resolved_capabilities.document_formatting = false
						on_attach(client, bufnr)
					end
				end

				if server.name == "pylsp" then
					config.on_attach = function(client, bufnr)
						client.resolved_capabilities.document_formatting = false
						on_attach(client, bufnr)
						config.settings = {
							pylsp = {
								-- configurationSources = { "flake8" },
								plugins = {
									-- TODO ignoring doesn't work, not here nor in `.flake8` config
									flake8 = { ignore = { "E203" } },
								},
							},
						}
					end
				end

				server:setup(config)
				vim.cmd([[ do User LspAttachBuffers ]])
			end)
		end,
	})
	use("williamboman/nvim-lsp-installer")
	use("ray-x/lsp_signature.nvim")
	use("onsails/lspkind-nvim")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end

	-- Automatically recompile plugins, on the init file change
	vim.cmd([[
    augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
    augroup end
    ]])
end)
