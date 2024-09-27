-- tree-sitter playground: triggering `BufWritePost`/`BufNewFile` in any .lua file
-- prints function name and its parameters

local ts = vim.treesitter
local parser = ts.get_parser(0, "lua")
local tree = parser:parse()[1]
local root = tree:root()

local function greet1(name)
	print("Hello, " .. name .. "!!!")
end

local function greet2(name, age)
	print("Hello, " .. name .. "! with " .. tostring(age))
end

local query = ts.query.parse(
	"lua",
	[[
(function_declaration
    name: (identifier) @func_name
    parameters: (parameters) @params)
]]
)

for id, node in query:iter_captures(root, 0) do
	local capture_name = query.captures[id] -- Capture name from query
	if capture_name == "func_name" then
		local func_name = ts.get_node_text(node, 0)
		print("Function name: ", func_name)
	elseif capture_name == "params" then
		local params = ts.get_node_text(node, 0)
		print("Parameters: ", params)
	end
end
