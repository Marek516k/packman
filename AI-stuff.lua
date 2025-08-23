function Is_wall(x, y)

    for _, wall in ipairs(Walls) do
        if wall.x - 1 == x and wall.y - 1 == y then
            return true
        end
    end
    return false
end

function Is_ghost(x, y, selfGhost)
    for _, g in pairs(Ghosts) do
        if g ~= selfGhost and g.x == x and g.y == y then
            return true
        end
    end
    return false
end

local function shuffleInPlace(t, startIndex)

    for i = #t, startIndex, -1 do
        local j = Love.math.random(startIndex, i)
        t[i], t[j] = t[j], t[i]
    end
end

local function canMove(g, dx, dy)
    return not Is_wall(g.x + dx, g.y + dy) and not Is_ghost(g.x + dx, g.y + dy, g)
end

local function stepIfFree(g, dx, dy)
    if not Is_wall(g.x + dx, g.y + dy)
       and not Is_ghost(g.x + dx, g.y + dy, g) then

        g.x = g.x + dx
        g.y = g.y + dy
        g.lastdx, g.lastdy = dx, dy
        return true
    end
    return false
end

local function buildPriorityList(tx, ty, G)
    local list = {}

    local dx = (tx > G.x) and 1 or -1
    local dy = (ty > G.y) and 1 or -1

    local primaries = {
        {x = dx, y = 0},
        {x = 0, y = dy},
    }

    shuffleInPlace(primaries, 1)

    for _, d in ipairs(primaries) do
        table.insert(list, d)
    end

    local secondaries = {
        {x = -dx, y = 0},
        {x = 0, y = -dy},
    }
    shuffleInPlace(secondaries, 1)

    for _, d in ipairs(secondaries) do
        table.insert(list, d)
    end

    return list
end

local function ghostMove(G, priorities)
    if G.state == "respawning" then return
    end

    if Love.math.random() < 0.2 then -- 20% chance to reshuffle directions completely
        shuffleInPlace(priorities, 1)
    end

    local revx, revy = -(G.lastdx or 0), -(G.lastdy or 0)
    local hasAlternative = false

    for _, d in ipairs(priorities) do
        if not (d.x == revx and d.y == revy) and canMove(G, d.x, d.y) then
            hasAlternative = true
            break
        end
    end

    for _, d in ipairs(priorities) do
        if (d.x ~= revx or d.y ~= revy) or not hasAlternative then
            if stepIfFree(G, d.x, d.y) then return end
        end
    end
end

function Blinky(Px, Py, G)
    local priorities = buildPriorityList(Px, Py, G)
    ghostMove(G, priorities)
end

function Pinky(Px, Py, G, Pdirx, Pdiry)
    local targetX = Px + 4 * Pdirx
    local targetY = Py + 4 * Pdiry
    local priorities = buildPriorityList(targetX, targetY, G)
    ghostMove(G, priorities)
end

function Inky(Px, Py, G, Pdirx, Pdiry, Blinky_)
    if not Blinky_ or not Blinky_.x then
        local priorities = buildPriorityList(Px, Py, G)
        return ghostMove(G, priorities)
    end

    local aheadX = Px + 2 * Pdirx
    local aheadY = Py + 2 * Pdiry
    local vectX = (aheadX - Blinky_.x) * 2
    local vectY = (aheadY - Blinky_.y) * 2
    local targetX = Blinky_.x + vectX
    local targetY = Blinky_.y + vectY
    local priorities = buildPriorityList(targetX, targetY, G)
    ghostMove(G, priorities)
end

function Clyde(Px, Py, G)
    local dx = Px - G.x
    local dy = Py - G.y
    local dist2 = dx*dx + dy*dy
    local targetX, targetY

    if dist2 > (8*8) then
        targetX, targetY = Px, Py
    else
        targetX, targetY = 0, 25
    end

    local priorities = buildPriorityList(targetX, targetY, G)
    ghostMove(G, priorities)
end

return {
    Blinky = Blinky,
    Pinky  = Pinky,
    Inky   = Inky,
    Clyde  = Clyde,
}