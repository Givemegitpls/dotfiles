return {
	{
		"mfussenegger/nvim-dap",
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup({ ---@diagnostic disable-line: missing-fields
				layouts = {
					{
						elements = {
							{ id = "console", size = 1 },
						},
						position = "bottom",
						size = 10,
					},
				},
				floating = {
					border = "rounded",
					mappings = {
						["close"] = { "q", "<Esc>" },
					},
				},
			})
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},

		config = function()
			require("dap-python").setup()

			local dap = require("dap")
			table.insert(dap.configurations.python, 1, {
				type = "python",
				request = "launch",
				name = "file (project root)",
				program = "${file}",
				console = "integratedTerminal",
				cwd = vim.fn.getcwd(),
				args = {},
			})
		end,
	},
}
