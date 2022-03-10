local M = {}

M.map = function(allkeys)
    for index, value in ipairs(allkeys) do
        if type(value) == "table" then
            if #value == 4 then
                vim.api.nvim_set_keymap(value[1], value[2], value[3], value[4])
            else
                vim.api.nvim_set_keymap(value[1], value[2], value[3], {silent = true, noremap = true})
            end
        else
            return false
        end
    end
    return true
end

M.set_maps = function()
    M.map {
        {"n", "LvimMoveDownN", ":<C-u> lua require('lvim-move.actions').LvimMoveDownN()<CR>"},
        {"n", "LvimMoveUpN", ":<C-u> lua require('lvim-move.actions').LvimMoveUpN()<CR>"},
        {"n", "LvimMoveLeftN", ":<C-u> lua require('lvim-move.actions').LvimMoveLeftN()<CR>"},
        {"n", "LvimMoveRightN", ":<C-u> lua require('lvim-move.actions').LvimMoveRightN()<CR>"},
        {"x", "LvimMoveUpV", ":<C-u> lua require('lvim-move.actions').LvimMoveUpV()<CR>"},
        {"x", "LvimMoveDownV", ":<C-u> lua require('lvim-move.actions').LvimMoveDownV()<CR>"},
        {"x", "LvimMoveLeftV", ":<C-u> lua require('lvim-move.actions').LvimMoveLeftV()<CR>"},
        {"x", "LvimMoveRightV", ":<C-u> lua require('lvim-move.actions').LvimMoveRightV()<CR>"}
    }
end

return M
