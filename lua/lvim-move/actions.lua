local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")

local M = {}
-- v       Visual by character
-- V       Visual by line
-- CTRL-V  Visual blockwise

M.LvimMoveDownN = function()
    if vim.o.modifiable then
        utils.cursor_position()
        lines.down("n")
    end
end

M.LvimMoveUpN = function()
    if vim.o.modifiable then
        utils.cursor_position()
        lines.up("n")
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
        utils.cursor_position()
        lines.right("n")
    end
end

M.LvimMoveDownV = function()
    if vim.o.modifiable then
        vim.cmd("normal! gv")
        utils.cursor_position()
        local mode = vim.fn.visualmode()
        if mode == "V" then
            lines.down(mode)
        end
    end
end

M.LvimMoveUpV = function()
    if vim.o.modifiable then
        vim.cmd("normal! gv")
        utils.cursor_position()
        local mode = vim.fn.visualmode()
        if mode == "V" then
            lines.up(mode)
        end
    end
end

M.LvimMoveLeftV = function()
    if vim.o.modifiable then
        vim.cmd("normal! gv")
        utils.cursor_position()
        local mode = vim.fn.visualmode()
        if mode == "V" then
            lines.left(mode)
        end
    end
end

M.LvimMoveRightV = function()
    if vim.o.modifiable then
        vim.cmd("normal! gv")
        utils.cursor_position()
        local mode = vim.fn.visualmode()
        if mode == "V" then
            lines.right(mode)
        end
    end
end

return M
