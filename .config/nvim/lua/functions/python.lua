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

local function check_poetry(path, workspace)
	local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
	if match ~= "" then
		vim.api.nvim_set_current_dir(workspace)
		local venv = vim.fn.trim(vim.fn.system("poetry  env info -p 2> /dev/null"))
		if venv ~= "" then
			return path.join(venv, "bin", "python")
		end
	end
	return ""
end

local function check_venv(path, workspace)
	local match = vim.fn.glob(path.join(workspace, ".venv"))
	if match ~= "" then
		vim.api.nvim_set_current_dir(workspace)
		return path.join(match, "bin", "python")
	end
	return ""
end

function export.get_python_path()
	local util = require("lspconfig/util")
	local path = util.path

	workspace = vim.fn.expand("%:p")
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
	end

	-- Find and use virtualenv via poetry in workspace directory.
	if workspace ~= "" then
		while workspace ~= "" do
			local poetry = check_poetry(path, workspace)
			if poetry ~= "" then
				return poetry
			end
			local venv = check_venv(path, workspace)
			if venv ~= "" then
				return venv
			end
			workspace = shorten_path(workspace)
		end
	end

	-- Fallback to system Python.
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return export
