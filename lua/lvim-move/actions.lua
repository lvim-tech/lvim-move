local M = {}
-- v       Visual by character
--     V       Visual by line
--     CTRL-V  Visual blockwise

-- LINES
M.line_up = function()
    print("line up")
end

M.line_down = function()
    print("line down")
end
-- LINES

-- CHARACTERS
M.character_up = function()
    print("character up")
end

M.character_down = function()
    print("character down")
end

M.character_left = function()
    print("character left")
end

function M.character_right()
    print("helllooooo")
end
-- CHARACTERS

-- BLOCK
M.block_up = function()
    print("block up")
end

M.block_down = function()
    print("block down")
end

M.block_left = function()
    print("block left")
end

M.block_right = function()
    print("block right")
end
-- BLOCK

return M
