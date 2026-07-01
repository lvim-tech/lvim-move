-- lvim-move.config: the LIVE configuration for lvim-move. setup() merges the user's opts into THIS table in
-- place (via lvim-utils.utils.merge, or vim.tbl_deep_extend when lvim-utils is absent); every reader does
-- `require("lvim-move.config")` and sees the effective values. Runtime state lives in lvim-move.state, never
-- here.
--
---@module "lvim-move.config"

---@class LvimMoveMaps
---@field normal_down string   move the current line down (normal mode)
---@field normal_up string     move the current line up (normal mode)
---@field normal_left string   dedent the current line (normal mode)
---@field normal_right string  indent the current line (normal mode)
---@field visual_down string   move the selection down (visual mode)
---@field visual_up string     move the selection up (visual mode)
---@field visual_left string   dedent / move chars left (visual mode)
---@field visual_right string  indent / move chars right (visual mode)

---@class LvimMoveConfig
---@field indent boolean         auto-indent (`==`) after a vertical line move (up/down)
---@field enable_move_hl boolean highlight the moved selection while a charwise/linewise visual move is active
---@field move_hl string         the highlight group Visual is remapped to while moving (self-themed default)
---@field maps LvimMoveMaps      the default keymaps; set any to "" to disable that one

---@type LvimMoveConfig
local M = {
    indent = true,
    enable_move_hl = true,
    move_hl = "LvimMoveHL",
    maps = {
        normal_down = "<A-j>",
        normal_up = "<A-k>",
        normal_left = "<A-h>",
        normal_right = "<A-l>",
        visual_down = "<A-j>",
        visual_up = "<A-k>",
        visual_left = "<A-h>",
        visual_right = "<A-l>",
    },
}

return M
