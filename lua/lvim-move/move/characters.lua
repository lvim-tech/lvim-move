local M = {}

local function reselect_char(line_nr, start_col, end_col)
	vim.cmd("normal! \27\27")
	vim.cmd("normal! " .. line_nr .. "gg" .. start_col .. "|v" .. end_col .. "|")
end

local function get_selection()
	local s = vim.fn.getcharpos("'<")
	local e = vim.fn.getcharpos("'>")
	if s[2] ~= e[2] then return nil end  -- ignore multi-line character selections
	return s[2], s[3], e[3]  -- line_nr, start_col, end_col
end

M.down = function()
	local line_nr, start_col, end_col = get_selection()
	if not line_nr or line_nr >= vim.fn.line("$") then return end

	local two_lines = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr + 1, false)
	local cur_line, next_line = two_lines[1], two_lines[2]
	local selected  = cur_line:sub(start_col, end_col)

	local new_cur  = cur_line:sub(1, start_col - 1) .. cur_line:sub(end_col + 1)
	local ins      = math.min(start_col - 1, #next_line)
	local new_next = next_line:sub(1, ins) .. selected .. next_line:sub(ins + 1)

	vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr + 1, false, { new_cur, new_next })
	reselect_char(line_nr + 1, ins + 1, ins + #selected)
end

M.up = function()
	local line_nr, start_col, end_col = get_selection()
	if not line_nr or line_nr <= 1 then return end

	local two_lines = vim.api.nvim_buf_get_lines(0, line_nr - 2, line_nr, false)
	local prev_line, cur_line = two_lines[1], two_lines[2]
	local selected  = cur_line:sub(start_col, end_col)

	local new_cur  = cur_line:sub(1, start_col - 1) .. cur_line:sub(end_col + 1)
	local ins      = math.min(start_col - 1, #prev_line)
	local new_prev = prev_line:sub(1, ins) .. selected .. prev_line:sub(ins + 1)

	vim.api.nvim_buf_set_lines(0, line_nr - 2, line_nr, false, { new_prev, new_cur })
	reselect_char(line_nr - 1, ins + 1, ins + #selected)
end

M.left = function()
	local line_nr, start_col, end_col = get_selection()
	if not line_nr or start_col <= 1 then return end

	local line     = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
	local before   = line:sub(start_col - 1, start_col - 1)
	local selected = line:sub(start_col, end_col)
	local new_line = line:sub(1, start_col - 2) .. selected .. before .. line:sub(end_col + 1)

	vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
	reselect_char(line_nr, start_col - 1, end_col - 1)
end

M.right = function()
	local line_nr, start_col, end_col = get_selection()
	if not line_nr then return end
	local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
	if end_col >= #line then return end

	local after    = line:sub(end_col + 1, end_col + 1)
	local selected = line:sub(start_col, end_col)
	local new_line = line:sub(1, start_col - 1) .. after .. selected .. line:sub(end_col + 2)

	vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
	reselect_char(line_nr, start_col + 1, end_col + 1)
end

return M
