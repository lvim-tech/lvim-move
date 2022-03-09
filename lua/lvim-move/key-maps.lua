local M = {}

function M.map(allkeys)
    for index, value in ipairs(allkeys) do
        if type(value) == "table" then
            -- mode, key, value, opts
            if #value == 4 then
                vim.api.nvim_set_keymap(value[1], value[2], value[3], value[4])
            else
                vim.api.nvim_set_keymap(value[1], value[2], value[3], {silent = true, noremap = true})
            end
        else
            print("mapping has invalid values at index " .. index)
            return false
        end
    end
    return true
end

function M.SetMaps()
    M.map {
        {"v", "LvimCharacterRight", "lua require('lvim-move.actions').character_right()"}
    }
end

return M
