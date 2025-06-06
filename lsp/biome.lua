return {
	cmd = { "/usr/bin/node", "/usr/local/bin/biome", "lsp-proxy" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"json",
		"jsonc",
	},
	root_markers = {
		"biome.json",
		"biome.jsonc",
		".biomejs.json",
		".biomejs.jsonc",
		"package.json",
		".git",
	},
	single_file_support = true,
}