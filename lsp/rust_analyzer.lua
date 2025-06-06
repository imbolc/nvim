return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = {
		"Cargo.toml",
		"rust-project.json",
		".git",
	},
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
}