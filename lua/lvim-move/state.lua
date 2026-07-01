-- lvim-move.state: RUNTIME-only state (never configuration). The cursor column is captured just before a
-- vertical line move so it can be restored on the moved line afterwards — nvim_buf_set_lines does not preserve
-- the cursor, and the '< / '> marks are unreliable after nvim_win_set_cursor. Kept out of config.lua so the
-- live config stays purely the user's declared options (the lvim-tech config/state split).
--
---@module "lvim-move.state"

---@class LvimMoveState
---@field column integer  1-based cursor column captured before a move (getcurpos()[5], the "want" column)
local M = {
    column = 1,
}

return M
