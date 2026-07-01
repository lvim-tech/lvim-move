-- lvim-move.move.characters: the CHARWISE move primitives (up / down / left / right) for a charwise-visual
-- ("v") selection WITHIN a single line. up/down move the selected text to the same column on the adjacent line
-- (clamped to that line's length); left/right swap the selection with its neighbouring character. Multi-line
-- charwise selections are ignored (get_selection returns nil). Each move rewrites the line(s) with
-- nvim_buf_set_lines and re-selects the moved text by explicit column (reselect_char).
--
---@module "lvim-move.move.characters"

local api = vim.api
local fn = vim.fn

local M = {}

--- Re-assert a charwise visual selection at explicit byte columns (marks are unreliable post-edit).
---@param line_nr integer   line (1-based)
---@param start_col integer selection start column (1-based)
---@param end_col integer   selection end column (1-based, inclusive)
local function reselect_char(line_nr, start_col, end_col)
    vim.cmd("normal! \27\27")
    vim.cmd("normal! " .. line_nr .. "gg" .. start_col .. "|v" .. end_col .. "|")
end

--- Resolve the current charwise selection to a single-line span.
---@return integer|nil line_nr  1-based line, or nil when the selection spans multiple lines
---@return integer? start_col   selection start column (1-based)
---@return integer? end_col     selection end column (1-based, inclusive)
local function get_selection()
    local s = fn.getcharpos("'<")
    local e = fn.getcharpos("'>")
    if s[2] ~= e[2] then
        return nil -- ignore multi-line character selections
    end
    return s[2], s[3], e[3] -- line_nr, start_col, end_col
end

--- Move the selected chars DOWN to the same column on the next line (clamped to its length).
M.down = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or line_nr >= fn.line("$") then
        return
    end

    local two_lines = api.nvim_buf_get_lines(0, line_nr - 1, line_nr + 1, false)
    local cur_line, next_line = two_lines[1], two_lines[2]
    local selected = cur_line:sub(start_col, end_col)

    local new_cur = cur_line:sub(1, start_col - 1) .. cur_line:sub(end_col + 1)
    local ins = math.min(start_col - 1, #next_line)
    local new_next = next_line:sub(1, ins) .. selected .. next_line:sub(ins + 1)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr + 1, false, { new_cur, new_next })
    reselect_char(line_nr + 1, ins + 1, ins + #selected)
end

--- Move the selected chars UP to the same column on the previous line (clamped to its length).
M.up = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or line_nr <= 1 then
        return
    end

    local two_lines = api.nvim_buf_get_lines(0, line_nr - 2, line_nr, false)
    local prev_line, cur_line = two_lines[1], two_lines[2]
    local selected = cur_line:sub(start_col, end_col)

    local new_cur = cur_line:sub(1, start_col - 1) .. cur_line:sub(end_col + 1)
    local ins = math.min(start_col - 1, #prev_line)
    local new_prev = prev_line:sub(1, ins) .. selected .. prev_line:sub(ins + 1)

    api.nvim_buf_set_lines(0, line_nr - 2, line_nr, false, { new_prev, new_cur })
    reselect_char(line_nr - 1, ins + 1, ins + #selected)
end

--- Swap the selected chars with the single character to their LEFT.
M.left = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or start_col <= 1 then
        return
    end

    local line = api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
    local before = line:sub(start_col - 1, start_col - 1)
    local selected = line:sub(start_col, end_col)
    local new_line = line:sub(1, start_col - 2) .. selected .. before .. line:sub(end_col + 1)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
    reselect_char(line_nr, start_col - 1, end_col - 1)
end

--- Swap the selected chars with the single character to their RIGHT.
M.right = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr then
        return
    end
    local line = api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
    if end_col >= #line then
        return
    end

    local after = line:sub(end_col + 1, end_col + 1)
    local selected = line:sub(start_col, end_col)
    local new_line = line:sub(1, start_col - 1) .. after .. selected .. line:sub(end_col + 2)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
    reselect_char(line_nr, start_col + 1, end_col + 1)
end

return M
