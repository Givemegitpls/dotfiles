return {
	{
		"mfussenegger/nvim-dap",
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
	{
		"mfussenegger/nvim-dap-python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},

		config = function()
			local python_utils = require("functions.python")
			local python_path = python_utils.get_python_path()
			require("dap-python").setup(python_path)
		end,
	},
}
