-- source https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-877293306
local export = {}

local cached_path = nil
local cached_workspace = nil

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

	-- Delegate to shared script; pass file's directory as starting point.
	local dir = vim.fn.expand("%:p:h")
	local path = vim.fn.trim(vim.fn.system("python-venv-checker " .. vim.fn.shellescape(dir)))
	if path ~= "" and vim.fn.filereadable(path) == 1 then
		cached_path = path
		cached_workspace = workspace
		return cached_path
	end

	-- Fallback to system Python.
	cached_path = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
	return cached_path
end

return export
