local cmd = vim.api.nvim_command

local M = {}

M.merge = function(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            if M.is_array(t1[k]) then
                t1[k] = M.concat(t1[k], v)
            else
                M.merge(t1[k], t2[k])
            end
        else
            t1[k] = v
        end
    end
    return t1
end

M.concat = function(t1, t2)
    for i = 1, #t2 do
        table.insert(t1, t2[i])
    end
    return t1
end

M.is_array = function(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
    return true
end

-- M.create_augroups = function(definitions)
--     for group_name, definition in pairs(definitions) do
--         cmd("augroup " .. group_name)
--         cmd("autocmd!")
--         for _, def in ipairs(definition) do
--             local command = table.concat(vim.tbl_flatten({"autocmd", def}), " ")
--             cmd(command)
--         end
--         cmd("augroup END")
--     end
-- end
--
-- M.map = function(mode, lhs, rhs, opts)
--     local options = {noremap = true}
--     if opts then
--         options = vim.tbl_extend("force", options, opts)
--     end
--     vim.api.nvim_set_keymap(mode, lhs, rhs, options)
-- end_row

return M
