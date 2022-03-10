local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local maps = require("lvim-move.key-maps")

local M = {}

M.setup = function(user_config)
    if user_config ~= nil then
        utils.merge(config, user_config)
    end
    M.init()
end

local function map_defaults()
    maps.map(
        {
            {"n", "<A-j>", "LvimMoveDownN", {}},
            {"n", "<A-k>", "LvimMoveUpN", {}},
            {"n", "<A-h>", "LvimMoveLeftN", {}},
            {"n", "<A-l>", "LvimMoveRightN", {}},
            {"x", "<A-j>", "LvimMoveDownV", {}},
            {"x", "<A-k>", "LvimMoveUpV", {}},
            {"x", "<A-h>", "LvimMoveLeftV", {}},
            {"x", "<A-l>", "LvimMoveRightV", {}}
        }
    )
end

M.init = function()
    maps.set_maps()
    if config.default_keybindings == 1 then
        map_defaults()
    end
end

return M
