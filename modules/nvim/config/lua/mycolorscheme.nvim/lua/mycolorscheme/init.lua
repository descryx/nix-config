local M = {}

M.setup = function(opts)
	opts = opts or {}
	local palette = opts.palette or "red-mon" -- default is red-mon

	local colors
	if palette == "blue" then
		colors = require("mycolorscheme.palette-blue").colors
	elseif palette == "red" then
		-- colors = require("mycolorscheme.palette-red-mon").colors
		colors = require("mycolorscheme.palette-red").colors
	else
		-- colors = require("mycolorscheme.palette-red").colors
		colors = require("mycolorscheme.palette-red-mon").colors
	end

	require("mycolorscheme.groups").setup(colors)
end

return M
