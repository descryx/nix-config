return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- Adds nice file icons
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto", -- Automatically matches your current Neovim colorscheme
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" }, -- The cool powerline triangles
			},
		})
	end,
}
