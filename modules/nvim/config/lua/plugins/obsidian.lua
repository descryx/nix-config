return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	event = { "BufReadPre *.md", "BufNewFile *.md" },
	cmd = { "Obsidian" }, -- catches all subcommands
	-- keys = {
	--   { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Obsidian backlinks" },
	--   { "<leader>od", "<cmd>Obsidian today<CR>", desc = "Obsidian daily note" },
	--   { "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Obsidian note links" },
	--   { "<leader>oo", "<cmd>Obsidian open<CR>", desc = "Open in Obsidian" },
	--   { "<leader>oq", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian quick switch" },
	--   { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Search Obsidian notes" },
	--   { "<leader>ot", "<cmd>Obsidian template<CR>", desc = "Insert Obsidian template" },
	--   { "<leader>oT", "<cmd>Obsidian toc<CR>", desc = "Obsidian table of contents" },
	-- },
	opts = {
		legacy_commands = false, -- silences the warning
		workspaces = {
			{
				name = "personal",
				path = "~/Projects",
			},
		},
	},
}
