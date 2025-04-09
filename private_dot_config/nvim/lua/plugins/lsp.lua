return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts)
		vim.keymap.set("n", "gr", function()
			vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "<C-i>", function()
			vim.diagnostic.open_float()
		end, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, opts)

		local util = require("lspconfig/util")
		local path = util.path

		-- source https://github.com/neovim/nvim-lspconfig/issues/500#issuecomment-877293306
		local function get_python_path(workspace)
			workspace = workspace or ""
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
			end

			-- Find and use virtualenv via poetry in workspace directory.
			if workspace ~= "" then
				local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
				if match ~= "" then
					local venv = vim.fn.trim(vim.fn.system("poetry env info -p 2> /dev/null"))
					if venv ~= "" then
						return path.join(venv, "bin", "python")
					end
				end
			end

			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		require("lspconfig").ruff.setup({
			before_init = function(_, config)
				config.settings.interpreter = get_python_path(config.root_dir)
			end,
		})
		require("lspconfig").basedpyright.setup({
			before_init = function(_, config)
				config.settings.python.pythonPath = get_python_path(config.root_dir)
			end,
			settings = {
				python = {},
				basedpyright = {
					analysis = {
						typeCheckingMode = "strict",
					},
				},
			},
		})
		require("lspconfig").bashls.setup({
			cmd = { "bash-language-server", "start" },
			filetypes = { "bash", "sh" },
		})
	end,
}
