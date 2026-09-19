-- Run from the repository root with the Rust Tree-sitter parser installed:
-- vim --appimage-extract-and-run --headless -u NONE -i NONE -l tests/sql_injections.lua
-- Check both string forms for every supported sqlx macro, including the SQL language metadata.
local query =
	vim.treesitter.query.parse("rust", table.concat(vim.fn.readfile("after/queries/rust/injections.scm"), "\n"))
local lines, expected = { "fn main() {" }, {}
for _, name in ipairs({
	"query",
	"query_as",
	"query_as_unchecked",
	"query_scalar",
	"query_scalar_unchecked",
	"query_unchecked",
}) do
	for _, literal in ipairs({ '"%s"', 'r"%s"', 'r#"%s"#' }) do
		local sql = "SELECT '" .. name .. "'"
		table.insert(lines, "sqlx::" .. name .. "!(" .. literal:format(sql) .. ");")
		table.insert(expected, sql)
	end
end

-- Similar names, other namespaces, and ordinary strings must not receive this injection.
table.insert(lines, [[other::query!("SELECT 1"); sqlx::query_extra!(r"SELECT 2"); sqlx::execute!("SELECT 3");]])
table.insert(lines, [[let plain = "SELECT 4"; }]])
local source = table.concat(lines, "\n")
local parser = vim.treesitter.get_string_parser(source, "rust")
local tree = parser:parse()[1]
local actual = {}
for id, node, metadata in query:iter_captures(tree:root(), source) do
	if query.captures[id] == "injection.content" then
		assert(metadata["injection.language"] == "sql", "Unexpected injection language")
		table.insert(actual, vim.treesitter.get_node_text(node, source))
	end
end
assert(vim.deep_equal(actual, expected), "SQL injections missed a string form or matched an unrelated macro")

print("SQL injection regression check passed")
