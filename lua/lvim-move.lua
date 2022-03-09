local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local map = require("lvim-move.key-maps").map
-- local autocmd = require("lvim-move.autocmd")
-- local switch = require("lvim-move.switch")

local M = {}

M.setup = function(user_config)
    if user_config ~= nil then
        utils.merge(config, user_config)
    end
    M.init()
end

local function map_defaults()
    map(
        {
            {"v", "<A-l>", "<Plug>LvimCharacterRight", {}}
        }
    )
end

M.init = function()
    if config.default_keybindings == 1 then
        map_defaults()
    end
end

return M
