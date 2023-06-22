-- sudo npm install -g prettier lua-fmt yaml-unist-parser
-- pip3 install black isort ueberzug
-- cargo install taplo-cli stylua comrak rust-script

vim.g.mapleader = ","

vim.opt.mouse = ""

vim.opt.autowrite = true -- automatically :write before running a commands
vim.opt.spelllang = "en,ru"

-- Backup
vim.opt.backup = false
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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4

-- --  Display tabs
-- vim.wo.list = true
-- vim.opt.listchars:append("tab:»·")


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
vim.keymap.set("n", "<leader>t", ":echo 'foo'|:Texplore %:p:h<cr>", { silent = true })
vim.g.netrw_banner = 0

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local install_plugins = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("Installing packer...")
	local packer_url = "https://github.com/wbthomason/packer.nvim"
	vim.fn.system({ "git", "clone", "--depth", "1", packer_url, install_path })
	print("Done.")

	vim.cmd("packadd packer.nvim")
	install_plugins = true
end

require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
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
                    "query",  -- treesitter
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
                context_commentstring = {
                    enable = true,
                },
			})
		end,
	})

	-- Json5
	use("GutenYe/json5.vim")
	vim.api.nvim_command("autocmd BufWritePost *.json5 set filetype=json5")

    -- -- Joshuto (ranger clone)
    -- use("theniceboy/joshuto.nvim")
    -- vim.keymap.set("n", "<leader>d", ":w|:tabe %:p:h|:Joshuto<cr>", { silent = true })

	-- -- Ranger
	-- use({ "kevinhwang91/rnvimr", run = "sudo apt install ranger python3-pynvim ueberzug" })
	-- vim.g.rnvimr_enable_ex = 1
	-- vim.g.rnvimr_enable_picker = 1
    -- vim.g.rnvimr_enable_bw = 1
	-- vim.keymap.set("n", "<leader>t", ":RnvimrToggle<cr>", { silent = true })
	-- vim.keymap.set("n", "<leader>nc", ":e ~/Documents/scroll/data<cr>", { silent = true })
	-- vim.g.rnvimr_action = {
	-- 	["<cr>"] = "NvimEdit tabedit",
	-- 	["<C-t>"] = "NvimEdit tabedit",
	-- 	["<C-x>"] = "NvimEdit split",
	-- 	["<C-v>"] = "NvimEdit vsplit",
	-- 	["gw"] = "JumpNvimCwd",
	-- 	["yw"] = "EmitRangerCwd",
	-- }


	-- Rust
	use("rust-lang/rust.vim")
	-- Enable SQL highlighting inside Rust sqlx string literals
	-- vim.cmd([[
 --      autocmd FileType rust :lua << EOF
 --        vim.cmd("echo 'Custom Rust syntax file loaded'")
 --        vim.cmd("syntax include @Sql syntax/sql.vim")
 --        vim.cmd("syntax region sqlxSQL start=+\\b(sqlx::query!\\?)+ end=+\"+ contains=@Sql")
 --      EOF
 --    ]])
	vim.cmd([[
        au FileType rust map <buffer> <leader>r :w\|!rust-script %<cr>
        " au FileType rust setlocal spell
    ]])

	-- use({ "alopatindev/cargo-limit", run = "cargo install cargo-limit nvim-send" })

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

	-- Python
	vim.cmd([[au FileType python map <buffer> <leader>r :w\|!python3 %<cr>]])

	-- Commenting
	use({
		"JoosepAlviste/nvim-ts-context-commentstring",
		requires = "nvim-treesitter/nvim-treesitter",
	})
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
			local ft = require("Comment.ft")
			ft.sailfish = "<%#%s%>"
			ft.json5 = "// %s"
		end,
	})

	-- use({
	-- 	"ggandor/leap.nvim",
	-- 	config = function()
	-- 		require("leap").add_default_mappings()
	-- 	end,
	-- })

	use("junegunn/vim-slash") -- automatically remove search selection

	-- install https://github.com/grwlf/xkb-switch
	-- use("lyokha/vim-xkbswitch") -- automatically switch layout back leaving insert mode
	-- vim.g.XkbSwitchEnabled = 1

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
					typescript = { prettier() },
					-- markdown = { prettier() },
					javascript = { prettier() },
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
					file_ignore_patterns = { "%.git", "node_modules" },
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

	vim.keymap.set("n", "<leader>f", "<cmd>lua require('telescope.builtin').find_files()<cr>", { silent = true })
	vim.keymap.set("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { silent = true })
	vim.keymap.set(
		"n",
		"<leader>n",
		"<cmd>lua require('telescope.builtin').find_files{search_dirs={'~/Documents/scroll/data'}}<cr>",
		-- "<cmd>lua require('telescope.builtin').live_grep{search_dirs={'~/Documents/scroll/data'}}<cr>",
		{ silent = true }
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

	--- Html
	vim.cmd([[au FileType html map <buffer> <leader>r :w\|!open %<cr>]])

	--- Markdown
	use({
		"preservim/vim-markdown",
		requires = { "godlygeek/tabular" },
		config = function()
			vim.g.vim_markdown_folding_disabled = 1
		end,
	})
	vim.cmd([[
       au FileType markdown setlocal wrap
       au FileType markdown setlocal spell
       au FileType markdown setlocal conceallevel=2
       au FileType markdown vnoremap g gq
       au FileType markdown map <buffer> <leader>r :w\|!comrak --unsafe -e table % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
       au FileType markdown TSBufDisable highlight
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

	--- Sailfish
	vim.cmd("luafile ~/.config/nvim/plugin/packer_compiled.lua") -- packer `rtp` doesn't work without this
	use({ "rust-sailfish/sailfish", rtp = "syntax/vim" })

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
				map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
				map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
				map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
				map("n", "<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
				map("n", "<space>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
				map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
				map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
				map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
				map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
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
				on_attach = on_attach,
				flags = {
					debounce_text_changes = 150,
				},
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						completion = {
							postfix = {
								enable = false,
							},
						},
					},
				},
				capabilities = capabilities,
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
		end,
	})
	use({
		"williamboman/mason.nvim",
		run = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	})
	use({
		"williamboman/mason-lspconfig.nvim",
		requires = {
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
				},
				-- automatic_installation = true,
			})
		end,
	})

	use("nvim-treesitter/playground")

	--- LSP progress at the bottom-right
	use({ "j-hui/fidget.nvim", tag = "legacy", config = "require'fidget'.setup{}" })

	--- Show function signature when you type
	use("ray-x/lsp_signature.nvim")
	use("onsails/lspkind-nvim")

	use("edgedb/edgedb-vim")

	use("Xuyuanp/sqlx-rs.nvim")
    -- use("~/open/sqlx-rs.nvim")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if install_plugins then
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
