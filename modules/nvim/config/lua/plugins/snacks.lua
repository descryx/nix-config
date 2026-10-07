return {
	"folke/snacks.nvim",
	opts = {
		scroll = { enabled = false },
		indent = {
			scope = {
				enabled = true,
				treesitter = {
					enabled = true,
					blocks = {
						enabled = true,
						"function_declaration",
						"function_definition",
						"if_statement",
						"for_statement",
						"while_statement",
						"class_definition",
						"class_specifier",
						"struct_specifier",
						"namespace_definition",
					},
				},
			},
		},
		dashboard = {
			-- 1. Define your preset parameters (Header & Keys)
			preset = {
				pick = function(cmd, opts)
					return LazyVim.pick(cmd, opts)()
				end,
				header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
--          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          -- { icon = " ", key = "s", desc = "Restore Session", action = ":lua Snacks.dashboard.resume()" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
			},
			-- 2. Arrange how the elements render on screen
			sections = {
				{ section = "header" }, -- Pulls your custom header from above
				{
					text = {
						{ "(◑.◑)", hl = "ErrorMsg" },
					},
					align = "center",
					padding = 1,
				},
				{ section = "keys", gap = 1, padding = 1 }, -- Pulls your custom keys from above
				{ section = "startup" }, -- Shows startup benchmark stats
			},
		},
	},
}
