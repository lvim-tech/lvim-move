local M = {}

M.down = function()
	local start_character = vim.fn.getcharpos("'<")[3]
	local end_character = vim.fn.getcharpos("'>")[3]
	local cursor_position = vim.fn.getcharpos(".")[3]
	local all_characters = (end_character - start_character) + 1
	if all_characters == 1 then
		vim.cmd("silent! normal! djPv")
	elseif cursor_position == start_character then
		vim.cmd("silent! normal! djPv" .. (all_characters - 1) .. "h")
	elseif cursor_position == end_character then
		vim.cmd("silent! normal! djP" .. (all_characters - 1) .. "hv" .. (all_characters - 1) .. "l")
	end
end

M.up = function()
	local start_character = vim.fn.getcharpos("'<")[3]
	local end_character = vim.fn.getcharpos("'>")[3]
	local cursor_position = vim.fn.getcharpos(".")[3]
	local all_characters = (end_character - start_character) + 1
	if all_characters == 1 then
		vim.cmd("silent! normal! dkPv")
	elseif cursor_position == start_character then
		vim.cmd("silent! normal! dkPv" .. (all_characters - 1) .. "h")
	elseif cursor_position == end_character then
		vim.cmd("silent! normal! dkP" .. (all_characters - 1) .. "hv" .. (all_characters - 1) .. "l")
	end
end

M.left = function()
	local start_character = vim.fn.getcharpos("'<")[3]
	local end_character = vim.fn.getcharpos("'>")[3]
	local cursor_position = vim.fn.getcharpos(".")[3]
	local all_characters = (end_character - start_character) + 1
	if all_characters == 1 then
		vim.cmd("silent! normal! dhPv")
	elseif cursor_position == start_character then
		vim.cmd("silent! normal! dhPv" .. (all_characters - 1) .. "h")
	elseif cursor_position == end_character then
		vim.cmd("silent! normal! dhP" .. (all_characters - 1) .. "hv" .. (all_characters - 1) .. "l")
	end
end

M.right = function()
	local start_character = vim.fn.getcharpos("'<")[3]
	local end_character = vim.fn.getcharpos("'>")[3]
	local cursor_position = vim.fn.getcharpos(".")[3]
	local all_characters = (end_character - start_character) + 1
	if all_characters == 1 then
		vim.cmd("silent! normal! dpv")
	elseif cursor_position == start_character then
		vim.cmd("silent! normal! dpv" .. (all_characters - 1) .. "h")
	elseif cursor_position == end_character then
		vim.cmd("silent! normal! dp" .. (all_characters - 1) .. "hv" .. (all_characters - 1) .. "l")
	end
end

return M
