-- lvim-move.move.characters: the CHARWISE move primitives (up / down / left / right) for a charwise-visual
-- ("v") selection WITHIN a single line. up/down move the selected text to the same column on the adjacent line
-- (clamped to that line's length); left/right swap the selection with its neighbouring character. Multi-line
-- charwise selections are ignored (get_selection returns nil). Everything works in CHARACTER units (not bytes),
-- so multibyte lines behave correctly: lines are split into characters (to_chars), spliced with table.concat over
-- character ranges, and re-selected by converting the character columns back to byte offsets (reselect_char).
--
---@module "lvim-move.move.characters"

local api = vim.api
local fn = vim.fn

local M = {}

--- Split a string into its characters (multibyte aware — honours 'encoding'), so column math is by CHARACTER,
--- not byte. `fn.split(s, "\\zs")` matches the empty span before every character, yielding one entry per char.
---@param s string
---@return string[] chars  one entry per character (empty table for "")
local function to_chars(s)
    return fn.split(s, "\\zs")
end

--- Re-assert a charwise visual selection at explicit CHARACTER columns (marks are unreliable post-edit). The
--- columns are converted to 0-based byte offsets (byteidx) and driven through nvim_win_set_cursor, so the span
--- is exact on multibyte lines regardless of display width.
---@param line_nr integer   line (1-based)
---@param start_col integer selection start column (1-based, in characters)
---@param end_col integer   selection end column (1-based, inclusive, in characters)
---@return nil
local function reselect_char(line_nr, start_col, end_col)
    local line = api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1] or ""
    local start_byte = fn.byteidx(line, start_col - 1)
    -- With `selection=inclusive` (the default) the cursor sits ON the last char's first byte and the char is
    -- covered. With `selection=exclusive` the selection stops BEFORE the cursor, so land it one char further —
    -- the byte just past the last selected char — or the whole span loses its final character.
    local end_byte
    if vim.o.selection == "exclusive" then
        end_byte = fn.byteidx(line, end_col)
        if end_byte < 0 then
            end_byte = #line
        end
    else
        end_byte = fn.byteidx(line, end_col - 1)
    end
    vim.cmd("normal! \27")
    api.nvim_win_set_cursor(0, { line_nr, start_byte })
    vim.cmd("normal! v")
    api.nvim_win_set_cursor(0, { line_nr, end_byte })
end

--- Resolve the current charwise selection to a single-line span (in CHARACTER columns via getcharpos).
---@return integer|nil line_nr  1-based line, or nil when the selection spans multiple lines
---@return integer? start_col   selection start column (1-based, in characters)
---@return integer? end_col     selection end column (1-based, inclusive, in characters)
local function get_selection()
    local s = fn.getcharpos("'<")
    local e = fn.getcharpos("'>")
    if s[2] ~= e[2] then
        return nil -- ignore multi-line character selections
    end
    return s[2], s[3], e[3] -- line_nr, start_col, end_col
end

--- Move the selected chars DOWN to the same column on the next line (clamped to its length).
---@return nil
M.down = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or line_nr >= fn.line("$") then
        return
    end

    local two_lines = api.nvim_buf_get_lines(0, line_nr - 1, line_nr + 1, false)
    local cur = to_chars(two_lines[1])
    local next_chars = to_chars(two_lines[2])
    local selected = table.concat(cur, "", start_col, end_col)

    local new_cur = table.concat(cur, "", 1, start_col - 1) .. table.concat(cur, "", end_col + 1)
    local ins = math.min(start_col - 1, #next_chars)
    local new_next = table.concat(next_chars, "", 1, ins) .. selected .. table.concat(next_chars, "", ins + 1)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr + 1, false, { new_cur, new_next })
    reselect_char(line_nr + 1, ins + 1, ins + (end_col - start_col + 1))
end

--- Move the selected chars UP to the same column on the previous line (clamped to its length).
---@return nil
M.up = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or line_nr <= 1 then
        return
    end

    local two_lines = api.nvim_buf_get_lines(0, line_nr - 2, line_nr, false)
    local prev_chars = to_chars(two_lines[1])
    local cur = to_chars(two_lines[2])
    local selected = table.concat(cur, "", start_col, end_col)

    local new_cur = table.concat(cur, "", 1, start_col - 1) .. table.concat(cur, "", end_col + 1)
    local ins = math.min(start_col - 1, #prev_chars)
    local new_prev = table.concat(prev_chars, "", 1, ins) .. selected .. table.concat(prev_chars, "", ins + 1)

    api.nvim_buf_set_lines(0, line_nr - 2, line_nr, false, { new_prev, new_cur })
    reselect_char(line_nr - 1, ins + 1, ins + (end_col - start_col + 1))
end

--- Swap the selected chars with the single character to their LEFT.
---@return nil
M.left = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr or start_col <= 1 then
        return
    end

    local chars = to_chars(api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1])
    local before = chars[start_col - 1]
    local selected = table.concat(chars, "", start_col, end_col)
    local new_line = table.concat(chars, "", 1, start_col - 2)
        .. selected
        .. before
        .. table.concat(chars, "", end_col + 1)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
    reselect_char(line_nr, start_col - 1, end_col - 1)
end

--- Swap the selected chars with the single character to their RIGHT.
---@return nil
M.right = function()
    local line_nr, start_col, end_col = get_selection()
    if not line_nr then
        return
    end
    local chars = to_chars(api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1])
    if end_col >= #chars then
        return
    end

    local after = chars[end_col + 1]
    local selected = table.concat(chars, "", start_col, end_col)
    local new_line = table.concat(chars, "", 1, start_col - 1)
        .. after
        .. selected
        .. table.concat(chars, "", end_col + 2)

    api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
    reselect_char(line_nr, start_col + 1, end_col + 1)
end

return M
