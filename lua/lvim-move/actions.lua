local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")
local characters = require("lvim-move.move.characters")

local M = {}
-- v        Visual by character
-- V        Visual by line
-- ^V       Visual blockwise

M.LvimMoveDownN = function()
	if vim.o.modifiable then
		utils.cursor_position()
		lines.down("n")
		if config.maps then
			vim.cmd("silent! normal! ==")
		end
	end
end

M.LvimMoveUpN = function()
	if vim.o.modifiable then
		utils.cursor_position()
		lines.up("n")
		if config.maps then
			vim.cmd("silent! normal! ==")
		end
	end
end

M.LvimMoveLeftN = function()
	if vim.o.modifiable then
		utils.cursor_position()
		lines.left("n")
	end
end

M.LvimMoveRightN = function()
	if vim.o.modifiable then
		vim.notify("Right")
		utils.cursor_position()
		lines.right("n")
	end
end

M.LvimMoveDownV = function()
	if vim.o.modifiable then
		vim.cmd("silent! normal! gv")
		utils.cursor_position()
		local mode = vim.api.nvim_get_mode()["mode"]
		vim.notify(mode)
		if mode == "V" then
			lines.down(mode)
			if config.maps then
				vim.cmd("silent! normal! ==")
			end
		elseif mode == "v" then
			characters.down()
		elseif mode == "CTRL-V" then
		end
	end
end

M.LvimMoveUpV = function()
	if vim.o.modifiable then
		vim.cmd("silent! normal! gv")
		utils.cursor_position()
		local mode = vim.api.nvim_get_mode()["mode"]
		if mode == "V" then
			lines.up(mode)
			if config.maps then
				vim.cmd("silent! normal! ==")
			end
		elseif mode == "v" then
			characters.up()
		end
	end
end

M.LvimMoveLeftV = function()
	if vim.o.modifiable then
		vim.cmd("silent! normal! gv")
		utils.cursor_position()
		local mode = vim.api.nvim_get_mode()["mode"]
		if mode == "V" then
			lines.left(mode)
		elseif mode == "v" then
			characters.left()
		end
	end
end

M.LvimMoveRightV = function()
	if vim.o.modifiable then
		vim.cmd("silent! normal! gv")
		utils.cursor_position()
		local mode = vim.api.nvim_get_mode()["mode"]
		if mode == "V" then
			lines.right(mode)
		elseif mode == "v" then
			characters.right()
		end
	end
end

return M
