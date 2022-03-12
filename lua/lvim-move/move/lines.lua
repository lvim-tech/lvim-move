local config = require("lvim-move.config")

local M = {}

M.down = function(mode)
    if mode == "n" then
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local current_line = vim.fn.getcharpos(".")[2]
        print(current_line)
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        elseif last_line > current_line then
            vim.cmd("normal! ddp")
            vim.api.nvim_win_set_cursor(0, {config.cursor_position.line + 1, config.cursor_position.column})
        end
    elseif mode == "V" then
        local current_line = vim.fn.getcharpos(".")[2]
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local start_line = vim.fn.getcharpos("'<")[2]
        local end_line = vim.fn.getcharpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        elseif last_line > end_line then
            if lines_number > 1 then
                if current_line == start_line then
                    vim.cmd(
                        "normal! " .. lines_number .. "dp" .. (lines_number - 1) .. "j" .. (lines_number - 1) .. "V"
                    )
                elseif current_line == end_line then
                    vim.cmd("normal! " .. lines_number .. "dpV" .. (lines_number - 1) .. "j")
                end
            else
                if current_line == start_line then
                    vim.cmd("normal! " .. lines_number .. "dpV")
                elseif current_line == end_line then
                    vim.cmd("normal! " .. lines_number .. "dpV")
                end
            end
            -- print(config.cursor_position.line, config.cursor_position.column)
            vim.api.nvim_win_set_cursor(0, {config.cursor_position.line + 1, config.cursor_position.column})
        end
    end
end

M.up = function(mode)
    if mode == "n" then
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local current_line = vim.fn.getcharpos(".")[2]
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        elseif current_line == last_line then
            vim.cmd("normal! ddP")
            vim.api.nvim_win_set_cursor(0, {config.cursor_position.line - 1, config.cursor_position.column})
        elseif current_line > 1 then
            vim.cmd("normal! ddkP")
            vim.api.nvim_win_set_cursor(0, {config.cursor_position.line - 1, config.cursor_position.column})
        end
    elseif mode == "V" then
        local current_line = vim.fn.getcharpos(".")[2]
        local last_line = tonumber(vim.api.nvim_exec([[echo line('$')]], true))
        local start_line = vim.fn.getcharpos("'<")[2]
        local end_line = vim.fn.getcharpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        elseif start_line > 1 then
            if end_line == last_line then
                if lines_number > 1 then
                    if current_line == start_line then
                        vim.cmd(
                            "normal! " .. lines_number .. "dP" .. (lines_number - 1) .. "j" .. (lines_number - 1) .. "V"
                        )
                    elseif current_line == end_line then
                        vim.cmd("normal! " .. lines_number .. "dPV" .. (lines_number - 1) .. "j")
                    end
                else
                    if current_line == start_line then
                        vim.cmd("normal! " .. lines_number .. "dPV")
                    elseif current_line == end_line then
                        vim.cmd("normal! " .. lines_number .. "dPV")
                    end
                end
                vim.api.nvim_win_set_cursor(0, {config.cursor_position.line - 1, config.cursor_position.column})
            else
                if lines_number > 1 then
                    if current_line == start_line then
                        vim.cmd(
                            "normal! " ..
                                lines_number .. "dkP" .. (lines_number - 1) .. "j" .. (lines_number - 1) .. "V"
                        )
                    elseif current_line == end_line then
                        vim.cmd("normal! " .. lines_number .. "dkPV" .. (lines_number - 1) .. "k")
                    end
                else
                    vim.cmd("normal! " .. lines_number .. "dkPV")
                end
                vim.api.nvim_win_set_cursor(0, {config.cursor_position.line - 1, config.cursor_position.column})
            end
        end
    end
end

M.left = function(mode)
    local tabstop = tonumber(vim.api.nvim_exec([[echo &tabstop]], true))
    if mode == "n" then
        local current_line = vim.fn.getcharpos(".")[2]
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        else
            vim.cmd("normal! V" .. current_line)
            vim.cmd("normal! gv<")
            local cursor_position = config.cursor_position.column - tabstop
            if cursor_position < 1 then
                cursor_position = 1
            end
            vim.api.nvim_win_set_cursor(0, {current_line, cursor_position})
        end
    elseif mode == "V" then
        local start_line = vim.fn.getcharpos("'<")[2]
        local end_line = vim.fn.getcharpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local current_line = vim.fn.getcharpos(".")[2]
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        else
            vim.cmd("normal! gv<")
            if lines_number > 1 then
                if current_line == start_line then
                    vim.cmd("normal! " .. (lines_number -1) .. "jV" .. (lines_number -1) .. "k")
                elseif current_line == end_line then
                    vim.cmd("normal! V" .. (lines_number -1) .. "j")
                end
            else
                vim.cmd("normal! V" .. (lines_number - 1))
            end
            local cursor_position = config.cursor_position.column - tabstop
            if cursor_position < 1 then
                cursor_position = 1
            end
            vim.api.nvim_win_set_cursor(0, {current_line, cursor_position})
        end
    end
end

M.right = function(mode)
    local tabstop = tonumber(vim.api.nvim_exec([[echo &tabstop]], true))
    if mode == "n" then
        local current_line = vim.fn.getcharpos(".")[2]
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        else
            vim.cmd("normal! V" .. current_line)
            vim.cmd("normal! gv>")
            vim.api.nvim_win_set_cursor(0, {current_line, config.cursor_position.column + tabstop})
        end
    elseif mode == "V" then
        local start_line = vim.fn.getcharpos("'<")[2]
        local end_line = vim.fn.getcharpos("'>")[2]
        local lines_number = (end_line - start_line) + 1
        local current_line = vim.fn.getcharpos(".")[2]
        local is_folded_current = tonumber(vim.api.nvim_exec([[echo foldclosed(]] .. current_line .. [[)]], true))
        if is_folded_current > -1 then
            vim.cmd("normal! zv")
        else
            vim.cmd("normal! gv>")
            if lines_number > 1 then
                if current_line == start_line then
                    vim.cmd("normal! " .. (lines_number -1) .. "jV" .. (lines_number -1) .. "k")
                elseif current_line == end_line then
                    vim.cmd("normal! V" .. (lines_number -1) .. "j")
                end
            else
                vim.cmd("normal! V" .. (lines_number - 1))
            end
            vim.api.nvim_win_set_cursor(0, {current_line, config.cursor_position.column + tabstop})
        end
    end
end

return M
