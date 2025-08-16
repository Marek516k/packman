love = require("love")
Level = require("Levels")
AI = require("AI-stuff")

function Key_cashe(dir)

    if dir == "right" then return 1, 0
    end

    if dir == "left" then return -1, 0
    end

    if dir == "up" then return 0, -1
    end

    if dir == "down" then return 0, 1
    end

    return 0, 0
end

function handleTeleport(entity)
    for _, tp in ipairs(Teleports) do
        if entity.x + 1 == tp.x and entity.y + 1 == tp.y then
            entity.x = tp.tx - 1
            entity.y = tp.ty - 1
            break
        end
    end
end

function Is_wall(x, y)

    for _, wall in ipairs(Walls) do
        if wall.x - 1 == x and wall.y - 1 == y then
            return true
        end
    end

    return false
end

function Ghost_pos(ghost)
    ghost.x = ghost.baseX
    ghost.y = ghost.baseY
    ghost.state = "normal"
    ghost.respawnTimer = nil
end

function Level_control()

    if NextLevel == 6 then
        love.audio.play(Victory)
        love.audio.stop(Song)
        Trueend = true
        Gamestarted = false
    end

    Collectibles = {}
    Teleports = {}
    TeleportSpots = {}
    Walls = {}
    Number_of_collectibles = 0
    Cherry_delay = 0
    Cherry_timer = 0
    Cherry_Pos = nil
    Cherry_con = false
    CherrySpots = {}
    
    Packman = {
        x = 8,
        y = 10,
        dir = nil
    }

    Ghosts = {
        {
            x = 11, y = 10,
            baseX = 11, baseY = 10,
            type = "blinky",
            state = "normal"
        },
        {
            x = 11, y = 9,
            baseX = 11, baseY = 9,
            type = "inky",
            state = "normal"
        },
        {
            x = 10, y = 9,
            baseX = 10, baseY = 9,
            type = "pinky",
            state = "normal"
        },
        {
            x = 10, y = 10,
            baseX = 10, baseY = 10,
            type = "clyde",
            state = "normal"
        }
    }
    if NextLevel == 5 then
        Ghosts = {
            {
                x = 13, y = 12,
                baseX = 13, baseY = 12,
                type = "blinky",
                state = "normal"
            },
            {
                x = 13, y = 11,
                baseX = 13, baseY = 11,
                type = "inky",
                state = "normal"
            },
            {
                x = 10, y = 11,
                baseX = 10, baseY = 11,
                type = "pinky",
                state = "normal"
            },
            {
                x = 10, y = 12,
                baseX = 10, baseY = 12,
                type = "clyde",
                state = "normal"
            }
        }
    end

    for y, row in ipairs(CurrentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            if tile == "t" then
                table.insert(TeleportSpots, {
                    x = x,
                    y = y
                })
            end
        end
    end

    for i = 1, #TeleportSpots, 2 do
        local a = TeleportSpots[i]
        local b = TeleportSpots[i + 1]
        if b then

            table.insert(Teleports, {
                x = a.x,
                y = a.y,
                tx = b.x,
                ty = b.y
            })

            table.insert(Teleports, {
                x = b.x,
                y = b.y,
                tx = a.x,
                ty = a.y
            })
        end
    end

    for y, row in ipairs(CurrentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            if tile == "." or tile == "o" then
                Number_of_collectibles = Number_of_collectibles + 1
                table.insert(Collectibles, {
                    x = x,
                    y = y,
                    type = tile
                })
            end
        end
    end

    for y, row in ipairs(CurrentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            if tile == "#" then
                table.insert(Walls, {
                    x = x,
                    y = y
                })
            elseif tile == "C" then
                table.insert(CherrySpots, { x = x - 1, y = y - 1 })
            end
        end
    end
end

function love.load()

    Trueend = false
    NextLevel = 5
    CurrentLevel = Level[NextLevel]

    love.window.setTitle("Pack man - but worse edition")
    love.window.setMode(800, 600, { resizable = false, vsync = true })
    Font_size = love.graphics.newFont(25)
    Death = love.audio.newSource("sounds/Death.wav", "static")
    CherryAlert = love.audio.newSource("sounds/cherryAlert.wav", "static")
    Song = love.audio.newSource("sounds/Song.wav", "stream")
    Song:setLooping(true)
    Hit = love.audio.newSource("sounds/hit.wav", "static")
    CherryEaten = love.audio.newSource("sounds/cherryEaten.wav", "static")
    Point_eaten = love.audio.newSource("sounds/point_pickedup.wav", "static")
    Bigpoint_eaten = love.audio.newSource("sounds/bigpoint.wav", "static")
    Victory = love.audio.newSource("sounds/victory.wav", "static")
    Ghost_death = love.audio.newSource("sounds/ghost_death.wav", "static")
    Packman_image = love.graphics.newImage("sprites/packman.png")
    Point_image = love.graphics.newImage("sprites/point.png")
    Wall_image = love.graphics.newImage("sprites/wall.png")
    Cherry = love.graphics.newImage("sprites/cherry.png")
    BigPoint_image = love.graphics.newImage("sprites/bigPoint.png")
    Blinky_image = love.graphics.newImage("sprites/blinky.png")
    Inky_image = love.graphics.newImage("sprites/inky.png")
    Pinky_image = love.graphics.newImage("sprites/pinky.png")
    Clyde_image = love.graphics.newImage("sprites/clyde.png")
    GridSize = 32
    Lives = 2
    Points = 0
    Timer = 0
    Interval = 0.4
    Gameover = false
    Gamestarted = false
    Invincibility = false
    Invincibility_timer = 0
    Level_control()
end

function love.update(dt)

    if Gamestarted and not Trueend then
        Timer = Timer + dt
        Cherry_delay = Cherry_delay + dt

        if Timer >= Interval and not Gameover and not Trueend then
            Timer = 0
            local Player = Packman
            local x, y = Player.x, Player.y

            if NextDir then
                local dx, dy = Key_cashe(NextDir)
                if not Is_wall(x + dx, y + dy) then
                    Player.dir = NextDir
                    NextDir = nil
                end
            end

            if Player.dir then
                local dx, dy = Key_cashe(Player.dir)
                if not Is_wall(x + dx, y + dy) then
                    Player.x = x + dx
                    Player.y = y + dy
                end
            end

            handleTeleport(Packman)

            blinkyAI(Packman.x, Packman.y, Ghosts[1])
            inkyAI(Packman.x, Packman.y, Ghosts[2])
            pinkyAI(Packman.x, Packman.y, Ghosts[3])
            clydeAI(Packman.x, Packman.y, Ghosts[4])
            for _, ghost in ipairs(Ghosts) do
                handleTeleport(ghost)
            end
        end

        if Cherry_delay > 10 and not Cherry_con and #CherrySpots > 0 then
            Cherry_con = true
            local spot = CherrySpots[love.math.random(#CherrySpots)] -- náhodné místo
            Cherry_Pos = { x = spot.x, y = spot.y }
            Cherry_timer = 0
        end

        if Cherry_con then
            Cherry_timer = Cherry_timer + dt
            if Cherry_timer > 5 then
                Cherry_Pos = nil
                Cherry_con = false
                Cherry_delay = 0
                Cherry_timer = 0
            end
        end

        if Invincibility then
            Invincibility_timer = Invincibility_timer - dt
            if Invincibility_timer <= 0 then
                Invincibility = false
            end
        end

        checkColl()
        for _, ghost in ipairs(Ghosts) do
            if ghost.state == "respawning" and ghost.respawnTimer then
                ghost.respawnTimer = ghost.respawnTimer - dt
                if ghost.respawnTimer <= 0 then
                    ghost.state = "normal"
                    ghost.respawnTimer = nil
                end
            end
        end
    end
end

function love.draw()

love.graphics.setColor(1, 1, 1) -- reset

    local Player = Packman
    love.graphics.draw(Packman_image, Player.x * GridSize, Player.y * GridSize)
    
    if Cherry_con and Cherry_Pos and not Gameover then
        love.graphics.draw(Cherry, Cherry_Pos.x * GridSize, Cherry_Pos.y * GridSize)
        love.audio.play(CherryAlert)
    end

    for _, point in ipairs(Collectibles) do
        local drawX = (point.x - 1) * GridSize
        local drawY = (point.y - 1) * GridSize
        if point.type == "." then
            love.graphics.draw(Point_image, drawX, drawY)
        elseif point.type == "o" then
            love.graphics.draw(BigPoint_image, drawX, drawY)
        end
    end

    for _, wall in ipairs(Walls) do
        local drawX = (wall.x - 1) * GridSize
        local drawY = (wall.y - 1) * GridSize
        love.graphics.draw(Wall_image, drawX, drawY)
    end

    for _, ghost in ipairs(Ghosts) do
        local drawX = (ghost.x) * GridSize
        local drawY = (ghost.y) * GridSize
        if ghost.type == "blinky" then
            love.graphics.draw(Blinky_image, drawX, drawY)
        elseif ghost.type == "inky" then
            love.graphics.draw(Inky_image, drawX, drawY)
        elseif ghost.type == "pinky" then
            love.graphics.draw(Pinky_image, drawX, drawY)
        elseif ghost.type == "clyde" then
            love.graphics.draw(Clyde_image, drawX, drawY)
        end
    end

    love.graphics.setFont(Font_size)
    love.graphics.setColor(1, 0, 0, 1) --red
    local PointsText = "Points: " .. tostring(Points)
    local textWidth = Font_size:getWidth(PointsText)
    love.graphics.print(PointsText, love.graphics.getWidth() - textWidth - 10, 10)
    love.graphics.setColor(1, 1, 1, 1) -- reset color to back white

    if Gameover and not Trueend then
        love.graphics.setFont(Font_size)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("YOU LOST, press r to restart the game", 0, love.graphics.getHeight() / 2 - 20,
        love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end

    if not Gamestarted and not Trueend then
        if not Song:isPlaying() then
            love.audio.play(Song)
        end

        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("Move to start the game", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end

    if Trueend then
        love.graphics.setFont(Font_size)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("Thank you for playing whatever this is but it ends right here .... unless you press r and do it all over again :D", 0, love.graphics.getHeight() / 2 - 20,
        love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key)

    if key == "d" then
        NextDir = "right"
        Gamestarted = true
    end

    if key == "a" then
        NextDir = "left"
        Gamestarted = true
    end
    
    if key == "w" then
        NextDir = "up"
        Gamestarted = true
    end

    if key == "s" then
        NextDir = "down"
        Gamestarted = true
    end

    if key == "r" and (Gameover or Trueend) then
        love.event.quit("restart")
        Gameover = false
        Trueend = false
    end
end

function checkColl()

    for i = 1, #Ghosts do
        local ghost = Ghosts[i]
        if Packman.x == ghost.x and Packman.y == ghost.y then
            if not Invincibility then
                Lives = Lives - 1

                if Lives > 0 then
                    love.audio.play(Hit)
                        Invincibility = true
                        Invincibility_timer = 2
                end

                Packman = {
                    x = 8,
                    y = 10
                }

                if Lives == 0 then
                    love.audio.stop(Song)
                    love.audio.play(Death)
                    Gameover = true
                end

            else
                Points = Points + 200 -- bonus for eating a ghost
                love.audio.play(Ghost_death)
                ghost.x = ghost.baseX
                ghost.y = ghost.baseY
                ghost.state = "respawning"
                ghost.respawnTimer = 2
            end
        end
    end

    if Cherry_con and Cherry_Pos.x == Packman.x and Cherry_Pos.y == Packman.y then
        love.audio.play(CherryEaten)
        Points = Points + 100
        Cherry_delay = 0
        Cherry_con = false
        Cherry_timer = 0
        Cherry_Pos = nil
    end

    for i = #Collectibles, 1, -1 do
        local point = Collectibles[i]
        if point.x - 1 == Packman.x and point.y - 1 == Packman.y then

            if point.type == "." then             
                Points = Points + 10
                love.audio.play(Point_eaten)

            elseif point.type == "o" then
                Points = Points + 50
                love.audio.play(Bigpoint_eaten)
                Invincibility = true
                Invincibility_timer = 6
            end

            Number_of_collectibles = Number_of_collectibles - 1
            table.remove(Collectibles, i)

            if Number_of_collectibles == 0 then
                NextLevel = NextLevel + 1
                CurrentLevel = Level[NextLevel]
                love.audio.stop(Song)
                Gamestarted = false
                Level_control()
                return

            end
        end
    end
end