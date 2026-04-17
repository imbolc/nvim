-- Install dependencies: ./install.sh
require("vim._core.ui2").enable()

vim.g.mapleader = " "

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

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false -- Don't fold everything on open
vim.opt.foldlevel = 99 -- Start with all folds open

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
vim.opt.incsearch = true

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

-- Let native autocomplete open completion menus while typing so this config does not need a custom TextChangedI trigger.
vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
vim.opt.autocomplete = true

-- Enable built-in LSP completion on attach so native completion and manual omni-complete can use server results.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true,
			})
		end
	end,
})

-- Smart Tab for completion: trigger/navigate or insert tab
function InsertTabWrapper()
	if vim.fn.pumvisible() == 1 then
		return vim.api.nvim_replace_termcodes("<C-n>", true, true, true)
	end
	local col = vim.fn.col(".") - 1
	if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
		return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
	else
		-- Try file path completion first, then fallback to LSP omni completion
		local line = vim.fn.getline(".")
		local cursor_col = vim.fn.col(".")
		local before_cursor = line:sub(1, cursor_col - 1)

		-- Check if we're typing a path (contains / or . or ~)
		if before_cursor:match("[/.~]") then
			return vim.api.nvim_replace_termcodes("<C-x><C-f>", true, true, true)
		else
			return vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true)
		end
	end
end

vim.keymap.set("i", "<Tab>", "v:lua.InsertTabWrapper()", { expr = true, silent = true })
vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, silent = true })

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

-- Copy selection to the system clipboard
vim.keymap.set({ "v" }, "<leader>y", '"+y', { silent = true })

-- Copy the current buffer's full path into the primary selection (*) register
vim.keymap.set("n", "<leader>yf", function()
	-- Skip unnamed buffers so we don't yank empty paths.
	local path = vim.fn.expand("%:.")
	if path == "" then
		return
	end
	vim.fn.setreg("+", path)
	vim.notify(string.format("Copied: %s", path))
end, { silent = true })

-- Configure a notes-only keymap that copies a GitHub link for the current note.
local NOTES_ROOT = vim.fn.expand("~/Documents/notes")
-- Use an autocmd to attach the mapping only for buffers inside the notes folder.
local notes_link_augroup = vim.api.nvim_create_augroup("notes-link", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = notes_link_augroup,
	callback = function()
		-- Avoid redefining the mapping when the same buffer is revisited.
		if vim.b.notes_link_mapped then
			return
		end
		-- Only set the mapping when the current buffer is within the notes root.
		local path = vim.fn.expand("%:p")
		if path == "" then
			return
		end
		if path ~= NOTES_ROOT and not vim.startswith(path, NOTES_ROOT .. "/") then
			return
		end

		-- Mark the buffer so we only set the mapping once per notes buffer.
		vim.b.notes_link_mapped = true

		vim.keymap.set("n", "<leader>yl", function()
			-- Build and copy the notes URL relative to the notes root.
			local note_path = vim.fn.expand("%:p")
			if note_path == "" then
				return
			end
			local rel_path = note_path:sub(#NOTES_ROOT + 2)
			local url = string.format("https://github.com/imbolc/notes/tree/main/%s", rel_path)
			vim.fn.setreg("+", url)
			vim.notify(string.format("Copied: %s", url))
		end, { silent = true, buffer = 0, desc = "Copy Notes Link" })
	end,
})

-- Show status line only if there are at least two windows
vim.opt.laststatus = 1

-- Hide command line until typing a command or recording a script
vim.opt.cmdheight = 0
vim.cmd("autocmd RecordingEnter * set cmdheight=1")
vim.cmd("autocmd RecordingLeave * set cmdheight=0")

-- Would it help with losing access to clipboard?
vim.g.clipboard = {
	name = "xclip",
	copy = {
		["+"] = "xclip -selection clipboard",
		["*"] = "xclip -selection primary",
	},
	paste = {
		["+"] = "xclip -selection clipboard -o",
		["*"] = "xclip -selection primary -o",
	},
	cache_enabled = 1,
}

-- Templates
local templates_augroup = vim.api.nvim_create_augroup("templates", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
	group = templates_augroup,
	pattern = "*.sh",
	desc = "Load skeleton for shell scripts",
	command = "0r ~/.config/nvim/templates/skeleton.sh",
})

vim.diagnostic.config({
	-- single-line errors
	virtual_text = true,
})

--------------------------------
-- File type related settings --
--------------------------------
-- Treat `.env.local` files as shell scripts so they get sh highlighting/completion in this setup.
vim.filetype.add({
	filename = {
		[".env.local"] = "sh",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.bo.commentstring = "-- %s"
		-- Use <leader>x for run commands to keep <leader>r for LSP rename.
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>x",
			':silent w | !db="sandbox_$$" && createdb "$db" && psql -v ON_ERROR_STOP=1 -d "$db" -f %:S; rc=$?; dropdb --force "$db"; exit "$rc"<CR>',
			{ noremap = true, silent = true }
		)
	end,
})
vim.cmd([[au FileType lua map <buffer> <leader>x :w\| :source  %<cr>]])
vim.cmd([[au FileType rust map <buffer> <leader>x :w\|! DATABASE_URL=postgres:/// rust-script %<cr>]])
vim.cmd([[au FileType sh map <buffer> <leader>x :w\|!sh %<cr>]])
vim.cmd([[au FileType python map <buffer> <leader>x :w\|!python3 %<cr>]])
vim.cmd([[au FileType html map <buffer> <leader>x :w\|!open %<cr>]])
vim.cmd([[au FileType javascript map <buffer> <leader>x :w\|!node %<cr>]])
vim.cmd([[
    " au FileType markdown setlocal wrap
    au FileType markdown setlocal spell
    au FileType markdown setlocal conceallevel=0
    au FileType markdown map <buffer> <leader>x :w\|!comrak --unsafe -e table -e footnotes % > /tmp/vim.md.html && xdg-open /tmp/vim.md.html<cr>
]])
vim.cmd([[
    au FileType yaml setlocal wrap
    au FileType yaml setlocal spell
]])
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Force commentstring to include spaces",
	callback = function(event)
		local cs = vim.bo[event.buf].commentstring
		vim.bo[event.buf].commentstring = cs:gsub("(%S)%%s", "%1 %%s"):gsub("%%s(%S)", "%%s %1")
	end,
})

--- Opens the first found TODO (or README) file in the current directory.
---
--- @param in_split boolean  If true, open file in a vsplit; otherwise, open in current window.
--- @param or_readme boolean  If true, also consider README.md as a candidate file.
--- @param show_errors boolean  If true, notify user if no file is found.
function OpenTodo(in_split, or_readme, show_errors)
	local possible_files = {
		".todo",
		".todo.txt",
		".todo.md",
		"todo.txt",
		"todo.md",
		"TODO.txt",
		"TODO.md",
		"var/todo.txt",
		"var/todo.md",
	}
	if or_readme then
		table.insert(possible_files, "README.md")
	end

	for _, filename in ipairs(possible_files) do
		-- vim.print(filename)
		if vim.fn.filereadable(filename) == 1 then
			vim.cmd((in_split and "vsplit" or "edit") .. " " .. filename)
			return
		end
	end

	if show_errors then
		vim.notify("No TODO file found\n", vim.log.levels.ERROR)
	end
end

vim.keymap.set("n", "<leader>t", "<cmd>lua OpenTodo(true, false, true)<cr>", { silent = true })
vim.keymap.set("n", "<leader>T", "<cmd>vs ~/Documents/todo.md<cr>", { silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.defer_fn(function()
				OpenTodo(false, true, false)
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
				-- Ignore early writes until plugins are loaded so theme files cannot request package colorschemes before vim.pack adds them.
				if not vim.g.theme_reload_enabled then
					return
				end

				-- Load theme changes defensively so a bad theme edit reports an error without breaking startup.
				local ok, err_msg = pcall(dofile, file)
				if not ok then
					vim.notify("Error loading theme file: " .. err_msg, vim.log.levels.ERROR)
				end
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
local plugins = {
	{ src = "https://github.com/mechatroner/rainbow_csv" },
	{ src = "https://github.com/junegunn/vim-slash" }, -- Automatically remove search selection.
	{ src = "https://github.com/pappasam/papercolor-theme-slim" },
	{ src = "https://github.com/dhruvasagar/vim-table-mode" },
	{ src = "https://github.com/saecki/crates.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{
		-- Use the active branch because the frozen master branch crashes on Markdown highlighting in Nvim 0.12.
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/nativerv/cyrillic.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
}

-- Respect --noplugin by skipping package installation, loading, and plugin-specific setup when plugin loading is disabled.
local plugin_loading_enabled = vim.o.loadplugins

-- Keep event-loaded packages out of the eager vim.pack loader so their startup cost stays deferred.
local deferred_plugins = {
	["crates.nvim"] = true,
	["cyrillic.nvim"] = true,
}

if plugin_loading_enabled then
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			-- Recreate Lazy's build hooks for native packages so plugin installs and updates refresh their generated data.
			local kind = ev.data and ev.data.kind or nil
			local name = ev.data and ev.data.spec and ev.data.spec.name or nil
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "nvim-treesitter" then
				vim.schedule(function()
					-- Run nvim-treesitter's parser update after package changes so managed parsers stay compatible with the plugin.
					if pcall(vim.cmd, "packadd nvim-treesitter") then
						pcall(vim.cmd, "TSUpdate")
					end
				end)
			elseif name == "mason.nvim" and #vim.api.nvim_list_uis() > 0 then
				vim.schedule(function()
					-- Refresh Mason's registry after package changes so interactive installs use current package metadata.
					if pcall(vim.cmd, "packadd mason.nvim") then
						pcall(vim.cmd, "MasonUpdate")
					end
				end)
			end
		end,
	})

	-- Install missing plugins without an interactive prompt and load non-headless plugins immediately for the setup below.
	vim.pack.add(plugins, {
		confirm = false,
		load = function(plugin)
			-- Keep Mason managed by vim.pack but inactive in headless checks, matching the previous Lazy enabled guard.
			if plugin.spec.name == "mason.nvim" and #vim.api.nvim_list_uis() == 0 then
				return
			end

			-- Let explicit autocmds below load deferred packages only when their old Lazy events would have run.
			if deferred_plugins[plugin.spec.name] then
				return
			end

			-- Load every other native package immediately so explicit setup calls below can require plugin modules.
			vim.cmd.packadd(plugin.spec.name)
		end,
	})

	-- Load the configured colorscheme after vim.pack makes the theme package available.
	vim.cmd([[colorscheme PaperColorSlim]])

	-- Enable theme reloads after vim.pack loads colorscheme packages, then apply the current theme file once.
	vim.g.theme_reload_enabled = true
	local theme_file = vim.fn.expand("~/.config/nvim/theme.lua")
	if vim.fn.filereadable(theme_file) == 1 then
		-- Apply the user's persisted theme now that PaperColorSlim variants are on the runtime path.
		local ok, err_msg = pcall(dofile, theme_file)
		if not ok then
			vim.notify("Error loading theme file: " .. err_msg, vim.log.levels.ERROR)
		end
	end

	-- Configure table-mode's Markdown-compatible corner character before the plugin creates tables.
	vim.g.table_mode_corner = "|"

	-- Track crates.nvim setup so repeated Cargo.toml reads do not reconfigure the plugin.
	local crates_configured = false
	vim.api.nvim_create_autocmd("BufRead", {
		pattern = "Cargo.toml",
		callback = function()
			-- Load and configure crates.nvim when a Cargo manifest opens, preserving the previous Lazy BufRead event.
			if crates_configured then
				return
			end
			crates_configured = true
			vim.cmd.packadd("crates.nvim")
			require("crates").setup()
		end,
	})

	-- Configure Oil as the directory editor and expose the existing project drawer keymap.
	require("oil").setup({
		view_options = {
			show_hidden = true,
		},
	})
	vim.keymap.set("n", "<leader>d", ":Oil --preview<cr>", { silent = true })

	-- Configure Conform as the external formatter orchestrator for project filetypes.
	require("conform").setup({
		formatters_by_ft = {
			css = { "biome" },
			html = { "global_prettier" },
			javascript = { "biome", "biome-organize-imports" },
			json = { "biome" },
			jsonc = { "biome" },
			json5 = { "global_prettier" },
			lua = { "stylua" },
			markdown = function(bufnr)
				-- Skip injected formatting when markdown contains rust,ignore fenced blocks so Conform does not modify or drop ignored Rust examples.
				for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
					if line:match("^```%s*rust%s*,%s*ignore[%w_,%-]*%s*$") then
						return { "markdown_prettier" }
					end
				end
				return { "markdown_prettier", "injected" }
			end,
			python = { "ruff_format", "ruff_organize_imports" },
			-- rust `injected` breaks Maud templates.
			-- rust = { "rustfmt_nightly", "injected" },
			rust = { "rustfmt_nightly" },
			sh = { "shfmt" },
			sql = { "sleek" },
			toml = { "taplo" },
			vue = { "global_prettier" },
			yaml = { "global_prettier" },
		},
		formatters = {
			global_prettier = {
				command = "/usr/bin/nodejs",
				args = { "/usr/local/bin/prettier", "--stdin-filepath", "$FILENAME" },
				stdin = true,
			},
			taplo = {
				-- Mirror the buffer's effective indent settings so TOML format-on-save keeps following Neovim's .editorconfig values.
				args = function(_, ctx)
					-- Fall back to tabstop when shiftwidth is zero so Taplo still receives a concrete indentation width.
					local indent_width = ctx.shiftwidth > 0 and ctx.shiftwidth or vim.bo[ctx.buf].tabstop
					-- Build Taplo's indent string from the current buffer options so tabs and spaces both stay in sync with .editorconfig.
					local indent_string = vim.bo[ctx.buf].expandtab and string.rep(" ", indent_width) or "\t"
					return {
						"format",
						"--stdin-filepath",
						ctx.filename,
						"--option",
						"indent_string=" .. indent_string,
						"-",
					}
				end,
				stdin = true,
			},
			rustfmt_nightly = {
				-- Run rustfmt from nightly and enable pipefail so markdown code fences stay unchanged when rustfmt rejects a snippet.
				command = "sh",
				args = { "-o", "pipefail", "-c", "rustup run nightly rustfmt --emit stdout | dx fmt -f -" },
				stdin = true,
			},
			markdown_prettier = {
				command = "/usr/bin/nodejs",
				args = {
					"/usr/local/bin/prettier",
					-- Bypass .gitignore/.prettierignore path filtering so Markdown files still autoformat even when gitignored.
					"--ignore-path",
					"/dev/null",
					"--print-width",
					"80",
					"--prose-wrap",
					"always",
					"--stdin-filepath",
					"$FILENAME",
				},
				stdin = true,
			},
			sleek = {
				command = "sleek",
				stdin = true,
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})

	-- Configure Conform's injected language formatter map so fenced and embedded code keeps the same formatting behavior.
	require("conform").formatters.injected = {
		options = {
			ignore_errors = true,
			lang_to_formatters = {
				bash = { "shfmt" },
				css = { "biome" },
				html = { "global_prettier" },
				javascript = { "biome", "biome-organize-imports" },
				json = { "biome" },
				json5 = { "global_prettier" },
				lua = { "stylua" },
				python = { "ruff_format", "ruff_organize_imports" },
				rust = { "rustfmt_nightly" },
				sh = { "shfmt" },
				-- sql = { "sleek" },
				toml = { "taplo" },
				yaml = { "global_prettier" },
			},
		},
	}

	local treesitter = require("nvim-treesitter")

	-- Install parsers into Neovim's site directory so parser binaries are runtime data instead of files inside the plugin checkout.
	treesitter.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	-- Enable native Nvim Tree-sitter highlighting for filetypes whose parsers are managed by nvim-treesitter or bundled with Nvim.
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"css",
			"html",
			"javascript",
			"json",
			"json5",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"query",
			"rust",
			"scss",
			"sh",
			"sql",
			"svelte",
			"toml",
			"typescript",
			"vue",
			"yaml",
		},
		callback = function()
			-- Skip buffers whose parser is not installed yet so opening files stays error-free until :TSInstall/:TSUpdate provides it.
			if not pcall(vim.treesitter.start) then
				return
			end

			-- Preserve the previous Tree-sitter indentation behavior using the new nvim-treesitter indentation entry point.
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})

	local fzf_lua = require("fzf-lua")
	local actions = require("fzf-lua.actions")

	-- Configure fzf-lua to keep skim-backed file and grep pickers with tab-opening file actions.
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

	-- Map the main file finder to fzf-lua's files picker.
	vim.keymap.set("n", "<leader>f", function()
		fzf_lua.files()
	end, { silent = true, desc = "Find Files" })

	-- Map the notes finder to fzf-lua with the notes directory as its working tree.
	vim.keymap.set("n", "<leader>n", function()
		fzf_lua.files({ cwd = NOTES_ROOT })
	end, { silent = true, desc = "Find Notes" })

	-- Map live grep to fzf-lua's project text search picker.
	vim.keymap.set("n", "<leader>g", function()
		fzf_lua.live_grep()
	end, { silent = true, desc = "Live Grep" })

	-- Keep Fidget as the notification and LSP progress UI because native progress is not visible with this minimal statusline setup.
	require("fidget").setup()

	-- Defer Cyrillic keyboard helpers until after startup so the vim.pack migration keeps Lazy's VeryLazy timing.
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			-- Load Cyrillic keyboard helpers after startup to preserve Lazy's deferred VeryLazy timing.
			vim.cmd.packadd("cyrillic.nvim")
			require("cyrillic").setup({
				no_cyrillic_abbrev = false, -- default
			})
		end,
	})

	-- Configure Mason only for interactive sessions so headless checks do not start registry refreshes or installs.
	if #vim.api.nvim_list_uis() > 0 then
		require("mason").setup()

		local registry = require("mason-registry")

		-- List of packages to ensure are installed.
		-- List of all packages: https://mason-registry.dev/registry/list
		local ensure_installed = {
			"lua-language-server",
			"marksman",
			"typos-lsp",
		}

		local function ensure_packages_installed()
			-- Install configured Mason packages when missing so LSP dependencies self-heal during interactive startup.
			for _, pkg_name in ipairs(ensure_installed) do
				local pkg = registry.get_package(pkg_name)
				if not pkg:is_installed() then
					-- Schedule the installation so startup is not blocked by Mason package downloads.
					pkg:install():on("after_success", function()
						vim.notify(("Package '%s' installed successfully"):format(pkg_name), vim.log.levels.INFO)
					end)
				end
			end
		end

		-- Refresh the registry before installing packages so interactive startup still self-heals without throwing in restricted headless runs.
		registry.refresh(function(success)
			-- Skip automatic installs when the registry refresh fails because package metadata may be unavailable.
			if not success then
				return
			end
			ensure_packages_installed()
		end)
	end
end

-- Native LSP configuration uses ~/.config/nvim/lsp/*.lua files and does not require a plugin wrapper.
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = true,
})

-- Attach buffer-local LSP mappings whenever a native LSP client starts for a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local bufnr = ev.buf

		local function map(mode, lhs, rhs, opts)
			-- Apply a consistent buffer-local LSP mapping shape for every attached server.
			opts = opts or {}
			opts.buffer = bufnr
			opts.noremap = true
			opts.silent = true
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- LSP keybindings.
		map("n", "gD", vim.lsp.buf.declaration)
		map("n", "gd", vim.lsp.buf.definition)
		map("n", "gi", vim.lsp.buf.implementation)
		map("n", "<C-k>", vim.lsp.buf.signature_help)
		map("n", "<leader>D", vim.lsp.buf.type_definition)
		map("n", "<leader>r", vim.lsp.buf.rename)
		map("n", "<leader>a", vim.lsp.buf.code_action)
		map("n", "gr", vim.lsp.buf.references)
		map("n", "<leader>e", vim.diagnostic.open_float)
		map("n", "<leader>q", vim.diagnostic.setloclist)
		-- Use <leader>lf for LSP formatting to avoid clashing with file finder.
		map("n", "<leader>lf", function()
			vim.lsp.buf.format({ async = true })
		end)
	end,
})

-- Enable LSP servers using native configuration files from the lsp/ directory.
local servers = {
	"bashls",
	"biome",
	"denols",
	"lua_ls",
	"marksman",
	"ruff",
	"rust_analyzer",
	"typos_lsp",
	"vuels",
	-- "harper_ls",
}

for _, server in ipairs(servers) do
	-- Start each configured server through Nvim's native LSP manager instead of an LSP config plugin.
	vim.lsp.enable(server)
end
