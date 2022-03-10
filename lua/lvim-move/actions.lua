local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")

local M = {}
-- v       Visual by character
-- V       Visual by line
-- CTRL-V  Visual blockwise

M.LvimMoveDownN = function()
    utils.cursor_position()
    lines.down("n")
end

M.LvimMoveUpN = function()
    utils.cursor_position()
    lines.up("n")
end

M.LvimMoveLeftN = function()
    utils.cursor_position()
    lines.left("n")
end

M.LvimMoveRightN = function()
    utils.cursor_position()
    lines.right("n")
end

M.LvimMoveDownV = function()
    vim.cmd("normal! gv")
    utils.cursor_position()
    local mode = vim.fn.visualmode()
    if mode == "V" then
        lines.down(mode)
    end
end

M.LvimMoveUpV = function()
    vim.cmd("normal! gv")
    utils.cursor_position()
    local mode = vim.fn.visualmode()
    if mode == "V" then
        lines.up(mode)
    end
end

M.LvimMoveLeftV = function()
    vim.cmd("normal! gv")
    utils.cursor_position()
    local mode = vim.fn.visualmode()
    if mode == "V" then
        lines.left(mode)
    end
end

M.LvimMoveRightV = function()
    vim.cmd("normal! gv")
    utils.cursor_position()
    local mode = vim.fn.visualmode()
    if mode == "V" then
        lines.right(mode)
    end
end

return M
