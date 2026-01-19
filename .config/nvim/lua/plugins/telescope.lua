return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("telescope").setup({
			pickers = {
				-- Optional: also show hidden files in find_files
				find_files = {
					hidden = true,
				},
			},
			defaults = {
				-- Configure live_grep and grep_string to include hidden files
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- Add this flag
				},
			},
		})
	end,
}
