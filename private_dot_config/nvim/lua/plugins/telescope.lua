return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"gbprod/yanky.nvim",
	},
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, opts)
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts)
		vim.keymap.set("n", "<leader>fb", builtin.buffers, opts)

		require("yanky").setup()
		require("telescope").load_extension("yank_history")
		vim.keymap.set("n", "<leader>fy", function()
			vim.cmd.Telescope("yank_history")
		end, opts)
	end,
}
