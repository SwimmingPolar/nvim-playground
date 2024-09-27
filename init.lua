local _, plenary = pcall(function()
	return require("plenary")
end)
if plenary == nil then
	pcall(function()
		vim.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", "plenary" }, { text = true }):wait()
	end)
end

-- add current dir to runtimepath
vim.opt.rtp:append(".")
vim.opt.rtp:append("plenary")

vim.api.nvim_create_autocmd({ "BufWritePost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("neovim_api_playground", { clear = true }),
	pattern = { "*.lua" },
	desc = "Neovim API Playground",
	callback = function()
		-- CLEAR MESSAGES
		vim.cmd([[silent! messages clear]])

		local ok, err = pcall(function()
			local lua_files = {}
			local function scan_dir(dir)
				local handle = vim.uv.fs_scandir(dir)
				if not handle then
					return
				end

				while true do
					local fname, type = vim.uv.fs_scandir_next(handle)
					if not fname then
						break
					end

					local abs_fname = dir .. "/" .. fname

					if type == "file" and fname:match("%.lua$") then
						table.insert(lua_files, abs_fname)
					elseif type == "directory" then
						scan_dir(dir .. "/" .. fname)
					end
				end
			end

			-- SCAN for .lua files
			local scan_ok, scan_err = pcall(function()
				scan_dir("./lua")
			end)
			if not scan_ok then
				vim.api.nvim_err_writeln("Error scanning dir: " .. scan_err)
			end

			-- SOURCE all .lua files
			for _, fname in ipairs(lua_files) do
				local source_ok, source_err = pcall(function()
					vim.cmd("runtime " .. fname)
				end)
				if not source_ok then
					vim.api.nvim_err_writeln("Error sourcing file: " .. source_err)
				end
			end
		end)
		if not ok then
			return vim.api.nvim_err_writeln(err and err or "Unknow Error")
		end

		-- SHOW messages
		vim.cmd([[messages | redraw]])
	end,
})
