return {
	cmd = { "ruff", "server", "--preview" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	single_file_support = true,
	settings = {
		-- Server settings can be configured here if needed
		-- See: https://github.com/astral-sh/ruff-lsp#settings
	},
}