-- lvim-move: :checkhealth lvim-move
--
---@module "lvim-move.health"

local config = require("lvim-move.config")

local M = {}

--- Count the keymaps that are actually bound (non-empty lhs).
---@return integer
local function bound_maps()
    local n = 0
    for _, lhs in pairs(config.maps or {}) do
        if type(lhs) == "string" and lhs ~= "" then
            n = n + 1
        end
    end
    return n
end

function M.check()
    local health = vim.health
    health.start("lvim-move")

    if vim.fn.has("nvim-0.10") == 1 then
        health.ok("Neovim >= 0.10")
    else
        health.error("Neovim >= 0.10 is required (getcharpos, ModeChanged, winhl)")
    end

    -- lvim-utils: the shared merge + palette-driven self-theming (declared dependency).
    local ok_utils = pcall(require, "lvim-utils.utils")
    local ok_hl, hl = pcall(require, "lvim-utils.highlight")
    if ok_utils and ok_hl and type(hl.bind) == "function" then
        health.ok("lvim-utils found (shared merge + palette self-theming)")
    else
        health.warn("lvim-utils not found — using vim.tbl_deep_extend + a plain highlight fallback")
    end

    -- The move highlight group must resolve to something visible, or the selection loses its colour while moving.
    if not config.enable_move_hl then
        health.info("move highlight disabled (enable_move_hl = false)")
    elseif ok_hl and type(hl.group_exists) == "function" and hl.group_exists(config.move_hl) then
        health.ok(("move highlight '%s' is defined"):format(config.move_hl))
    else
        local exists = vim.fn.hlexists(config.move_hl) == 1
        if exists then
            health.ok(("move highlight '%s' is defined"):format(config.move_hl))
        else
            health.warn(
                ("move highlight '%s' is not defined — the selection will lose its colour while moving; define it or install lvim-utils"):format(
                    config.move_hl
                )
            )
        end
    end

    local n = bound_maps()
    if n > 0 then
        health.ok(("%d keymap(s) bound (auto-indent=%s)"):format(n, tostring(config.indent)))
    else
        health.warn('no keymaps bound — was setup() called, or are all maps set to ""?')
    end
end

return M
