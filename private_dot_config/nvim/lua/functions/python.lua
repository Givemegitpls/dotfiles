-- source https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-877293306
local export = {}

local function shorten_path(path)
	if not path or #path <= 1 then
		return path or "/"
	end

	local last_slash = path:match(".*/()")

	if last_slash and last_slash > 1 then
		return path:sub(1, last_slash - 2)
	else
		return "/"
	end
end

function export.get_python_path()
	local util = require("lspconfig/util")
	local path = util.path
	workspace = vim.loop.cwd()
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
	end

	-- Find and use virtualenv via poetry in workspace directory.
	while workspace ~= "/" do
		if workspace ~= "" then
			local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
			if match ~= "" then
				local venv = vim.fn.trim(vim.fn.system("poetry env info -p 2> /dev/null"))
				if venv ~= "" then
					return path.join(venv, "bin", "python")
				end
			end
		end
		workspace = shorten_path(workspace)
	end

	-- Fallback to system Python.
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return export
