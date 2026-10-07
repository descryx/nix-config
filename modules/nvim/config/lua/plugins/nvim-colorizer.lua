-- lua/plugins/colorizer.lua
return {
	"NvChad/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		user_default_options = {
			filetypes = { "*" }, -- every filetype, including plain config files
			mode = "background", -- or "foreground" / "virtualtext"
		},
	},
}
