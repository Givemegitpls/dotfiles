vim.cmd([[
  tnoremap <C-h> <C-\\><C-o><C-w>h
  tnoremap <C-k> <C-\\><C-o><C-w>k
  tnoremap <C-l> <C-\\><C-o><C-w>l
  tnoremap <C-j> <C-\\><C-o><C-w>j

  nnoremap <C-h> <C-w>h
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
  nnoremap <C-j> <C-w>j
]])

-- dap
local dap = require("dap")
vim.keymap.set("n", "<leader>dr", dap.continue, { desc = "Dap run" })
vim.keymap.set("n", "<leader>ds", dap.stop, { desc = "Dap stop" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Dap breakpoint" })

-- fugitive
vim.keymap.set("n", "<leader>p", "<CMD>Git pull --rebase<CR>")
vim.keymap.set("n", "<leader>P", "<CMD>Git push<CR>")

-- lsp
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go references" })
vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float, { desc = "Get diagnostic" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Display hover information" })

-- neotree
vim.keymap.set("n", "<F2>", "<CMD>Neotree toggle<CR>")

-- telescope
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Telescope grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fy", telescope.registers, { desc = "Telescope registers" })
