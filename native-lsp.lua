-- Use with: vim --clean -u ~/.config/nvim/native-lsp.lua

-- Colorscheme
vim.opt.termguicolors = true
vim.opt.background = "light"

local function lsp_map(buf_num)
	local opts = { noremap = true, silent = true }
	local function map(...)
		vim.api.nvim_buf_set_keymap(buf_num, ...)
	end
	map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	map("n", "<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	map("n", "<space>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	map("n", "<space>q", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)
	map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		local client = vim.lsp.start({
			name = "rust-analyzer",
			cmd = { "rust-analyzer" },
			root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true })[1]),
		})
		vim.lsp.buf_attach_client(0, client)
		lsp_map(0)
	end,
})
