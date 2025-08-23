function Is_wall(x, y)

    for _, wall in ipairs(Walls) do
        if wall.x - 1 == x and wall.y - 1 == y then
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

    return not Is_wall(g.x + dx, g.y + dy)
end

local function stepIfFree(g, dx, dy)

    if not Is_wall(g.x + dx, g.y + dy) then
        g.x = g.x + dx
        g.y = g.y + dy
        g.lastdx, g.lastdy = dx, dy
        return true
    end
    return false
end

local function buildPriorityList(tx, ty, G)

    local list = {}
    -- 1st horizontal toward target
    table.insert(list, {x = (tx > G.x) and 1 or -1, y = 0})
    -- 2nd vertical toward target
    table.insert(list, {x = 0, y = (ty > G.y) and 1 or -1})
    -- 3rd + 4th: opposite directions (randomized)
    table.insert(list, {x = -list[1].x, y = 0})
    table.insert(list, {x = 0, y = -list[2].y})
    shuffleInPlace(list, 3)
    return list
end

local function ghostMove(G, priorities)

    if G.state == "respawning" then
        return
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

function blinkyAI(Px, Py, G)
    local priorities = buildPriorityList(Px, Py, G)
    ghostMove(G, priorities)
end

function pinkyAI(Px, Py, G, Pdirx, Pdiry)
    local targetX = Px + 4 * Pdirx
    local targetY = Py + 4 * Pdiry
    local priorities = buildPriorityList(targetX, targetY, G)
    ghostMove(G, priorities)
end

function inkyAI(Px, Py, G, Pdirx, Pdiry, blinky)
    local aheadX = Px + 2 * Pdirx
    local aheadY = Py + 2 * Pdiry
    local vectX = (aheadX - blinky.x) * 2
    local vectY = (aheadY - blinky.y) * 2
    local targetX = blinky.x + vectX
    local targetY = blinky.y + vectY
    local priorities = buildPriorityList(targetX, targetY, G)
    ghostMove(G, priorities)
end

function clydeAI(Px, Py, G)
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
    blinkyAI = blinkyAI,
    pinkyAI  = pinkyAI,
    inkyAI   = inkyAI,
    clydeAI  = clydeAI,
}