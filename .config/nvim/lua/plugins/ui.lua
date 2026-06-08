return {
	-- main theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto", -- latte, frappe, macchiato, mocha
				integrations = {
					notify = true,
					noice = true,
				},
				transparent_background = true,
				float = {
					transparent = true, -- enable transparent floating windows
					solid = false, -- use solid styling for floating windows, see |winborder|
				},
			})

			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
	-- statusbar
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({ ---@diagnostic disable-line: undefined-field
				sections = {
					lualine_c = {
						{
							"filename",
							file_status = true, -- Displays file status (readonly status, modified status)
							newfile_status = false, -- Display new file status (new file means no write after created)
							path = 1, -- 0: Just the filename

							shorting_target = 40, -- Shortens path to leave 40 spaces in the window
							symbols = {
								modified = "[+]", -- Text to show when the file is modified.
								readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
								unnamed = "[No Name]", -- Text to show for unnamed buffers.
								newfile = "[New]", -- Text to show for newly created file before first write
							},
						},
					},
				},
			})
		end,
	},
	-- git helper
	{
		"akinsho/git-conflict.nvim",
		config = function()
			local git = require("git-conflict")
			git.setup({
				default_mappings = true, -- disable buffer local mapping created by this plugin
				default_commands = true, -- disable commands created by this plugin
				disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
				list_opener = "copen", -- command or function to open the conflicts list
				highlights = { -- They must have background color, otherwise the default color will be used
					incoming = "DiffAdd",
					current = "DiffText",
				},
			})
		end,
	},
	-- tree branch visualizer
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup()
		end,
	},
	-- markdown renderer
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },

		config = function()
			-- disabling wrapping for better tables rendering
			vim.api.nvim_create_autocmd({ "ModeChanged", "BufReadPost" }, {
				pattern = "*",
				callback = function()
					if vim.api.nvim_get_mode().mode == "n" and vim.bo.filetype == "markdown" then
						vim.cmd("setlocal nowrap")
						vim.cmd("highlight @string.escape guifg=#000000")
					else
						vim.cmd("setlocal wrap")
						vim.cmd("highlight @string.escape NONE")
					end
				end,
			})

			require("render-markdown").setup({
				enable = false,
				pipe_table = {
					preset = "round",
					cell = "trimmed",
				},
			})
		end,
	},
	{
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			processor = "magick_cli",
		},
		config = function()
			require("image").setup({
				integrations = {
					markdown = {
						resolve_image_path = function(document_path, image_path, fallback)
							return fallback(document_path, image_path)
						end,
					},
				},
			})
		end,
	},
	-- Keybind helper
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
		},
		-- setup deduplicated binds
		config = function(_, opts)
			local lmu = require("langmapper.utils")
			local wk_state = require("which-key.state")
			local check_orig = wk_state.check

			wk_state.check = function(state, key)
				if key ~= nil then
					key = lmu.translate_keycode(key, "default", "ru")
				end
				return check_orig(state, key)
			end
			require("which-key").setup(opts)
		end,
	},
	-- New UI
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				background_colour = "#000000",
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline", -- can be cmdline or cmdline_popup
				format = {
					cmdline = { pattern = "^:", icon = ":", lang = "vim" },
				},
			},
			-- add any options here
			presets = { lsp_doc_border = true },
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
}
