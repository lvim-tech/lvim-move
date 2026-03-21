local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")
local characters = require("lvim-move.move.characters")

local M = {}

local function normal_move(fn, with_indent)
	if not vim.o.modifiable then return end
	utils.cursor_position()
	local moved = fn("n")
	if with_indent and moved then
		vim.cmd("normal! ==")
	end
end

local function visual_move(line_fn, char_fn, with_indent)
	if not vim.o.modifiable then return end
	vim.cmd("silent! normal! gv")
	local mode = vim.api.nvim_get_mode().mode
	local moved
	if mode == "V" then
		moved = line_fn(mode)
	elseif mode == "v" then
		char_fn()
	end
	if with_indent and moved then
		vim.cmd("normal! ==")
		vim.cmd("normal! gv")
	end
	utils.apply_move_hl()
end

M.LvimMoveDownN  = function() normal_move(lines.down,  config.indent) end
M.LvimMoveUpN    = function() normal_move(lines.up,    config.indent) end
M.LvimMoveLeftN  = function() normal_move(lines.left,  false) end
M.LvimMoveRightN = function() normal_move(lines.right, false) end

M.LvimMoveDownV  = function() visual_move(lines.down,  characters.down,  config.indent) end
M.LvimMoveUpV    = function() visual_move(lines.up,    characters.up,    config.indent) end
M.LvimMoveLeftV  = function() visual_move(lines.left,  characters.left,  false) end
M.LvimMoveRightV = function() visual_move(lines.right, characters.right, false) end

return M
