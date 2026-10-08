-- simple keymap: save
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--local keymap = vim.keymap

--vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader><up>", "<cmd>%y+<cr>", { desc = "Yank entire buffer to +" })
vim.keymap.set("n", "<leader>q", function()
	vim.cmd("confirm quit")
end)

vim.keymap.set("v", "<leader>j", ":m '>+1<CR>gv=gv", { desc = "Move selected block down" })
vim.keymap.set("v", "<leader>k", ":m '<-2<CR>gv=gv", { desc = "Move selected block up" })
