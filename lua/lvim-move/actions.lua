-- lvim-move.actions: the eight public move actions, one per direction × mode, bound by init.set_maps and also
-- callable directly (require("lvim-move.actions").LvimMoveDownN() …). Each wraps a move.lines / move.characters
-- primitive with the shared pre/post steps: guard a non-modifiable buffer, capture the cursor column, optional
-- auto-indent, and (visual) the moving highlight. The visual `V` vs `v` split routes linewise moves to
-- move.lines and charwise moves to move.characters.
--
---@module "lvim-move.actions"

local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")
local characters = require("lvim-move.move.characters")

local M = {}

--- Run a NORMAL-mode line move: capture the column, move, then optionally re-indent the moved line.
---@param fn fun(mode: "n"|"V"): boolean|nil  a move.lines primitive; returns true when it actually moved a line
---@param with_indent boolean                 re-indent (`==`) after a successful vertical move
---@return nil
local function normal_move(fn, with_indent)
    if not vim.bo.modifiable then
        return
    end
    utils.cursor_position()
    local moved = fn("n")
    if with_indent and moved then
        vim.cmd("normal! ==")
    end
end

--- Run a VISUAL-mode move: re-assert the selection, dispatch by kind (linewise `V` → line_fn, charwise `v` →
--- char_fn), optionally re-indent + re-select, then apply the moving highlight.
---@param line_fn fun(mode: "n"|"V"): boolean|nil  the linewise (move.lines) primitive
---@param char_fn fun()                             the charwise (move.characters) primitive
---@param with_indent boolean                       re-indent (`==`) after a successful linewise move
---@return nil
local function visual_move(line_fn, char_fn, with_indent)
    if not vim.bo.modifiable then
        return
    end
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

--- Move the current line down (normal mode).
---@return nil
M.LvimMoveDownN = function()
    normal_move(lines.down, config.indent)
end
--- Move the current line up (normal mode).
---@return nil
M.LvimMoveUpN = function()
    normal_move(lines.up, config.indent)
end
--- Dedent the current line (normal mode).
---@return nil
M.LvimMoveLeftN = function()
    normal_move(lines.left, false)
end
--- Indent the current line (normal mode).
---@return nil
M.LvimMoveRightN = function()
    normal_move(lines.right, false)
end

--- Move the selection down (visual mode: linewise block / charwise chars).
---@return nil
M.LvimMoveDownV = function()
    visual_move(lines.down, characters.down, config.indent)
end
--- Move the selection up (visual mode: linewise block / charwise chars).
---@return nil
M.LvimMoveUpV = function()
    visual_move(lines.up, characters.up, config.indent)
end
--- Dedent the selection / move the selected chars left (visual mode).
---@return nil
M.LvimMoveLeftV = function()
    visual_move(lines.left, characters.left, false)
end
--- Indent the selection / move the selected chars right (visual mode).
---@return nil
M.LvimMoveRightV = function()
    visual_move(lines.right, characters.right, false)
end

return M
