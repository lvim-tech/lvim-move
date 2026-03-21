local config = require("lvim-move.config")

local M = {}

local HL_AUG = vim.api.nvim_create_augroup("LvimMoveHL", { clear = true })

local function concat(t1, t2)
	for i = 1, #t2 do
		table.insert(t1, t2[i])
	end
	return t1
end

local function is_array(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

M.merge = function(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			if is_array(t1[k]) then
				t1[k] = concat(t1[k], v)
			else
				M.merge(t1[k], t2[k])
			end
		else
			t1[k] = v
		end
	end
	return t1
end

M.cursor_position = function()
	config.cursor_position = { column = vim.fn.getcurpos()[5] }
end

-- Uses winhl to remap Visual → LvimMoveHL for the current window.
-- winhl is the only reliable way to override Visual mode rendering
-- (extmarks are drawn before the Visual selection, so Visual always wins).
-- vim.schedule defers until after all mode transitions settle.
M.apply_move_hl = function()
	if not config.enable_move_hl then return end

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local hl_entry = "Visual:" .. config.move_hl

	vim.schedule(function()
		local mode = vim.fn.mode()
		if mode ~= "v" and mode ~= "V" then return end

		local prev_winhl = vim.wo.winhl

		-- Add our entry first (first match in winhl wins)
		if not prev_winhl:find(hl_entry, 1, true) then
			vim.wo.winhl = hl_entry .. (prev_winhl ~= "" and "," .. prev_winhl or "")
		end

		-- Restore winhl when leaving visual mode
		vim.api.nvim_clear_autocmds({ group = HL_AUG, buffer = buf })
		vim.api.nvim_create_autocmd("ModeChanged", {
			group = HL_AUG,
			buffer = buf,
			callback = function()
				local new_mode = vim.fn.mode()
				if new_mode ~= "v" and new_mode ~= "V" and new_mode ~= "\x16" then
					if vim.api.nvim_win_is_valid(win) then
						vim.wo[win].winhl = prev_winhl
					end
					return true -- delete the autocmd
				end
			end,
		})
	end)
end

return M
