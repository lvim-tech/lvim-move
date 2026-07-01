-- lvim-move: move lines and character selections up / down / left / right, in normal and visual mode. The
-- public entry point: setup() merges the user's opts into the live config (via the shared lvim-utils.utils.merge
-- when present, else vim.tbl_deep_extend), self-themes the default move highlight from the lvim-utils palette,
-- and binds the eight keymaps. Every action is also exposed on lvim-move.actions for manual mapping. The move
-- LOGIC lives in move.lines (linewise) + move.characters (charwise); the pre/post steps in actions; the cursor
-- and highlight helpers in utils. Fold-aware (opens a fold instead of moving) and cursor-column preserving.
--
---@module "lvim-move"

local config = require("lvim-move.config")
local utils = require("lvim-move.utils")
local actions = require("lvim-move.actions")

-- shared merge (clean array REPLACE) when lvim-utils is installed; a graceful fallback keeps lvim-move usable
-- standalone. lvim-utils is a declared dependency (palette + merge) — see :checkhealth lvim-move.
local ok_utils, uu = pcall(require, "lvim-utils.utils")

local M = {}

--- Bind the eight configured keymaps. Normal-mode moves use a Lua callback; visual-mode moves use a
--- `:<C-u> … <CR>` command string so the '< / '> marks are set BEFORE the action runs (they are only committed
--- on leaving visual mode). A map whose lhs is "" is skipped (the documented way to disable one).
local function set_maps()
    ---@type { [1]: string, [2]: string, [3]: string }[]
    local normal_maps = {
        { config.maps.normal_down, "LvimMoveDownN", "Move line down" },
        { config.maps.normal_up, "LvimMoveUpN", "Move line up" },
        { config.maps.normal_left, "LvimMoveLeftN", "Move line left (dedent)" },
        { config.maps.normal_right, "LvimMoveRightN", "Move line right (indent)" },
    }
    for _, map in ipairs(normal_maps) do
        local lhs, fn_name, desc = map[1], map[2], map[3]
        if lhs ~= "" then
            vim.keymap.set("n", lhs, function()
                actions[fn_name]()
            end, { noremap = true, silent = true, desc = desc })
        end
    end

    ---@type { [1]: string, [2]: string, [3]: string }[]
    local visual_maps = {
        { config.maps.visual_down, "LvimMoveDownV", "Move selection down" },
        { config.maps.visual_up, "LvimMoveUpV", "Move selection up" },
        { config.maps.visual_left, "LvimMoveLeftV", "Move selection left (dedent)" },
        { config.maps.visual_right, "LvimMoveRightV", "Move selection right (indent)" },
    }
    for _, map in ipairs(visual_maps) do
        local lhs, fn_name, desc = map[1], map[2], map[3]
        if lhs ~= "" then
            vim.keymap.set(
                "x",
                lhs,
                ":<C-u> lua require('lvim-move.actions')." .. fn_name .. "()<CR>",
                { noremap = true, silent = true, desc = desc }
            )
        end
    end
end

--- Merge the user's options, self-theme the move highlight, and install the keymaps. Safe to call again to
--- re-apply after a config change.
---@param user_config? LvimMoveConfig  partial overrides; anything omitted keeps its default
M.setup = function(user_config)
    if ok_utils and uu.merge then
        uu.merge(config, user_config or {})
    elseif user_config then
        ---@diagnostic disable-next-line: cast-local-type
        config = vim.tbl_deep_extend("force", config, user_config)
    end
    utils.apply_hl()
    set_maps()
end

return M
