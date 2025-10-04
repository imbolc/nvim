return {
	cmd = { "deno", "lsp" },
	filetypes = {
		"javascript",
	},
	root_markers = {
		"deno.json",
		"deno.jsonc",
		"import_map.json",
		"jsconfig.json",
	},
	single_file_support = true,
	init_options = {
		enable = true,
		lint = true,
		unstable = false,
	},
}
