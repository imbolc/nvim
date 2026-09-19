-- Run from the repository root: vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/lsp_defaults.lua
-- Exercise native LSP startup with an in-process server so no language server installation is needed.
local servers = { "bashls", "biome", "denols", "marksman", "ruff", "typos_lsp", "vuels" }
local project = vim.fn.getcwd()
-- Keep rootless buffers outside existing home or temporary-directory project markers, without creating files.
local standalone = "/nvim-lsp-standalone-" .. vim.uv.os_getpid()
-- Isolate test logging from the user's persistent LSP log.
vim.lsp.log._set_filename(vim.fn.tempname())

local function check(name, directory, workspace_required, expected_root)
	local config = dofile("lsp/" .. name .. ".lua")
	local initialized, opened, closed
	if workspace_required then
		config.workspace_required = true
	end
	-- Fix the project root so unrelated marker files in ancestor directories cannot affect this defaults check.
	if expected_root then
		config.root_dir = expected_root
	end
	-- Use the native initialization and attachment lifecycle with a minimal server transport.
	config.cmd = function(dispatchers)
		local function stop()
			closed = true
			dispatchers.on_exit(0, 0)
		end
		return {
			request = function(method, params, reply)
				assert(method == "initialize" or method == "shutdown", "Unexpected LSP request: " .. method)
				if method == "initialize" then
					initialized = params
				end
				vim.schedule(function()
					reply(nil, method == "initialize" and { capabilities = { textDocumentSync = 1 } } or nil)
				end)
				return true, 1
			end,
			notify = function(method)
				if method == "textDocument/didOpen" then
					opened = true
				elseif method == "exit" then
					stop()
				end
				return true
			end,
			is_closing = function()
				return closed or false
			end,
			terminate = stop,
		}
	end

	-- Named buffers exercise startup without writing test files to disk.
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, directory .. "/" .. name)
	vim.bo[buf].filetype = config.filetypes[1]
	vim.lsp.config[name] = config
	vim.lsp.enable(name)
	vim.api.nvim_exec_autocmds("FileType", { buffer = buf })

	if workspace_required and not expected_root then
		assert(not initialized, name .. " started without its required workspace")
		assert(#vim.lsp.get_clients({ bufnr = buf }) == 0, name .. " attached without a workspace")
	else
		assert(
			vim.wait(1000, function()
				return opened
			end),
			name .. " did not open the buffer"
		)
		local client = assert(vim.lsp.get_clients({ bufnr = buf, name = name })[1])
		assert(client.root_dir == expected_root, name .. " resolved an unexpected root")
		assert(initialized.rootUri == (expected_root and vim.uri_from_fname(expected_root) or vim.NIL))
		-- Both omitted and explicit empty settings must produce the same usable client settings.
		if name == "ruff" or name == "typos_lsp" then
			assert(vim.deep_equal(client.settings, {}), name .. " should have empty settings")
		end
		client:stop(true)
	end
	vim.lsp.enable(name, false)
	vim.api.nvim_buf_delete(buf, { force = true })
end

-- Standalone files work by default; requiring a workspace blocks them but still permits project files.
for _, name in ipairs(servers) do
	check(name, standalone, nil, nil)
	check(name, standalone, true, nil)
	check(name, project, true, project)
end

print("Native LSP defaults regression check passed")
