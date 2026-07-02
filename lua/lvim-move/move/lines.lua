-- lvim-move.move.lines: the LINEWISE move primitives (up / down / left / right), each handling both normal
-- ("n") and linewise-visual ("V") mode. Vertical moves swap whole lines with nvim_buf_set_lines and restore the
-- saved cursor column (lvim-move.state); horizontal moves delegate to `<<` / `>>` (indent). Every direction is
-- FOLD-AWARE: on a closed fold it opens the fold (`zv`) instead of moving. Visual moves re-select the block by
-- explicit line numbers (reselect_block) rather than the '< / '> marks, which are unreliable after
-- nvim_win_set_cursor.
--
---@module "lvim-move.move.lines"

local state = require("lvim-move.state")

local api = vim.api
local fn = vim.fn

local M = {}

--- Re-assert a linewise visual selection at explicit line numbers (marks are unreliable post-cursor-move).
---@param new_start integer  first line (1-based)
---@param new_end integer    last line (1-based)
local function reselect_block(new_start, new_end)
    vim.cmd("normal! \27\27")
    vim.cmd("normal! " .. new_start .. "ggV" .. new_end .. "gg")
end

--- Move the current line / selected block DOWN one line.
---@param mode "n"|"V"
---@return boolean|nil moved  true when a line/block actually moved (nil on a fold / at the last line)
M.down = function(mode)
    if mode == "n" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        local last_line = fn.line("$")
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        elseif current_line < last_line then
            local two = api.nvim_buf_get_lines(0, current_line - 1, current_line + 1, false)
            api.nvim_buf_set_lines(0, current_line - 1, current_line + 1, false, { two[2], two[1] })
            api.nvim_win_set_cursor(0, { current_line + 1, state.column - 1 })
            return true
        end
    elseif mode == "V" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        local last_line = fn.line("$")
        local start_line = fn.getpos("'<")[2]
        local end_line = fn.getpos("'>")[2]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        elseif end_line < last_line then
            local vSRow = start_line - 1
            local vERow = end_line
            local lines_buf = api.nvim_buf_get_lines(0, vSRow, vERow + 1, false)
            local below = table.remove(lines_buf)
            table.insert(lines_buf, 1, below)
            api.nvim_buf_set_lines(0, vSRow, vERow + 1, false, lines_buf)
            reselect_block(start_line + 1, end_line + 1)
            return true
        end
    end
end

--- Move the current line / selected block UP one line.
---@param mode "n"|"V"
---@return boolean|nil moved  true when a line/block actually moved (nil on a fold / at the first line)
M.up = function(mode)
    if mode == "n" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        elseif current_line > 1 then
            local two = api.nvim_buf_get_lines(0, current_line - 2, current_line, false)
            api.nvim_buf_set_lines(0, current_line - 2, current_line, false, { two[2], two[1] })
            api.nvim_win_set_cursor(0, { current_line - 1, state.column - 1 })
            return true
        end
    elseif mode == "V" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        local start_line = fn.getpos("'<")[2]
        local end_line = fn.getpos("'>")[2]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        elseif start_line > 1 then
            local vSRow = start_line - 1
            local vERow = end_line
            local lines_buf = api.nvim_buf_get_lines(0, vSRow - 1, vERow, false)
            local above = table.remove(lines_buf, 1)
            table.insert(lines_buf, above)
            api.nvim_buf_set_lines(0, vSRow - 1, vERow, false, lines_buf)
            reselect_block(start_line - 1, end_line - 1)
            return true
        end
    end
end

--- Dedent the current line / selected block (move LEFT).
---@param mode "n"|"V"
---@return nil
M.left = function(mode)
    if mode == "n" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        else
            vim.cmd("normal! <<")
            local col = math.max(1, state.column - fn.shiftwidth())
            api.nvim_win_set_cursor(0, { current_line, col - 1 })
        end
    elseif mode == "V" then
        local start_line = fn.getpos("'<")[2]
        local end_line = fn.getpos("'>")[2]
        local current_line = api.nvim_win_get_cursor(0)[1]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        else
            vim.cmd("normal! <")
            reselect_block(start_line, end_line)
        end
    end
end

--- Indent the current line / selected block (move RIGHT).
---@param mode "n"|"V"
---@return nil
M.right = function(mode)
    if mode == "n" then
        local current_line = api.nvim_win_get_cursor(0)[1]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        else
            vim.cmd("normal! >>")
            api.nvim_win_set_cursor(0, { current_line, (state.column - 1) + fn.shiftwidth() })
        end
    elseif mode == "V" then
        local start_line = fn.getpos("'<")[2]
        local end_line = fn.getpos("'>")[2]
        local current_line = api.nvim_win_get_cursor(0)[1]
        if fn.foldclosed(current_line) > -1 then
            vim.cmd("silent! normal! zv")
        else
            vim.cmd("normal! >")
            reselect_block(start_line, end_line)
        end
    end
end

return M
