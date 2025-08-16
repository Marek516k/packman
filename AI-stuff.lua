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
        local j = love.math.random(startIndex, i)
        t[i], t[j] = t[j], t[i]
    end
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

local function buildPriorityList(Px, Py, G)
    local list = {}
    -- 1st: horizontal toward Pac-Man
    table.insert(list, {x = (Px > G.x) and 1 or -1, y = 0})
    -- 2nd: vertical toward Pac-Man
    table.insert(list, {x = 0, y = (Py > G.y) and 1 or -1})
    -- 3rd & 4th: the opposite directions
    table.insert(list, {x = -list[1].x, y = 0})
    table.insert(list, {x = 0, y = -list[2].y})
    shuffleInPlace(list, 3)
    return list
end

function blinkyAI(Px, Py, G)
    if G.state == "respawning" then
        return -- skip movement while ghost is paused at base
    end

    local revx, revy = -(G.lastdx or 0), -(G.lastdy or 0)
    local priorities = buildPriorityList(Px, Py, G)
    for _, d in ipairs(priorities) do
        -- skip reverse unless it’s the only way
        if not (d.x == revx and d.y == revy) or #priorities == 1 then
            if stepIfFree(G, d.x, d.y) then return end
        end
    end
end

function inkyAI(Px, Py, G)
    if G.state == "respawning" then
        return -- skip movement while ghost is paused at base
    end

    local revx, revy = -(G.lastdx or 0), -(G.lastdy or 0)
    local priorities = buildPriorityList(Px, Py, G)
    for _, d in ipairs(priorities) do
        if not (d.x == revx and d.y == revy) or #priorities == 1 then
            if stepIfFree(G, d.x, d.y) then return end
        end
    end
end

function pinkyAI(Px, Py, G)
    if G.state == "respawning" then
        return -- skip movement while ghost is paused at base
    end

    local revx, revy = -(G.lastdx or 0), -(G.lastdy or 0)
    local priorities = buildPriorityList(Px, Py, G)
    for _, d in ipairs(priorities) do
        if not (d.x == revx and d.y == revy) or #priorities == 1 then
            if stepIfFree(G, d.x, d.y) then return end
        end
    end
end

function clydeAI(Px, Py, G)
    if G.state == "respawning" then
        return -- skip movement while ghost is paused at base
    end

    local revx, revy = -(G.lastdx or 0), -(G.lastdy or 0)
    local priorities = buildPriorityList(Px, Py, G)
    for _, d in ipairs(priorities) do
        if not (d.x == revx and d.y == revy) or #priorities == 1 then
            if stepIfFree(G, d.x, d.y) then return end
        end
    end
end

return {
    blinkyAI = blinkyAI,
    inkyAI = inkyAI,
    pinkyAI = pinkyAI,
    clydeAI = clydeAI,
}