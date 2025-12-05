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
	end,
}
