return {
	-- 1. Install and configure yazi.nvim
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>-", "<cmd>Yazi<cr>", desc = "Open Yazi (File Tree Replacement)" },
		},
		opts = {
			open_for_directories = true,
		},
	},

	-- 2. Prevent Snacks from overriding your search keys
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				-- This keeps the picker enabled but prevents it from auto-binding over your custom Yazi keys
				explorer = false,
			},
		},
	},
}
