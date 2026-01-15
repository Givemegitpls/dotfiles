return {
	"neovim/nvim-lspconfig",
	config = function()
		local python_utils = require("functions.python")
		local python_path = python_utils.get_python_path()

		vim.lsp.config("ruff", {
			settings = { interpreter = python_path },
		})
		vim.lsp.enable("ruff")
		vim.lsp.config("basedpyright", {
			settings = {
				python = { pythonPath = python_path },
				basedpyright = {
					analysis = {
						diagnosticMode = "workspace",
						typeCheckingMode = "strict",
					},
				},
			},
		})
		vim.lsp.enable("basedpyright")
		vim.lsp.config("bashls", {
			cmd = { "bash-language-server", "start" },
			filetypes = { "bash", "sh" },
		})
		vim.lsp.enable("bashls")
		vim.lsp.config("tombi", {
			cmd = { "tombi", "lsp" },
			filetypes = { "toml" },
		})
		vim.lsp.enable("tombi")
	end,
}
