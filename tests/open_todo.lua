-- Run from the repository root: vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/open_todo.lua
-- Load only the todo function so this check needs no plugins or personal configuration.
local source = table.concat(vim.fn.readfile("init.lua"), "\n")
assert(loadstring(assert(source:match("\nfunction OpenTodo%(.-\nend\n"))))()

-- Simulate directories and readable files without creating or opening personal todo files.
local test_home = vim.fn.tempname() .. "/home.[test]"
local projects = test_home .. "/proj/"
local cwd, probes, notifications
local readable = { ["todo.md"] = true, ["README.md"] = true }
vim.fn.expand = function(path)
	return (path:gsub("^~", function()
		return test_home
	end))
end
vim.fn.getcwd = function()
	return cwd
end
vim.fn.filereadable = function(path)
	probes = probes + 1
	return readable[path] and 1 or 0
end
-- Model existing targets separately from readability checks for local fallback files.
vim.fn.getftype = function(path)
	return readable[path] and "file" or ""
end
vim.notify = function(message, level)
	table.insert(notifications, { message, level })
end

-- Exercise real edit/split commands to catch escaping mistakes and unintended fallback buffers.
local function check(directory, expected, in_split, or_readme, show_errors)
	vim.cmd("silent! only")
	vim.cmd("enew")
	cwd, probes, notifications = directory, 0, {}
	OpenTodo(in_split, or_readme, show_errors)
	local path = expected and vim.fn.fnamemodify(expected, ":p") or ""
	assert(vim.api.nvim_buf_get_name(0) == path, "Unexpected todo path for " .. directory)
	assert(#vim.api.nvim_list_wins() == (in_split and expected and 2 or 1), "Unexpected split")
end

-- Project roots and nested paths must open a missing target without checking local alternatives.
check(projects .. "demo", projects .. "todo/demo.md", false, true, false)
assert(probes == 0 and #notifications == 0)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "# demo todo" }))
assert(vim.bo.modified, "A new todo header must remain unsaved")

-- Reopening an unsaved todo must preserve its header and any edits already made.
vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "- Keep this unsaved task" })
check(projects .. "demo/src/lib", projects .. "todo/demo.md", true, false, true)
assert(probes == 0 and #notifications == 0)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "# demo todo", "", "- Keep this unsaved task" }))
check(projects .. "space #100% [todo]|name/src", projects .. "todo/space #100% [todo]|name.md", false, true, true)
assert(probes == 0 and #notifications == 0)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "# space #100% [todo]|name todo" }))

-- Existing empty files and existing content must not receive a generated header.
readable[projects .. "todo/existing.md"] = true
check(projects .. "existing", projects .. "todo/existing.md", false, true, false)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "" }) and not vim.bo.modified)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Existing project notes" })
vim.bo.modified = false
check(projects .. "existing/src", projects .. "todo/existing.md", true, false, true)
assert(
	vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "Existing project notes" }) and not vim.bo.modified
)

-- Outside projects, preserve TODO priority, optional README lookup, and error visibility.
check(test_home .. "/outside", "todo.md", true, true, true)
assert(#notifications == 0)
readable = { ["README.md"] = true }
check(test_home .. "/proj", "README.md", false, true, false)
check(test_home .. "/proj-other/demo", "README.md", false, true, false)
check(test_home .. "/outside", nil, false, false, false)
assert(#notifications == 0)
check(test_home .. "/outside", nil, true, false, true)
assert(#notifications == 1 and notifications[1][2] == vim.log.levels.ERROR)

print("OpenTodo regression check passed")
