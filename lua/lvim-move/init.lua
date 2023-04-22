local config = require("lvim-move.config")
local utils = require("lvim-move.utils")

local M = {}

local function set_maps()
	vim.keymap.set(
		"n",
		config.maps.normal_down,
		":<C-u> lua require('lvim-move.actions').LvimMoveDownN()<CR>",
		{ noremap = true, silent = true }
	)
	vim.keymap.set(
		"n",
		config.maps.normal_up,
		":<C-u> lua require('lvim-move.actions').LvimMoveUpN()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveUpN" }
	)
	vim.keymap.set(
		"n",
		config.maps.normal_left,
		":<C-u> lua require('lvim-move.actions').LvimMoveLeftN()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveLeftN" }
	)
	vim.keymap.set(
		"n",
		config.maps.normal_right,
		":<C-u> lua require('lvim-move.actions').LvimMoveRightN()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveRightN" }
	)
	vim.keymap.set(
		"x",
		config.maps.visual_down,
		":<C-u> lua require('lvim-move.actions').LvimMoveDownV()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveDownV" }
	)
	vim.keymap.set(
		"x",
		config.maps.visual_up,
		":<C-u> lua require('lvim-move.actions').LvimMoveUpV()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveUpV" }
	)
	vim.keymap.set(
		"x",
		config.maps.visual_left,
		":<C-u> lua require('lvim-move.actions').LvimMoveLeftV()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveLeftV" }
	)
	vim.keymap.set(
		"x",
		config.maps.visual_right,
		":<C-u> lua require('lvim-move.actions').LvimMoveRightV()<CR>",
		{ noremap = true, silent = true, desc = "LvimMoveRightV" }
	)
end

M.setup = function(user_config)
	if user_config ~= nil then
		utils.merge(config, user_config)
	end
	set_maps()
end

return M
