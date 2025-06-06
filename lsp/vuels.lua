return {
	cmd = { "/usr/bin/node", "/usr/local/bin/vls" },
	filetypes = { "vue" },
	root_markers = {
		"package.json",
		"vue.config.js",
		"nuxt.config.js",
		"nuxt.config.ts",
		"vite.config.js",
		"vite.config.ts",
		".git",
	},
	single_file_support = true,
	init_options = {
		config = {
			css = {},
			emmet = {},
			html = {
				suggest = {},
			},
			javascript = {
				format = {},
			},
			stylusSupremacy = {},
			typescript = {
				format = {},
			},
			vetur = {
				completion = {
					autoImport = false,
					tagCasing = "kebab",
					useScaffoldSnippets = true,
				},
				format = {
					defaultFormatter = {},
					defaultFormatterOptions = {},
					scriptInitialIndent = false,
					styleInitialIndent = false,
				},
				useWorkspaceDependencies = false,
				validation = {
					script = true,
					style = true,
					template = true,
				},
			},
		},
	},
}