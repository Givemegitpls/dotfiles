-- completion engine plugin for neovim
return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
	},
	config = function()
		local cmp = require("cmp")
		cmp.setup({
			mapping = {
				["<A-d>"] = cmp.mapping(function(fallback)
					if cmp.visible_docs() then
						cmp.close_docs()
					elseif cmp.visible() then
						cmp.open_docs()
					else
						fallback()
					end
				end),
				["<A-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
				["<A-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
				["<C-Space>"] = cmp.mapping.complete(),
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
			},
			snippet = {
				expand = function(args)
					vim.snippet.expand(args.body)
				end,
			},
			sources = { { name = "nvim_lsp" }, { name = "buffer" } },
		})
	end,
}
