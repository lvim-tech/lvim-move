-- lvim-move.utils: the shared helpers — cursor-column capture (into lvim-move.state), the "moving" highlight
-- (Visual remapped to move_hl while a visual move is active), and the self-theming of the default move_hl group
-- from the lvim-utils palette. winhl is the only reliable way to override Visual-mode rendering (extmarks are
-- drawn UNDER the Visual selection, so a plain highlight always loses); vim.schedule defers the remap until
-- after the mode transition settles.
--
---@module "lvim-move.utils"

local config = require("lvim-move.config")
local state = require("lvim-move.state")

local api = vim.api

local M = {}

--- The augroup owning the one-shot ModeChanged autocmd that restores winhl when visual mode ends.
---@type integer
local HL_AUG = api.nvim_create_augroup("LvimMoveHL", { clear = true })

--- Self-theme the DEFAULT move highlight group ("LvimMoveHL") from the lvim-utils palette — a blue tinted
--- toward the background, re-applied automatically on every theme change (via highlight.bind). Applied with
--- `default = true`, so a colorscheme or the user can still override it. When lvim-utils is absent the plugin
--- falls back to a plain distinct link so the moved selection still shows a colour. A custom `move_hl` group is
--- the user's to define. Call once from setup().
---@return nil
function M.apply_hl()
    local ok, hl = pcall(require, "lvim-utils.highlight")
    if ok and type(hl.bind) == "function" then
        hl.bind(function(colors)
            local c = colors or require("lvim-utils.colors")
            return { LvimMoveHL = { bg = hl.blend(c.blue, c.bg, 0.3) } }
        end)
    else
        api.nvim_set_hl(0, "LvimMoveHL", { link = "IncSearch", default = true })
    end
end

--- Capture the current cursor column into state, so a vertical move can restore it on the moved line
--- afterwards. Uses getcurpos()[5] (the "want" column, which survives moving onto a shorter/longer line).
---@return nil
function M.cursor_position()
    state.column = vim.fn.getcurpos()[5]
end

--- Remap Visual → `config.move_hl` for the current window so the block/chars being moved get a distinct
--- colour, and restore the previous winhl once visual mode ends. No-op when `enable_move_hl` is off or the
--- selection was already dropped by the time the deferred callback runs.
---@return nil
function M.apply_move_hl()
    if not config.enable_move_hl then
        return
    end

    local win = api.nvim_get_current_win()
    local buf = api.nvim_get_current_buf()
    local hl_entry = "Visual:" .. config.move_hl

    vim.schedule(function()
        local mode = vim.fn.mode()
        if mode ~= "v" and mode ~= "V" then
            return
        end

        local prev_winhl = vim.wo.winhl

        -- prepend our entry (the first match in winhl wins) — but only once
        if not prev_winhl:find(hl_entry, 1, true) then
            vim.wo.winhl = hl_entry .. (prev_winhl ~= "" and "," .. prev_winhl or "")
        end

        -- restore winhl the moment we leave visual mode (any of v / V / <C-v>)
        api.nvim_clear_autocmds({ group = HL_AUG, buffer = buf })
        api.nvim_create_autocmd("ModeChanged", {
            group = HL_AUG,
            buffer = buf,
            callback = function()
                local new_mode = vim.fn.mode()
                if new_mode ~= "v" and new_mode ~= "V" and new_mode ~= "\x16" then
                    if api.nvim_win_is_valid(win) then
                        vim.wo[win].winhl = prev_winhl
                    end
                    return true -- delete the autocmd
                end
            end,
        })
    end)
end

return M
