local config = require("lvim-move.config")
local utils = require("lvim-move.utils")

local M = {}

local function set_maps()
	-- Normal mode: function callbacks are fine (no visual marks involved)
	local normal_maps = {
		{ config.maps.normal_down, "LvimMoveDownN", "Move line down" },
		{ config.maps.normal_up, "LvimMoveUpN", "Move line up" },
		{ config.maps.normal_left, "LvimMoveLeftN", "Move line left (dedent)" },
		{ config.maps.normal_right, "LvimMoveRightN", "Move line right (indent)" },
	}
	for _, map in ipairs(normal_maps) do
		local lhs, fn_name, desc = map[1], map[2], map[3]
		vim.keymap.set("n", lhs, function()
			require("lvim-move.actions")[fn_name]()
		end, { noremap = true, silent = true, desc = desc })
	end

	-- Visual mode: use :<C-u> to ensure visual marks '< and '> are set before execution
	local visual_maps = {
		{ config.maps.visual_down, "LvimMoveDownV", "Move selection down" },
		{ config.maps.visual_up, "LvimMoveUpV", "Move selection up" },
		{ config.maps.visual_left, "LvimMoveLeftV", "Move selection left (dedent)" },
		{ config.maps.visual_right, "LvimMoveRightV", "Move selection right (indent)" },
	}
	for _, map in ipairs(visual_maps) do
		local lhs, fn_name, desc = map[1], map[2], map[3]
		vim.keymap.set(
			"x",
			lhs,
			":<C-u> lua require('lvim-move.actions')." .. fn_name .. "()<CR>",
			{ noremap = true, silent = true, desc = desc }
		)
	end
end

M.setup = function(user_config)
	if user_config ~= nil then
		utils.merge(config, user_config)
	end
	set_maps()
end

return M
