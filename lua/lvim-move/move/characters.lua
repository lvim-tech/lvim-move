local config = require("lvim-move.config")
local lines = require("lvim-move.move.lines")

local M = {}

M.down = function()
    local start_characters = vim.fn.getcharpos("'<")
    local end_characters = vim.fn.getcharpos("'>")
    local start_line = start_characters[2]
    local end_line = end_characters[2]
    local start_character = start_characters[3]
    local end_character = end_characters[3]
    local characters_number = (end_character - start_character) +  1
    local lines_number = (end_line - start_line) + 1
    local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
    if lines_number > 1 then
        vim.cmd("normal! V")
        lines.down("V")
    else
        if last_line > start_line then
            vim.cmd("normal! dj0")
            local all_characters = vim.fn.col('$')
            if math.abs(config.cursor_position.column - (config.cursor_position.column + end_character)) - config.cursor_position.column == characters_number then
                if all_characters > config.cursor_position.column + 1 then
                    vim.cmd("normal! " .. (config.cursor_position.column - 1) .. "lPv" .. (characters_number - 1) .. "h")
                else
                    vim.cmd("normal! $Pv" .. (characters_number - 1) .. "h")
                end
            else
                if all_characters > start_character + 1 then
                    print(1)
                    if start_character == 1 then
                        vim.cmd("normal! P" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
                    else
                        vim.cmd("normal! " .. (start_character - 1) .. "lP" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
                    end
                else
                    vim.cmd("normal! p" .. (characters_number - 1) .. "hv" .. (characters_number - 1).. "l")
                end
            end
        end
    end
end

M.up = function()
    local start_characters = vim.fn.getcharpos("'<")
    local end_characters = vim.fn.getcharpos("'>")
    local start_line = start_characters[2]
    local end_line = end_characters[2]
    local start_character = start_characters[3]
    local end_character = end_characters[3]
    local characters_number = (end_character - start_character) +  1
    local lines_number = (end_line - start_line) + 1
    if lines_number > 1 then
        vim.cmd("normal! V")
        lines.up("V")
    else
        if start_line > 1 then
            vim.cmd("normal! dk0")
            local all_characters = vim.fn.col('$')
            if math.abs(config.cursor_position.column - (config.cursor_position.column + end_character)) - config.cursor_position.column == characters_number then
                if all_characters > config.cursor_position.column + 1 then
                    vim.cmd("normal! " .. (config.cursor_position.column - 1) .. "lPv" .. (characters_number - 1) .. "h")
                else
                    vim.cmd("normal! $Pv" .. (characters_number - 1) .. "h")
                end
            else
                if all_characters > start_character + 1 then
                    print(1)
                    if start_character == 1 then
                        vim.cmd("normal! P" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
                    else
                        vim.cmd("normal! " .. (start_character - 1) .. "lP" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
                    end
                else
                    vim.cmd("normal! p" .. (characters_number - 1) .. "hv" .. (characters_number - 1).. "l")
                end
            end
        end
    end
end

M.left = function()
    local start_characters = vim.fn.getcharpos("'<")
    local end_characters = vim.fn.getcharpos("'>")
    local start_line = start_characters[2]
    local end_line = end_characters[2]
    local start_character = start_characters[3]
    local end_character = end_characters[3]
    local characters_number = (end_character - start_character) +  1
    local lines_number = (end_line - start_line) + 1
    if lines_number > 1 then
        vim.cmd("normal! V")
        lines.left("V")
    else
        if start_character > 1 then
            if characters_number == 1 then
                vim.cmd("normal! dhPv")
            elseif math.abs(config.cursor_position.column - (config.cursor_position.column + end_character)) - config.cursor_position.column == characters_number then
                vim.cmd("normal! dhPv" .. (characters_number - 1) .. "h")
            else
                vim.cmd("normal! dhP" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
            end
        end
    end
end


M.right = function()
    local start_characters = vim.fn.getcharpos("'<")
    local end_characters = vim.fn.getcharpos("'>")
    local start_line = start_characters[2]
    local end_line = end_characters[2]
    local start_character = start_characters[3]
    local end_character = end_characters[3]
    local characters_number = (end_character - start_character) +  1
    local lines_number = (end_line - start_line) + 1
    if lines_number > 1 then
        vim.cmd("normal! V")
        lines.right("V")
    else
        local all_characters = vim.fn.col("$")
        if all_characters > end_character then
            if characters_number == 1 then
                vim.cmd("normal! dpv")
            elseif math.abs(config.cursor_position.column - (config.cursor_position.column + end_character)) - config.cursor_position.column == characters_number then
                vim.cmd("normal! dpv" .. (characters_number - 1) .. "h")
            else
                vim.cmd("normal! dp" .. (characters_number - 1) .. "hv" .. (characters_number - 1) .. "l")
            end
        end
    end
end

-- print(vim.inspect(start_line),vim.inspect(end_line))
-- print(vim.fn.col("$"))
-- M.is_V = function()
--     local start_characters = vim.fn.getpos("'<")
--     local end_characters = vim.fn.getpos("'>")
--     local start_line = start_characters[2]
--     local end_line = end_characters[2]
--     local start_cursor = start_characters[3]
--     local end_cursor = end_characters[3]
--     local lines_number = (end_line - start_line) + 1
--     if lines_number > 1 then
--         vim.cmd("normal! V")
--         lines.right("V")
--     else

--     end
-- end

return M
