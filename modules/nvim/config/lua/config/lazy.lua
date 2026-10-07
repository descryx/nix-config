-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Initialize lazy.nvim and load plugins from lua/plugins/
require("lazy").setup({
	spec = {
		--1. lazyvim default plugns first
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- import your plugins here
		{ import = "plugins" },
	},
	checker = { enabled = true }, -- check for plugin updates
})
