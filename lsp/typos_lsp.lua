return {
	cmd = { "typos-lsp" },
	filetypes = {
		"text",
		"markdown",
		"gitcommit",
		"lua",
		"python",
		"rust",
		"javascript",
		"typescript",
		"html",
		"css",
		"json",
		"yaml",
		"toml",
		"sh",
		"bash",
		"vim",
	},
	root_markers = {
		"typos.toml",
		".typos.toml",
		"_typos.toml",
		"pyproject.toml",
		"Cargo.toml",
		"package.json",
		".git",
	},
	single_file_support = true,
	settings = {
		-- Typos LSP settings can be configured here
		-- See: https://github.com/tekumara/typos-lsp#configuration
	},
}