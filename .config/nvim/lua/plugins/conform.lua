return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			-- Customize or remove this keymap to your liking
			"<leader>F",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	-- Everything in opts will be passed to setup()
	opts = {
		formatters = {
			mdformat_post = { command = "mdformat", args = { "--number", "--wrap", "100", "-" } },
		},
		-- Define your formatters
		formatters_by_ft = {
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			jsonc = { "prettierd" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			html = { "prettierd" },
			yml = { "prettierd" },
			css = { "prettierd" },
			python = { "ruff_fix", "ruff_format" },
			markdown = { "mdformat_post" },
			toml = { "tombi" },
			lua = { "stylua" },
			sh = { "shfmt" },
		},
		-- Set up format-on-save
		format_on_save = { timeout_ms = 500, lsp_fallback = true },
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
