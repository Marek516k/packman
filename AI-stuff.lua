require("levels")

function Is_wall(x, y)
    for _, wall in ipairs(Walls) do
        if wall.x - 1 == x and wall.y - 1 == y then
            return true
        end
    end

    return false
end

function blinkyAI(Packman_x, Packman_y, Ghost)
    if Ghost.x < Packman_x and not Is_wall(Ghost.x + 1, Ghost.y) then
        Ghost.x = Ghost.x + 1
    elseif Ghost.x > Packman_x and not Is_wall(Ghost.x - 1, Ghost.y) then
        Ghost.x = Ghost.x - 1
    end

    if Ghost.y < Packman_y and not Is_wall(Ghost.x, Ghost.y + 1) then
        Ghost.y = Ghost.y + 1
    elseif Ghost.y > Packman_y and not Is_wall(Ghost.x, Ghost.y - 1) then
        Ghost.y = Ghost.y - 1
    end
end

function inkyAI(Packman_x, Packman_y, Ghost)
    if Ghost.x < Packman_x and not Is_wall(Ghost.x + 1, Ghost.y) then
        Ghost.x = Ghost.x + 1
    elseif Ghost.x > Packman_x and not Is_wall(Ghost.x - 1, Ghost.y) then
        Ghost.x = Ghost.x - 1
    end

    if Ghost.y < Packman_y and not Is_wall(Ghost.x, Ghost.y + 1) then
        Ghost.y = Ghost.y + 1
    elseif Ghost.y > Packman_y and not Is_wall(Ghost.x, Ghost.y - 1) then
        Ghost.y = Ghost.y - 1
    end
end

function pinkyAI(Packman_x, Packman_y, Ghost)
    if Ghost.x < Packman_x and not Is_wall(Ghost.x + 1, Ghost.y) then
        Ghost.x = Ghost.x + 1
    elseif Ghost.x > Packman_x and not Is_wall(Ghost.x - 1, Ghost.y) then
        Ghost.x = Ghost.x - 1
    end

    if Ghost.y < Packman_y and not Is_wall(Ghost.x, Ghost.y + 1) then
        Ghost.y = Ghost.y + 1
    elseif Ghost.y > Packman_y and not Is_wall(Ghost.x, Ghost.y - 1) then
        Ghost.y = Ghost.y - 1
    end
end

function clydeAI(Packman_x, Packman_y, Ghost)
    if Ghost.x < Packman_x and not Is_wall(Ghost.x + 1, Ghost.y) then
        Ghost.x = Ghost.x + 1
    elseif Ghost.x > Packman_x and not Is_wall(Ghost.x - 1, Ghost.y) then
        Ghost.x = Ghost.x - 1
    end

    if Ghost.y < Packman_y and not Is_wall(Ghost.x, Ghost.y + 1) then
        Ghost.y = Ghost.y + 1
    elseif Ghost.y > Packman_y and not Is_wall(Ghost.x, Ghost.y - 1) then
        Ghost.y = Ghost.y - 1
    end
end

function AICollision()
end

return clydeAI, pinkyAI, inkyAI, blinkyAI