return {
	"romus204/tree-sitter-manager.nvim",
	dependencies = {}, -- tree-sitter CLI must be installed system-wide
	config = function()
		require("tree-sitter-manager").setup({ ---@diagnostic disable-line: missing-fields
			ensure_installed = {
				"lua",
				"python",
				"yaml",
				"markdown",
				"bash",
				"toml",
			},

			sync_install = false,
			auto_install = false,

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
