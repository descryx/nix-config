require("config.keymaps")
-- require("config.diagnostics")
--
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = function()
		require("config.options")
	end,
})

require("config.lazy")
