local config = require("lvim-move.config")

local M = {}

-- Reselects linewise visual at exact positions using explicit line numbers.
-- Avoids '< / '> marks which are unreliable after nvim_win_set_cursor.
local function reselect_block(new_start, new_end)
	vim.cmd("normal! \27\27")
	vim.cmd("normal! " .. new_start .. "ggV" .. new_end .. "gg")
end

M.down = function(mode)
	if mode == "n" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		local last_line = vim.fn.line("$")
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		elseif current_line < last_line then
			local two = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line + 1, false)
			vim.api.nvim_buf_set_lines(0, current_line - 1, current_line + 1, false, { two[2], two[1] })
			vim.api.nvim_win_set_cursor(0, { current_line + 1, config.cursor_position.column - 1 })
			return true
		end
	elseif mode == "V" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		local last_line = vim.fn.line("$")
		local start_line = vim.fn.getpos("'<")[2]
		local end_line = vim.fn.getpos("'>")[2]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		elseif end_line < last_line then
			local vSRow = start_line - 1
			local vERow = end_line
			local lines_buf = vim.api.nvim_buf_get_lines(0, vSRow, vERow + 1, false)
			local below = table.remove(lines_buf)
			table.insert(lines_buf, 1, below)
			vim.api.nvim_buf_set_lines(0, vSRow, vERow + 1, false, lines_buf)
			reselect_block(start_line + 1, end_line + 1)
			return true
		end
	end
end

M.up = function(mode)
	if mode == "n" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		elseif current_line > 1 then
			local two = vim.api.nvim_buf_get_lines(0, current_line - 2, current_line, false)
			vim.api.nvim_buf_set_lines(0, current_line - 2, current_line, false, { two[2], two[1] })
			vim.api.nvim_win_set_cursor(0, { current_line - 1, config.cursor_position.column - 1 })
			return true
		end
	elseif mode == "V" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		local start_line = vim.fn.getpos("'<")[2]
		local end_line = vim.fn.getpos("'>")[2]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		elseif start_line > 1 then
			local vSRow = start_line - 1
			local vERow = end_line
			local lines_buf = vim.api.nvim_buf_get_lines(0, vSRow - 1, vERow, false)
			local above = table.remove(lines_buf, 1)
			table.insert(lines_buf, above)
			vim.api.nvim_buf_set_lines(0, vSRow - 1, vERow, false, lines_buf)
			reselect_block(start_line - 1, end_line - 1)
			return true
		end
	end
end

M.left = function(mode)
	if mode == "n" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		else
			vim.cmd("normal! <<")
			local col = math.max(1, config.cursor_position.column - vim.o.tabstop)
			vim.api.nvim_win_set_cursor(0, { current_line, col - 1 })
		end
	elseif mode == "V" then
		local start_line = vim.fn.getpos("'<")[2]
		local end_line = vim.fn.getpos("'>")[2]
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		else
			vim.cmd("normal! <")
			reselect_block(start_line, end_line)
		end
	end
end

M.right = function(mode)
	if mode == "n" then
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		else
			vim.cmd("normal! >>")
			vim.api.nvim_win_set_cursor(0, { current_line, (config.cursor_position.column - 1) + vim.o.tabstop })
		end
	elseif mode == "V" then
		local start_line = vim.fn.getpos("'<")[2]
		local end_line = vim.fn.getpos("'>")[2]
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		if vim.fn.foldclosed(current_line) > -1 then
			vim.cmd("silent! normal! zv")
		else
			vim.cmd("normal! >")
			reselect_block(start_line, end_line)
		end
	end
end

return M
