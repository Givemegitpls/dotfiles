-- source https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-877293306
local export = {}

local cached_path = nil
local cached_workspace = nil

local function shorten_path(workspace)
	if not workspace or #workspace <= 1 then
		return workspace or "/"
	end

	local last_slash = workspace:match(".*/()")

	if last_slash and last_slash > 1 then
		return workspace:sub(1, last_slash - 2)
	else
		return "/"
	end
end

local function check_poetry(workspace)
	local match = vim.fn.glob(vim.fs.joinpath(workspace, "poetry.lock"))
	if match ~= "" then
		vim.api.nvim_set_current_dir(workspace)
		local venv = vim.fn.trim(vim.fn.system("poetry  env info -p 2> /dev/null"))
		if venv ~= "" then
			return vim.fs.joinpath(venv, "bin", "python")
		end
	end
	return ""
end

local function check_venv(workspace)
	local match = vim.fn.glob(vim.fs.joinpath(workspace, ".venv"))
	if match ~= "" then
		vim.api.nvim_set_current_dir(workspace)
		return vim.fs.joinpath(match, "bin", "python")
	end
	return ""
end

function export.get_python_path()
	local workspace = vim.fn.expand("%:p")
	if cached_path and cached_workspace and workspace:find(cached_workspace, 1, true) == 1 then
		return cached_path
	end
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		cached_path = vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
		return cached_path
	end

	-- Find and use virtualenv via poetry in workspace directory.
	if workspace ~= "" then
		cached_workspace = workspace
		while workspace ~= "" do
			local poetry = check_poetry(workspace)
			if poetry ~= "" then
				cached_path = poetry
				return cached_path
			end
			local venv = check_venv(workspace)
			if venv ~= "" then
				cached_path = venv
				return cached_path
			end
			workspace = shorten_path(workspace)
		end
	end

	-- Fallback to system Python.
	cached_path = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
	return cached_path
end

return export
