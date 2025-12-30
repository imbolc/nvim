return {
	cmd = { "deno", "lsp" },
	filetypes = {
		"javascript",
	},
	root_markers = {
		"deno.jsonc",
		"deno.json",
		".git",
		"jsconfig.json",
		"import_map.json",
	},
	single_file_support = true,
	init_options = {
		enable = true,
		lint = true,
		unstable = false,
	},
	suggest = {
		autoImports = true,
		imports = {
			autoDiscover = true,
		},
	},
}
