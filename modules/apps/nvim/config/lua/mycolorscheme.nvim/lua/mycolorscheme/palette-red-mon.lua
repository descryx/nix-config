local M = {}

M.colors = {
	-- =============================================
	-- 1. BASE COLORS
	-- =============================================
	bg = "NONE",
	fg = "#f5f5f5",
	bg_dark = "#1a1a1a",
	bg_highlight = "#2a2a2a",
	cursorline = "#222222",

	-- =============================================
	-- 2. UI ELEMENTS
	-- =============================================
	comment = "#707070",
	linenr = "#4d4d4d",
	selection = "#333333",
	visual = "#333333",
	search = "#550000", -- dark, pure-red family — a deliberate spot of red
	statusline = "#1a1a1a",
	menu_bg = "#141414",
	menu_sel = "#3d3d3d",
	split = "#2a2a2a",

	-- =============================================
	-- 3. SYNTAX CORE
	-- =============================================
	keyword = "#ff0000", -- unchanged: this is the anchor of the theme
	func = "#ffffff",
	string = "#999999",
	constant = "#cccccc",
	type = "#b8b8b8",
	number = "#ee0000",
	boolean = "#bb0000", -- pure dark red — true/false pop like keywords do
	operator = "#ffffff",
	variable = "#cccccc",
	preproc = "#e6e6e6",

	-- =============================================
	-- 4. C++ / LANGUAGE SPECIFIC
	-- =============================================
	type_keyword = "#b8b8b8",
	namespace = "#999999",
	parameter = "#b3b3b3",
	property = "#c2c2c2",
	modifier = "#a3a3a3",
	macro = "#bb0000", -- pure dark red — preprocessor macros are rare, good accent
	constructor = "#e0e0e0",
	global = "#f0f0f0",
	bracket = "#bb0000",
	punctuation = "#b8b8b8",
	delimiter = "#b8b8b8",

	-- =============================================
	-- 5. DIAGNOSTICS
	-- =============================================
	error = "#ff0000",
	warn = "#858f3f",
	info = "#664490",
	hint = "#506070",
	git_add = "#4b824b",
	git_change = "#858f3f",
	git_delete = "#bb0000",

	-- =============================================
	-- 6. INDENT / WHITESPACE
	-- =============================================
	indent = "#ffffff",
	indent_context = "#777777",

	-- =============================================
	-- 7. EXTRA (calls, tags, markup, escapes)
	-- =============================================
	func_call = "#e0e0e0",
	method_call = "#e0e0e0",
	attribute = "#c2c2c2",
	escape = "#e6e6e6",
	regex = "#cccccc",
	url = "#a8a8a8",
	label = "#c2c2c2",
	heading = "#f5f5f5", -- stands out by brightness, not color
	link = "#a8a8a8",
	tag = "#cccccc",
	tag_delim = "#888888",
}

return M
