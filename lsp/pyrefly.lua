return {
	-- Start Pyrefly as the Python type-checking LSP so Python buffers get Pyrefly diagnostics and language services.
	cmd = { "pyrefly", "lsp" },
	filetypes = { "python" },
	root_markers = {
		"pyrefly.toml",
		"pyproject.toml",
		".git",
	},
	single_file_support = true,
	settings = {
		python = {
			pyrefly = {
				-- Use the full default diagnostic set so ad hoc Python files can verify Pyrefly without a project config.
				typeCheckingMode = "default",
			},
		},
	},
}
