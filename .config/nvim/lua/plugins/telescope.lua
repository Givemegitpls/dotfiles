return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local builtin = require("telescope.actions")

		-- vibecoded thing, that make me happy
		local function feedkeys(keys)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
		end

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
				mappings = {
					i = {
						["<C-h>"] = function()
							feedkeys("<Left>")
						end,
						["<C-l>"] = function()
							feedkeys("<Right>")
						end,
						["<C-p>"] = function()
							feedkeys('<C-r>"')
						end,
						["<C-k>"] = builtin.move_selection_previous,
						["<C-j>"] = builtin.move_selection_next,
						["<S-Up>"] = builtin.preview_scrolling_up,
						["<S-Down>"] = builtin.preview_scrolling_down,
						["<S-Left>"] = builtin.preview_scrolling_left,
						["<S-Right>"] = builtin.preview_scrolling_right,
					},
					n = {
						["<C-h>"] = builtin.move_selection_previous,
						["<C-l>"] = builtin.move_selection_next,
						["<C-k>"] = builtin.move_selection_previous,
						["<C-j>"] = builtin.move_selection_next,
					},
				},
			},
		})
	end,
}
