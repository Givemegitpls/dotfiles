return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local tree = require("neo-tree")
		local command = require("neo-tree.command")

		tree.setup({
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
		vim.keymap.set("n", "<F2>", "<CMD>Neotree toggle<CR>")
	end,
}
