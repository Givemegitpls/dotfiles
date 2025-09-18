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

		require("lspconfig").ruff.setup({
			settings = { interpreter = python_path },
		})
		require("lspconfig").basedpyright.setup({
			settings = {
				python = { pythonPath = python_path },
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
