return {
	"nvim-tree/nvim-web-devicons",
	init = function()
		require("nvim-web-devicons").setup({
			override = {
				cpp = {
					icon = "", -- Your custom Nerd Font glyph
					color = "#ff2222", -- Your preferred color hex code
					--					color = "#519aba", -- Your preferred color hex code
					name = "Cpp",
				},
				hpp = {
					icon = "",
					color = "#519aba",
					name = "Hpp",
				},
			},
		})
	end,
}
