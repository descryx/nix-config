pcall(function()
	require("config.diagnostics").setup()
end)

return {
	"neovim/nvim-lspconfig",
	opts = {
		inlay_hints = {
			enabled = false,
		},
		servers = {
			pyright = {},
			clangd = {
				mason = false,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					-- "--query-driver=/usr/bin/c++,/usr/bin/g++",
				},
				init_options = {
					fallbackFlags = { "-std=c++20" },
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						telemetry = { enable = false },
					},
				},
			},
		},
	},
}
