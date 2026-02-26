return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local tree = require("neo-tree")

		tree.setup({
			filesystem = {
				filtered_items = {
					visible = true, -- Show all hidden files
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
			document_symbols = {
				custom_kinds = {},
			},
			mapping_options = {
				noremap = true,
				nowait = true,
			},
			window = {
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
				},
			},
		})
	end,
}
