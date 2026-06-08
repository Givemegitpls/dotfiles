vim.cmd([[
  tnoremap <C-h> <C-\\><C-o><C-w>h
  tnoremap <C-k> <C-\\><C-o><C-w>k
  tnoremap <C-l> <C-\\><C-o><C-w>l
  tnoremap <C-j> <C-\\><C-o><C-w>j

  nnoremap <C-h> <C-w>h
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
  nnoremap <C-j> <C-w>j

  cnoremap <C-h> <Left>
  cnoremap <C-j> <Down>
  cnoremap <C-k> <Up>
  cnoremap <C-l> <Right>
  cnoremap <C-p> <C-r>"
]])

-- dap functions
local dap = require("dap")
local dapui = require("dapui")
local stacks = function()
	dapui.float_element("stacks")
end

local scopes = function()
	dapui.float_element("scopes")
end

-- fugitive functions
local telescope = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local fugitive_commits = function()
	telescope.git_commits({
		prompt_title = "Select File (Returns Path)",
		attach_mappings = function(prompt_bufnr, map)
			map({ "i", "n" }, "<CR>", function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				local selected = selection.value

				vim.cmd("Gvdiffsplit " .. selected .. " | wincmd L")
			end)
			return true -- Keep other default mappings working
		end,
	})
end

-- dap
vim.keymap.set("n", "<leader>dr", dap.continue, { desc = "Debug run" })
vim.keymap.set("n", "<leader>dR", dap.restart, { desc = "Debug restart" })
vim.keymap.set("n", "<leader>dc", dap.close, { desc = "Debug close" })
vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Debug eval" })
vim.keymap.set("n", "<leader>ds", stacks, { desc = "Debug stacks" })
vim.keymap.set("n", "<leader>dS", scopes, { desc = "Debug scopes" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug breakpoint" })
vim.keymap.set("n", "<leader>dB", dap.set_exception_breakpoints, { desc = "Debug exception breakpoint" })

-- fugitive
vim.keymap.set("n", "<leader>gp", "<CMD>Git pull --rebase<CR>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gP", "<CMD>Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gc", fugitive_commits, { desc = "Git diff" })

-- lsp
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go references" })
vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float, { desc = "Get diagnostic" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Display hover information" })

-- neotree
vim.keymap.set("n", "<F2>", "<CMD>Neotree toggle<CR>")

-- telescope
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Telescope grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fy", telescope.registers, { desc = "Telescope registers" })
