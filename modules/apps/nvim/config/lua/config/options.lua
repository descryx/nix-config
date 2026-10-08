vim.opt.termguicolors = true

-- basic usability
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.statuscolumn = ""

vim.opt.colorcolumn = "100"

vim.opt.clipboard = "unnamedplus" -- makes nvim comunicate with system clipboard

vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.scrolloff = 18
vim.opt.sidescrolloff = 0

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.autoformat = true
-- vim.g.lazyvim_inlay_hints = false

-- Disable the built-in netrw explorer completely
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo" -- outside the repo
vim.opt.undofile = true
vim.fn.mkdir(vim.fn.stdpath("state") .. "/undo", "p")
