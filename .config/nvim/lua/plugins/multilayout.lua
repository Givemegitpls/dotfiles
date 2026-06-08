return {
	-- Minimal configuration for russian layout using lazy.nvim
	{
		"mrsobakin/multilayout.nvim",
		opts = {
			layouts = {
				ru = "ru",
			},
			-- Enable if you want to have full multilayout.nvim functionality.
			use_libukb = false,
		},
	},
	{
		"Wansmer/langmapper.nvim",
		lazy = false,
		priority = 1, -- High priority is needed if you will use `autoremap()`
		-- check ui.lua/which-key

		-- config = function()
		-- 	require("langmapper").setup({--[[ your config ]]
		-- 	})
		-- end,
	},
}
