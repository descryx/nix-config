local M = {}
M.colors = {
	-- =============================================
	-- 1. BASE COLORS
	-- =============================================
	bg = "NONE",
	fg = "#f5f5f5",
	bg_dark = "#222222",
	bg_highlight = "#444444",
	cursorline = "#333333",
	-- =============================================
	-- 2. UI ELEMENTS
	-- =============================================
	comment = "#888888",
	linenr = "#666666",
	selection = "#444444",
	visual = "#444444",
	search = "#774444",
	statusline = "#222222",
	menu_bg = "#1a1a1a",
	menu_sel = "#555555",
	split = "#333333",
	-- =============================================
	-- 3. SYNTAX CORE
	-- =============================================
	keyword = "#ff0000",
	func = "#ff7722",
	string = "#ffffff",
	constant = "#d7c4c4",
	type = "#cfbdbd",
	number = "#f3e7e7",
	boolean = "#b89f9f",
	operator = "#cc0000",
	variable = "#ccbaba",
	preproc = "#ff5d7f",

	-- =============================================
	-- 4. C++ / LANGUAGE SPECIFIC
	-- =============================================
	type_keyword = "#e60000",
	namespace = "#969696",
	parameter = "#b19d9d",
	property = "#d4bcbc",
	modifier = "#caa8a8",
	macro = "#ff003d",
	constructor = "#c6acac",
	global = "#ffffff",
	bracket = "#ffffff",
	punctuation = "#b8b8b8",
	delimiter = "#b8b8b8", -- was #999999

	-- =============================================
	-- 5. DIAGNOSTICS
	-- =============================================
	error = "#ff0055",
	warn = "#c49a40",
	info = "#6090aa",
	hint = "#50a050",
	git_add = "#3070aa",
	git_change = "#dd66aa",
	git_delete = "#ff0000",

	-- =============================================
	-- 6. INDENT / WHITESPACE
	-- =============================================
	indent = "#ffffff",
	indent_context = "#777777",

	-- =============================================
	-- 7. EXTRA (calls, tags, markup, escapes)
	-- =============================================
	func_call = "#ff9944", -- slightly lighter than func, for call-site highlighting
	method_call = "#ff9944",
	attribute = "#e08888", -- decorators / annotations (@decorator, #[derive])
	escape = "#ffaa00", -- \n \t etc inside strings
	regex = "#ffb347", -- regex literals
	url = "#88aaff", -- markdown/comment URLs
	label = "#d7c4c4", -- JSON keys / goto labels
	heading = "#ff5555", -- markdown headings / Title
	link = "#88aaff", -- markdown link text
	tag = "#ff6666", -- html/jsx tag names
	tag_delim = "#999999", -- < > / in tags
}
return M
