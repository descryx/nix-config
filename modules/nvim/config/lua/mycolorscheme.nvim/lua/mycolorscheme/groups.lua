local M = {}

M.setup = function(colors)
	local hl = vim.api.nvim_set_hl

	-- Safe accessor: falls back to an existing palette color instead of
	-- erroring or rendering unstyled if a key hasn't been added yet.
	-- Once you add the real key to your palette file, this just uses it.
	local function c(key, fallback)
		return colors[key] or fallback or colors.fg
	end

	-- Clear previous colors
	vim.cmd.hi("clear")
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = "mycolorscheme"

	-- ==================== Core / Legacy syntax ====================
	hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
	hl(0, "NormalFloat", { fg = colors.fg, bg = colors.bg })
	hl(0, "Comment", { fg = colors.comment, italic = true })
	hl(0, "String", { fg = colors.string })
	hl(0, "Character", { fg = colors.string })
	hl(0, "Number", { fg = colors.number })
	hl(0, "Boolean", { fg = colors.boolean })
	hl(0, "Float", { fg = colors.number })
	hl(0, "Keyword", { fg = colors.keyword })
	hl(0, "Operator", { fg = colors.operator })
	hl(0, "Identifier", { fg = colors.variable })
	hl(0, "Function", { fg = colors.func })
	hl(0, "Type", { fg = colors.type })
	hl(0, "Constant", { fg = colors.constant })
	hl(0, "PreProc", { fg = colors.preproc })
	hl(0, "Statement", { fg = colors.keyword })
	hl(0, "Special", { fg = c("escape", colors.operator) })
	hl(0, "Underlined", { fg = colors.func, underline = true })
	hl(0, "Title", { fg = c("heading", colors.keyword), bold = true })
	hl(0, "Todo", { fg = colors.bg, bg = colors.warn, bold = true })
	hl(0, "Error", { fg = colors.error, bold = true })

	-- ==================== Treesitter: variables / constants ====================
	hl(0, "@variable", { fg = colors.variable })
	hl(0, "@variable.builtin", { fg = colors.variable, italic = true })
	hl(0, "@variable.parameter", { fg = colors.parameter })
	hl(0, "@variable.parameter.builtin", { fg = colors.parameter, italic = true })
	hl(0, "@variable.member", { fg = colors.property })
	hl(0, "@constant", { fg = colors.constant })
	hl(0, "@constant.builtin", { fg = colors.constant, bold = true })
	hl(0, "@constant.macro", { fg = c("macro", colors.constant) })
	hl(0, "@module", { fg = colors.namespace })
	hl(0, "@module.builtin", { fg = colors.namespace, italic = true })
	hl(0, "@namespace", { fg = colors.namespace }) -- legacy alias
	hl(0, "@label", { fg = c("label", colors.constant) })

	-- ==================== Treesitter: strings / numbers ====================
	hl(0, "@string", { fg = colors.string })
	hl(0, "@string.documentation", { fg = colors.comment, italic = true })
	hl(0, "@string.regex", { fg = c("regex", colors.string) })
	hl(0, "@string.escape", { fg = c("escape", colors.operator), bold = true })
	hl(0, "@string.special", { fg = colors.string })
	hl(0, "@string.special.symbol", { fg = colors.constant })
	hl(0, "@string.special.url", { fg = c("url", colors.func), underline = true })
	hl(0, "@string.special.path", { fg = colors.string, underline = true })
	hl(0, "@character", { fg = colors.string })
	hl(0, "@character.special", { fg = c("escape", colors.operator) })
	hl(0, "@number", { fg = colors.number })
	hl(0, "@number.float", { fg = colors.number })
	hl(0, "@boolean", { fg = colors.boolean })

	-- ==================== Treesitter: types / attributes ====================
	hl(0, "@type", { fg = colors.type })
	hl(0, "@type.builtin", { fg = colors.type, italic = true })
	hl(0, "@type.definition", { fg = colors.type })
	hl(0, "@type.qualifier", { fg = colors.modifier }) -- const, static, etc
	hl(0, "@attribute", { fg = c("attribute", colors.modifier) })
	hl(0, "@attribute.builtin", { fg = c("attribute", colors.modifier), italic = true })
	hl(0, "@property", { fg = colors.property })
	hl(0, "@field", { fg = colors.property }) -- legacy alias

	-- ==================== Treesitter: functions ====================
	hl(0, "@function", { fg = colors.func })
	hl(0, "@function.builtin", { fg = colors.func, italic = true })
	hl(0, "@function.call", { fg = c("func_call", colors.func), bold = true })
	hl(0, "@function.macro", { fg = c("macro", colors.func) })
	hl(0, "@function.method", { fg = colors.func })
	hl(0, "@function.method.call", { fg = c("method_call", colors.func) })
	hl(0, "@constructor", { fg = colors.constructor })
	hl(0, "@operator", { fg = colors.operator })
	hl(0, "@parameter", { fg = colors.parameter }) -- legacy alias

	-- ==================== Treesitter: keywords ====================
	hl(0, "@keyword", { fg = colors.keyword })
	hl(0, "@keyword.coroutine", { fg = colors.keyword, italic = true })
	hl(0, "@keyword.function", { fg = colors.keyword })
	hl(0, "@keyword.operator", { fg = colors.operator })
	hl(0, "@keyword.import", { fg = colors.keyword, italic = true })
	hl(0, "@keyword.type", { fg = colors.type_keyword })
	hl(0, "@keyword.modifier", { fg = colors.modifier })
	hl(0, "@keyword.repeat", { fg = colors.keyword })
	hl(0, "@keyword.return", { fg = colors.keyword, bold = true })
	hl(0, "@keyword.debug", { fg = colors.warn })
	hl(0, "@keyword.exception", { fg = colors.keyword, bold = true })
	hl(0, "@keyword.conditional", { fg = colors.keyword })
	hl(0, "@keyword.conditional.ternary", { fg = colors.operator })
	hl(0, "@keyword.directive", { fg = colors.preproc })
	hl(0, "@keyword.directive.define", { fg = colors.preproc, bold = true })

	-- ==================== Treesitter: punctuation ====================
	hl(0, "@punctuation", { fg = colors.punctuation }) -- legacy alias
	hl(0, "@punctuation.delimiter", { fg = colors.delimiter })
	hl(0, "@punctuation.bracket", { fg = colors.bracket })
	hl(0, "@punctuation.special", { fg = c("escape", colors.operator) })

	-- ==================== Treesitter: comments ====================
	hl(0, "@comment", { fg = colors.comment, italic = true })
	hl(0, "@comment.documentation", { fg = colors.comment, italic = true })
	hl(0, "@comment.error", { fg = colors.error, bold = true })
	hl(0, "@comment.warning", { fg = colors.warn, bold = true })
	hl(0, "@comment.todo", { fg = colors.bg, bg = colors.warn, bold = true })
	hl(0, "@comment.note", { fg = colors.info, bold = true })

	-- ==================== Treesitter: markup (markdown, help, comments) ====================
	hl(0, "@markup.strong", { bold = true })
	hl(0, "@markup.italic", { italic = true })
	hl(0, "@markup.strikethrough", { strikethrough = true })
	hl(0, "@markup.underline", { underline = true })
	hl(0, "@markup.heading", { fg = c("heading", colors.keyword), bold = true })
	hl(0, "@markup.quote", { fg = colors.comment, italic = true })
	hl(0, "@markup.math", { fg = colors.number })
	hl(0, "@markup.link", { fg = c("link", colors.func) })
	hl(0, "@markup.link.label", { fg = c("link", colors.func), underline = true })
	hl(0, "@markup.link.url", { fg = c("url", colors.func), underline = true })
	hl(0, "@markup.raw", { fg = colors.string })
	hl(0, "@markup.raw.block", { fg = colors.string })
	hl(0, "@markup.list", { fg = colors.operator })
	hl(0, "@markup.list.checked", { fg = colors.git_add })
	hl(0, "@markup.list.unchecked", { fg = colors.comment })

	-- ==================== Treesitter: tags (html/xml/jsx/vue) ====================
	hl(0, "@tag", { fg = c("tag", colors.keyword) })
	hl(0, "@tag.builtin", { fg = c("tag", colors.keyword), italic = true })
	hl(0, "@tag.attribute", { fg = c("attribute", colors.parameter), italic = true })
	hl(0, "@tag.delimiter", { fg = c("tag_delim", colors.punctuation) })

	-- ==================== Treesitter: diff ====================
	hl(0, "@diff.plus", { fg = colors.git_add })
	hl(0, "@diff.minus", { fg = colors.git_delete })
	hl(0, "@diff.delta", { fg = colors.git_change })

	-- ==================== LSP Semantic Tokens (generic, all languages) ====================
	-- These generic groups cover every language's LSP; the .cpp-scoped ones
	-- below only apply on top of them for clangd specifically.
	hl(0, "@lsp.type.class", { link = "@type" })
	hl(0, "@lsp.type.decorator", { link = "@attribute" })
	hl(0, "@lsp.type.enum", { link = "@type" })
	hl(0, "@lsp.type.enumMember", { link = "@constant" })
	hl(0, "@lsp.type.function", { link = "@function" })
	hl(0, "@lsp.type.interface", { link = "@type" })
	hl(0, "@lsp.type.macro", { link = "@constant.macro" })
	hl(0, "@lsp.type.method", { link = "@function.method" })
	hl(0, "@lsp.type.namespace", { link = "@module" })
	hl(0, "@lsp.type.parameter", { link = "@variable.parameter" })
	hl(0, "@lsp.type.property", { link = "@property" })
	hl(0, "@lsp.type.struct", { link = "@type" })
	hl(0, "@lsp.type.type", { link = "@type" })
	hl(0, "@lsp.type.typeParameter", { link = "@type.definition" })
	hl(0, "@lsp.type.variable", { link = "@variable" })

	-- LSP Semantic Tokens (C++-specific overrides, kept from your original)
	hl(0, "@lsp.type.macro.cpp", { fg = colors.macro })
	hl(0, "@lsp.typemod.variable.globalScope.cpp", { fg = colors.global })

	-- ==================== Diagnostics & UI ====================
	hl(0, "DiagnosticError", { fg = colors.error })
	hl(0, "DiagnosticWarn", { fg = colors.warn })
	hl(0, "DiagnosticInfo", { fg = colors.info })
	hl(0, "DiagnosticHint", { fg = colors.hint })

	hl(0, "CursorLine", { bg = colors.cursorline })
	hl(0, "Visual", { bg = colors.visual })
	hl(0, "Search", { bg = colors.search, fg = colors.bg })
	hl(0, "IncSearch", { bg = colors.search, fg = colors.bg })

	hl(0, "LineNr", { fg = colors.linenr })
	hl(0, "CursorLineNr", { fg = colors.fg, bold = true })
	hl(0, "StatusLine", { fg = colors.fg, bg = colors.statusline })
	hl(0, "WinSeparator", { fg = colors.split })

	-- Popup menus (completion, etc.) — previously undefined
	hl(0, "Pmenu", { fg = colors.fg, bg = colors.menu_bg })
	hl(0, "PmenuSel", { fg = colors.fg, bg = colors.menu_sel })
	hl(0, "PmenuSbar", { bg = colors.menu_bg })
	hl(0, "PmenuThumb", { bg = colors.menu_sel })

	-- Snacks Dashboard Highlight Definitions
	hl(0, "SnacksDashboardHeader", { fg = colors.keyword, bold = true })
	hl(0, "SnacksDashboardFile", { fg = colors.func })
	hl(0, "SnacksDashboardDesc", { fg = colors.fg })
	hl(0, "SnacksDashboardIcon", { fg = colors.fg })
	hl(0, "SnacksDashboardKey", { fg = colors.keyword, bold = true })
	hl(0, "SnacksDashboardFooter", { fg = colors.keyword, italic = true })
	hl(0, "ErrorMsg", { fg = colors.error, bold = true })

	-- git
	hl(0, "GitSignsAdd", { fg = colors.git_add, bg = "NONE" })
	hl(0, "GitSignsChange", { fg = colors.git_change, bg = "NONE" })
	hl(0, "GitSignsDelete", { fg = colors.git_delete, bg = "NONE" })
	hl(0, "GitSignsAddLn", { bg = "NONE" })
	hl(0, "GitSignsChangeLn", { bg = "NONE" })
	hl(0, "GitSignsDeleteLn", { bg = "NONE" })

	-- ==================== snacks.indentscope ====================
	hl(0, "SnacksIndent", { fg = colors.indent_context })
	hl(0, "SnacksIndentScope", { fg = colors.indent })
end

return M
