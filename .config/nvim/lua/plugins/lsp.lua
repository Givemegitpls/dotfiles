return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.config("ruff", {})
		vim.lsp.enable("ruff")
		vim.lsp.config("basedpyright", {
			settings = {
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
		vim.lsp.config("lua_ls", {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = {
							"vim",
							"require",
						},
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
		vim.lsp.enable("lua_ls")
	end,
}
