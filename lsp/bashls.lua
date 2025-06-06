return {
	cmd = { "/usr/bin/node", "/usr/local/bin/bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = {
		".git",
		".bashrc",
		".bash_profile",
		"*.sh",
	},
	single_file_support = true,
}