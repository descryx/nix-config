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
	search = "#444477",
	statusline = "#222222",
	menu_bg = "#1a1a1a",
	menu_sel = "#555555",
	split = "#333333",

	-- =============================================
	-- 3. SYNTAX CORE
	-- =============================================
	keyword = "#0066ff",
	func = "#2288ff",
	string = "#ffffff",
	constant = "#c4c4d7",
	type = "#bdbdcf",
	number = "#e7e7f3",
	boolean = "#9f9fb8",
	operator = "#0044cc",
	variable = "#babacc",
	preproc = "#5d7fff",

	-- =============================================
	-- 4. C++ / LANGUAGE SPECIFIC
	-- =============================================
	type_keyword = "#0055e6",
	namespace = "#969696",
	parameter = "#9d9db1",
	property = "#bcbcd4",
	modifier = "#a8a8ca",
	macro = "#003dff",
	constructor = "#acacc6",
	global = "#ffffff",
	bracket = "#ffffff",
	punctuation = "#b8b8b8",
	delimiter = "#b8b8b8",

	-- =============================================
	-- 5. DIAGNOSTICS
	-- =============================================
	-- error        = "#0055ff",
	-- warn         = "#40a0c4",
	-- info         = "#6090aa",
	-- hint         = "#50a050",
	-- git_add      = "#3070aa",
	-- git_change   = "#66aadd",
	-- git_delete   = "#0044ff",

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
	-- 7. EXTRA
	-- =============================================
	func_call = "#4499ff",
	method_call = "#4499ff",
	attribute = "#8888e0",
	escape = "#00aaff",
	regex = "#47b3ff",
	url = "#88aaff",
	label = "#c4c4d7",
	heading = "#5555ff",
	link = "#88aaff",
	tag = "#6666ff",
	tag_delim = "#999999",
}
return M
