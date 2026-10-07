-- -- plugins/colorscheme.lua
--
-- return {
-- 	-- Tell LazyVim to use your colorscheme
-- 	{
-- 		"LazyVim/LazyVim",
-- 		opts = {
-- 			colorscheme = "mycolorscheme",
-- 		},
-- 	},
--
-- 	-- Load your local colorscheme
-- 	{
-- 		dir = "~/nix-config/modules/nvim/config/lua/mycolorscheme.nvim",
-- 		name = "mycolorscheme",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			vim.cmd.colorscheme("mycolorscheme")
-- 		end,
-- 	},
-- }

-- plugins/colorscheme.lua

return {
	-- Tell LazyVim to use your colorscheme
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "mycolorscheme-red-mon",
		},
	},

	-- Load your local colorscheme
	{
		dir = "~/.config/nvim/lua/mycolorscheme.nvim",
		name = "mycolorscheme-red-mon",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("mycolorscheme-red-mon")
		end,
	},

	-- Install koda.nvim
	{
		"oskarnurm/koda.nvim",
		-- lazy = false,
		priority = 1000,
		config = function()
			require("koda").setup({
				transparent = true, -- enables transparent background

				colors = {
					const = "#aa0000", -- placeholder — see note below on the exact key name
				},
				on_highlights = function(hl, c)
					hl.GitSignsAdd = { fg = "#0066ff" }
					hl.GitSignsChange = { fg = "#ff66cc" }
					hl.GitSignsDelete = { fg = "#ff0000" }
				end,
			})
			-- vim.cmd("colorscheme koda")
		end,
	},

	-- Install lackluster.nvim too, so it's available even if koda is default
	{
		"slugbyte/lackluster.nvim",
		lazy = false,
		priority = 1000,
	},
}
