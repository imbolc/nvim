-- sudo npm install -g prettier lua-fmt yaml-unist-parser
-- pip3 install black isort
-- cargo install taplo-cli stylua

local keymap = vim.api.nvim_set_keymap
local keyopts = { noremap = true, silent = true }

vim.g.mapleader = ","

vim.o.cursorline = true

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Wrapping
vim.o.wrap = false
vim.o.breakindent = true
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Search
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Indentation
vim.o.smarttab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.autoindent = true

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
vim.cmd([[colorscheme PaperColor]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Switching between tabs by <tab> / <shift-tab>
keymap("n", "<tab>", "gt", keyopts)
keymap("n", "<s-tab>", "gT", keyopts)

-- don't lose selection when shifting
keymap("x", "<", "<gv", keyopts)
keymap("x", ">", ">gv", keyopts)

vim.api.nvim_command("autocmd BufWritePost *.json5 set filetype=json5")

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

	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

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
					html = { prettier() },
					json = { prettier() },
					json5 = { prettier() },
					yaml = { prettier() },
					css = { prettier() },
					vue = { prettier() },
					markdown = { prettier() },
					javascript = { prettier("--tab-width", 4) },
					lua = { exe_args_stdin("stylua", "-") },
					rust = { exe_args_stdin("rustfmt") },
					toml = { exe_args_stdin("taplo", "fmt", "-") },
					python = { exe_args_stdin("isort", "--profile", "black", "-"), exe_args_stdin("black", "-") },
				},
			})
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

	use("NLKNguyen/papercolor-theme")

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

			telescope.setup({
				defaults = {
					file_ignore_patterns = { ".git", "node_modules" },
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
					},
				},
			})

			telescope.load_extension("fzf")
			telescope.load_extension("packer")
		end,
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use("nvim-telescope/telescope-packer.nvim")

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
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
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
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
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
					["<ESC>"] = cmp.mapping.close(),
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
					completeopt = "menu,menuone",
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
	use("L3MON4D3/LuaSnip")
	use("RRethy/vim-illuminate")

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
					vim.api.nvim_buf_set_map(bufnr, ...)
				end

				require("lsp_signature").on_attach(lspSignatureCfg)
				require("illuminate").on_attach(client)

				-- Mappings.
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

			local lsp_installer = require("nvim-lsp-installer")

			lsp_installer.on_server_ready(function(server)
				local config = make_config()

				if server.name == "sumneko_lua" then
					-- config = require("lsp.servers.sumneko_lua").setup(config, on_attach)
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

				if server.name == "texlab" then
					config = require("lsp.servers.texlab").setup(config, on_attach)
				end

				if server.name == "html" then
					config = require("lsp.servers.html").setup(config, on_attach)
				end

				if server.name == "jsonls" then
					config = require("lsp.servers.jsonls").setup(config, on_attach)
				end

				if server.name == "tsserver" then
					config = require("lsp.servers.tsserver").setup(config, on_attach)
				end

				if server.name == "yamlls" then
					config = require("lsp.servers.yamlls").setup(config, on_attach)
				end

				if server.name == "volar" then
					config = require("lsp.servers.volar").setup(config, on_attach)
				end

				if server.name == "rust_analyzer" then
					config = require("lsp.servers.rust_analyzer").setup(config, on_attach)
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
end)
