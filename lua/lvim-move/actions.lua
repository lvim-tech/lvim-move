-- lvim-move.actions: the eight public move actions, one per direction × mode, bound by init.set_maps and also
-- callable directly (require("lvim-move.actions").LvimMoveDownN() …). Each wraps a move.lines / move.characters
-- primitive with the shared pre/post steps: guard a non-modifiable buffer, capture the cursor column, optional
-- auto-indent, and (visual) the moving highlight. The visual `V` vs `v` split routes linewise moves to
-- move.lines and charwise moves to move.characters.
--
---@module "lvim-move.actions"

local config = require("lvim-move.config")
local state = require("lvim-move.state")
local utils = require("lvim-move.utils")
local lines = require("lvim-move.move.lines")
local characters = require("lvim-move.move.characters")

local api = vim.api
local fn = vim.fn

local M = {}

--- Run a NORMAL-mode line move: capture the column, move, then optionally re-indent the moved line.
---@param move_fn fun(mode: "n"|"V"): boolean|nil  a move.lines primitive; returns true when it actually moved a line
---@param with_indent boolean                      re-indent (`==`) after a successful vertical move
---@return nil
local function normal_move(move_fn, with_indent)
    if not vim.bo.modifiable then
        return
    end
    -- A count (`3<A-j>`) repeats the move that many lines / indent steps. `v:count1` is 1 with no count;
    -- capture it before any `normal!` below resets it. Boundary iterations are harmless no-ops.
    for _ = 1, vim.v.count1 do
        utils.cursor_position()
        local moved = move_fn("n")
        if with_indent and moved then
            -- The primitive left the cursor on the moved line at the preserved column; a bare `==` would jump
            -- it to first-non-blank, discarding that column (the plugin's advertised "cursor-column
            -- preserving"). So re-apply the column AFTER the reindent, shifted by the indent delta so it stays
            -- over the SAME character. undojoin folds the `==` into the move's own undo block (one `u` reverts).
            local row = api.nvim_win_get_cursor(0)[1]
            local indent_before = fn.indent(row)
            pcall(vim.cmd, "undojoin")
            vim.cmd("normal! ==")
            local indent_after = fn.indent(row)
            local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
            local col = math.max(0, (state.column - 1) + (indent_after - indent_before))
            api.nvim_win_set_cursor(0, { row, math.min(col, #line) })
        end
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
    -- A count (`2<A-j>`) repeats the block move that many steps. Between iterations we leave visual mode with
    -- `<Esc>` so the `'<`/`'>` marks COMMIT to the freshly re-selected block — otherwise the next `gv` would
    -- restore the stale pre-move selection. The final iteration stays in visual (as the single-move path does).
    local count = vim.v.count1
    local mode, moved
    for i = 1, count do
        vim.cmd("silent! normal! gv")
        mode = vim.api.nvim_get_mode().mode
        if mode == "V" then
            moved = line_fn(mode)
        elseif mode == "v" then
            char_fn()
        end
        if i < count then
            vim.cmd("normal! \27")
        end
    end
    if with_indent and moved then
        pcall(vim.cmd, "undojoin")
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
