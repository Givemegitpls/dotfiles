return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"python",
				"yaml",
				"markdown",
				"bash",
			},

			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			incremental_selection = {
				enable = true,
				disable = {},
				keymaps = {
					init_selection = false,
					node_incremental = false,
					scope_incremental = false,
					node_decremental = false,
				},
			},
		})
	end,
}
