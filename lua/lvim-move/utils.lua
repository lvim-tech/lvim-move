local config = require("lvim-move.config")
local cmd = vim.api.nvim_command

local M = {}

M.merge = function(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			if M.is_array(t1[k]) then
				t1[k] = M.concat(t1[k], v)
			else
				M.merge(t1[k], t2[k])
			end
		else
			t1[k] = v
		end
	end
	return t1
end

M.concat = function(t1, t2)
	for i = 1, #t2 do
		table.insert(t1, t2[i])
	end
	return t1
end

M.is_array = function(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

M.cursor_position = function()
	local position = vim.api.nvim_win_get_cursor(0)
	config.cursor_position = {
		line = position[1],
		column = position[2],
	}
end

M.reindent = function()
	vim.defer_fn(function()
		local new_line_start = vim.fn.line("'[")
		local new_line_end = vim.fn.line("']")
		vim.fn.cursor(new_line_start, 1)
		local old_indent = vim.fn.indent(".")
		vim.cmd("silent! normal! ==")
		local new_indent = vim.fn.indent(".")

		if new_line_start < new_line_end and old_indent ~= new_indent then
			local op = (
				old_indent < new_indent and string.rep(">", new_indent - old_indent)
				or string.rep("<", old_indent - new_indent)
			)
			local old_sw = vim.fn.shiftwidth()
			vim.o.shiftwidth = 1
			vim.cmd("silent! " .. new_line_start + 1 .. "," .. new_line_end .. op)
			vim.o.shiftwidth = old_sw
		end
	end, 100)
end

return M
