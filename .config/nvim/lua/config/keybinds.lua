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
vim.keymap.set("n", "<F5>", dap.continue, opts)
vim.keymap.set("n", "<s-F5>", dap.stop, opts)
vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, opts)

-- fugitive
vim.keymap.set("n", "<leader>p", "<CMD>Git pull --rebase<CR>")
vim.keymap.set("n", "<leader>P", "<CMD>Git push<CR>")

-- lsp
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
vim.keymap.set("n", "<C-i>", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

-- neotree
vim.keymap.set("n", "<F2>", "<CMD>Neotree toggle<CR>")

-- telescope
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, opts)
vim.keymap.set("n", "<leader>fg", telescope.live_grep, opts)
vim.keymap.set("n", "<leader>fb", telescope.buffers, opts)
vim.keymap.set("n", "<leader>fy", telescope.registers, opts)
