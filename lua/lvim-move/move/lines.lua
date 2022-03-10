local config = require("lvim-move.config")

local M = {}

M.down = function(mode)
    if mode == "n" then
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local current_line = vim.fn.getpos(".")[2]
        if last_line > current_line then
            vim.cmd("normal! ddp")
            vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line + 1, config.cursor_position.column})
        end
    elseif mode == "V" then
        local current_line = vim.fn.getpos(".")[2]
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]
        local lines_numbers = (end_line - start_line) + 1
        if last_line > end_line then
            if current_line == start_line then
                vim.cmd("normal! " .. lines_numbers .. "dp" .. (lines_numbers - 1) .. "j" .. (lines_numbers - 1) .. "V")
            elseif current_line == end_line then
                vim.cmd("normal! " .. lines_numbers .. "dpV" .. (lines_numbers - 1) .. "j")
            end
            vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line + 1, config.cursor_position.column})
        end
    end
end

M.up = function(mode)
    if mode == "n" then
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local current_line = vim.fn.getpos(".")[2]
        if current_line == last_line then
            vim.cmd("normal! ddP")
            vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line - 1, config.cursor_position.column})
        elseif current_line > 1 then
            vim.cmd("normal! ddkP")
            vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line - 1, config.cursor_position.column})
        end
    elseif mode == "V" then
        local current_line = vim.fn.getpos(".")[2]
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]
        local lines_numbers = (end_line - start_line) + 1
        if start_line > 1 then
            if end_line == last_line then
                if current_line == start_line then
                    vim.cmd(
                        "normal! " .. lines_numbers .. "dP" .. (lines_numbers - 1) .. "j" .. (lines_numbers - 1) .. "V"
                    )
                elseif current_line == end_line then
                    vim.cmd("normal! " .. lines_numbers .. "dPV" .. (lines_numbers - 1) .. "j")
                end
                vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line - 1, config.cursor_position.column})
            else
                if current_line == start_line then
                    vim.cmd(
                        "normal! " .. lines_numbers .. "dkP" .. (lines_numbers - 1) .. "j" .. (lines_numbers - 1) .. "V"
                    )
                elseif current_line == end_line then
                    vim.cmd("normal! " .. lines_numbers .. "dkPV" .. (lines_numbers - 1) .. "j")
                end
                vim.api.nvim_win_set_cursor({0}, {config.cursor_position.line - 1, config.cursor_position.column})
            end
        end
    end
end

M.left = function(mode)
    local tabstop = tonumber(vim.api.nvim_exec([[echo &tabstop]], true))
    if mode == "n" then
        local current_line = vim.fn.getpos(".")[2]
        vim.cmd("normal! V" .. current_line)
        vim.cmd("normal! gv<")
        vim.api.nvim_win_set_cursor({0}, {current_line, config.cursor_position.column - tabstop})
    elseif mode == "V" then
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local current_line = vim.fn.getpos(".")[2]
        vim.cmd("normal! gv<")
        if lines_number > 1 then
            vim.cmd("normal! V" .. (lines_number - 1) .. "j")
        else
            vim.cmd("normal! V" .. (lines_number - 1))
        end
        vim.api.nvim_win_set_cursor({0}, {current_line, config.cursor_position.column - tabstop})
    end
end

M.right = function(mode)
    local tabstop = tonumber(vim.api.nvim_exec([[echo &tabstop]], true))
    if mode == "n" then
        local current_line = vim.fn.getpos(".")[2]
        vim.cmd("normal! V" .. current_line)
        vim.cmd("normal! gv>")
        vim.api.nvim_win_set_cursor({0}, {current_line, config.cursor_position.column + tabstop})
    elseif mode == "V" then
        local start_line = vim.fn.getpos("'<")[2]
        local end_line = vim.fn.getpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local current_line = vim.fn.getpos(".")[2]
        vim.cmd("normal! gv>")
        if lines_number > 1 then
            vim.cmd("normal! V" .. (lines_number - 1) .. "j")
        else
            vim.cmd("normal! V" .. (lines_number - 1))
        end
        vim.api.nvim_win_set_cursor({0}, {current_line, config.cursor_position.column + tabstop})
    end
end

return M
