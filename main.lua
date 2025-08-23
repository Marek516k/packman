Love = require("love")
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

function Love.keypressed(key)

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
        Love.event.quit("restart")
        Gameover = false
        Trueend = false
    end
end

function Teleport_handler(entity)
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
        Love.audio.play(Victory)
        Love.audio.stop(Song)
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
        x = 8, y = 10,
        dir = nil,
        dx = 0, dy = 0
    }

    Ghosts = {
        {
            x = 11, y = 10,
            baseX = 11, baseY = 10,
            type = "blinky",
            state = "normal",
            dx = 0, dy = 0
        },
        {
            x = 12, y = 10,
            baseX = 12, baseY = 10,
            type = "inky",
            state = "normal",
            dx = 0, dy = 0
        },
        {
            x = 13, y = 10,
            baseX = 13, baseY = 10,
            type = "pinky",
            state = "normal",
            dx = 0, dy = 0
        },
        {
            x = 14, y = 10,
            baseX = 14, baseY = 10,
            type = "clyde",
            state = "normal",
            dx = 0, dy = 0
        }
    }
    if NextLevel == 5 then
        Ghosts = {
            {
                x = 13, y = 12,
                baseX = 13, baseY = 12,
                type = "blinky",
                state = "normal",
                dx = 0, dy = 0
            },
            {
                x = 13, y = 11,
                baseX = 13, baseY = 11,
                type = "inky",
                state = "normal",
                dx = 0, dy = 0
            },
            {
                x = 10, y = 11,
                baseX = 10, baseY = 11,
                type = "pinky",
                state = "normal",
                dx = 0, dy = 0
            },
            {
                x = 10, y = 12,
                baseX = 10, baseY = 12,
                type = "clyde",
                state = "normal",
                dx = 0, dy = 0
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

function Love.load()

    Trueend = false
    NextLevel = 1
    CurrentLevel = Level[NextLevel]

    Love.window.setTitle("Pack man - but worse edition")
    Love.window.setMode(800, 600, { resizable = false, vsync = true })
    Font_size = Love.graphics.newFont(25)
    Death = Love.audio.newSource("sounds/Death.wav", "static")
    CherryAlert = Love.audio.newSource("sounds/cherryAlert.wav", "static")
    Song = Love.audio.newSource("sounds/Song.wav", "stream")
    Song:setLooping(true)
    Hit = Love.audio.newSource("sounds/hit.wav", "static")
    CherryEaten = Love.audio.newSource("sounds/cherryEaten.wav", "static")
    Point_eaten = Love.audio.newSource("sounds/point_pickedup.wav", "static")
    Bigpoint_eaten = Love.audio.newSource("sounds/bigpoint.wav", "static")
    Victory = Love.audio.newSource("sounds/victory.wav", "static")
    Ghost_death = Love.audio.newSource("sounds/ghost_death.wav", "static")
    Packman_image = Love.graphics.newImage("sprites/packman.png")
    Point_image = Love.graphics.newImage("sprites/point.png")
    Wall_image = Love.graphics.newImage("sprites/wall.png")
    Cherry = Love.graphics.newImage("sprites/cherry.png")
    BigPoint_image = Love.graphics.newImage("sprites/bigPoint.png")
    Blinky_image = Love.graphics.newImage("sprites/blinky.png")
    Inky_image = Love.graphics.newImage("sprites/inky.png")
    Pinky_image = Love.graphics.newImage("sprites/pinky.png")
    Clyde_image = Love.graphics.newImage("sprites/clyde.png")
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

function Love.update(dt)

    if Gamestarted and not Trueend then
        Timer = Timer + dt
        Cherry_delay = Cherry_delay + dt

        if Timer >= Interval and not Gameover and not Trueend then
            Timer = 0
            local x, y = Packman.x, Packman.y

            if NextDir then
                local dx, dy = Key_cashe(NextDir)
                if not Is_wall(x + dx, y + dy) then
                    Packman.dir = NextDir
                    NextDir = nil
                end
            end

            if Packman.dir then
                local dx, dy = Key_cashe(Packman.dir)
                if not Is_wall(x + dx, y + dy) then
                    Packman.x = x + dx
                    Packman.y = y + dy
                else
                    Packman.dx = 0
                    Packman.dy = 0
                end
            end

            Teleport_handler(Packman)

            blinkyAI(Packman.x, Packman.y, Ghosts[1])
            inkyAI(Packman.x, Packman.y, Ghosts[2], Packman.dx, Packman.dy, Ghosts[1])
            pinkyAI(Packman.x, Packman.y, Ghosts[3], Packman.dx, Packman.dy)
            clydeAI(Packman.x, Packman.y, Ghosts[4])

            for _, ghost in ipairs(Ghosts) do
                Teleport_handler(ghost)
            end
        end

        if Cherry_delay > 10 and not Cherry_con and #CherrySpots > 0 then
            Cherry_con = true
            local spot = CherrySpots[Love.math.random(#CherrySpots)] -- náhodné místo
            Cherry_Pos = { x = spot.x, y = spot.y }
            Cherry_timer = 0
        end

        if Cherry_con then
            Love.audio.play(CherryAlert)
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

        CheckColl()
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

function Love.draw()

Love.graphics.setColor(1, 1, 1) -- reset

    Love.graphics.draw(Packman_image, Packman.x * GridSize, Packman.y * GridSize)
    
    if Cherry_con and Cherry_Pos and not Gameover then
        Love.graphics.draw(Cherry, Cherry_Pos.x * GridSize, Cherry_Pos.y * GridSize)
    end

    for _, point in ipairs(Collectibles) do
        local drawX = (point.x - 1) * GridSize
        local drawY = (point.y - 1) * GridSize
        if point.type == "." then
            Love.graphics.draw(Point_image, drawX, drawY)
        elseif point.type == "o" then
            Love.graphics.draw(BigPoint_image, drawX, drawY)
        end
    end

    for _, wall in ipairs(Walls) do
        local drawX = (wall.x - 1) * GridSize
        local drawY = (wall.y - 1) * GridSize
        Love.graphics.draw(Wall_image, drawX, drawY)
    end

    for _, ghost in ipairs(Ghosts) do
        local drawX = (ghost.x) * GridSize
        local drawY = (ghost.y) * GridSize
        if ghost.type == "blinky" then
            Love.graphics.draw(Blinky_image, drawX, drawY)
        elseif ghost.type == "inky" then
            Love.graphics.draw(Inky_image, drawX, drawY)
        elseif ghost.type == "pinky" then
            Love.graphics.draw(Pinky_image, drawX, drawY)
        elseif ghost.type == "clyde" then
            Love.graphics.draw(Clyde_image, drawX, drawY)
        end
    end

    Love.graphics.setFont(Font_size)
    Love.graphics.setColor(1, 0, 0, 1) --red
    local PointsText = "Points: " .. tostring(Points)
    local textWidth = Font_size:getWidth(PointsText)
    Love.graphics.print(PointsText, Love.graphics.getWidth() - textWidth - 10, 10)
    Love.graphics.setColor(1, 1, 1, 1) -- reset color to back white

    if Gameover and not Trueend then
        Love.graphics.setFont(Font_size)
        Love.graphics.setColor(0, 1, 0, 1)
        Love.graphics.printf("YOU LOST, press r to restart the game", 0, Love.graphics.getHeight() / 2 - 20,
        Love.graphics.getWidth(), "center")
        Love.graphics.setColor(1, 1, 1, 1)
    end

    if not Gamestarted and not Trueend then
        if not Song:isPlaying() then
            Love.audio.play(Song)
        end

        Love.graphics.setColor(0, 1, 0, 1)
        Love.graphics.printf("Move to start the game", 0, Love.graphics.getHeight() / 2 - 20, Love.graphics.getWidth(), "center")
        Love.graphics.setColor(1, 1, 1, 1)
    end

    if Trueend then
        Love.graphics.setFont(Font_size)
        Love.graphics.setColor(0, 1, 0, 1)
        Love.graphics.printf("Thank you for playing whatever this is but it ends right here .... unless you press r and do it all over again :D", 0, Love.graphics.getHeight() / 2 - 20,
        Love.graphics.getWidth(), "center")
        Love.graphics.setColor(1, 1, 1, 1)
    end
end

function CheckColl()
    Packman.prevX = Packman.x
    Packman.prevY = Packman.y

    for _, ghost in ipairs(Ghosts) do
        ghost.prevX = ghost.x
        ghost.prevY = ghost.y
        ghost.x = ghost.x + (ghost.dx or 0)
        ghost.y = ghost.y + (ghost.dy or 0)
    end

    for _, ghost in ipairs(Ghosts) do
        if Packman.x == ghost.x and Packman.y == ghost.y then --exact cordinates collision
            if not Invincibility then
                Lives = Lives - 1

                if Lives > 0 then
                    Love.audio.play(Hit)
                        Invincibility = true
                        Invincibility_timer = 2
                        Packman = {
                            x = 8,
                            y = 10,
                            dx = 0,
                            dy = 0
                        }
                end

                if Lives == 0 then
                    Love.audio.stop(Song)
                    Love.audio.play(Death)
                    Gameover = true
                end

                else
                    Points = Points + 200 -- bonus for eating a ghost
                    Love.audio.play(Ghost_death)
                    ghost.x = ghost.baseX
                    ghost.y = ghost.baseY
                    ghost.state = "respawning"
                    ghost.respawnTimer = 2
                end
            end

        if Packman.x == ghost.prevX and Packman.y == ghost.prevY and
           Packman.prevX == ghost.x and Packman.prevY == ghost.y then --head on collision
            if not Invincibility then
                Lives = Lives - 1

                if Lives > 0 then
                    Love.audio.play(Hit)
                        Invincibility = true
                        Invincibility_timer = 2
                        Packman = {
                            x = 8,
                            y = 10,
                            dx = 0,
                            dy = 0
                        }
                end

                if Lives == 0 then
                    Love.audio.stop(Song)
                    Love.audio.play(Death)
                    Gameover = true
                end

                else
                    Points = Points + 200 -- bonus for eating a ghost
                    Love.audio.play(Ghost_death)
                    ghost.x = ghost.baseX
                    ghost.y = ghost.baseY
                    ghost.state = "respawning"
                    ghost.respawnTimer = 2
                end
            end
        end

    if Cherry_con and Cherry_Pos.x == Packman.x and Cherry_Pos.y == Packman.y then
        Love.audio.play(CherryEaten)
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
                Love.audio.play(Point_eaten)

            elseif point.type == "o" then
                Points = Points + 50
                Love.audio.play(Bigpoint_eaten)
                Invincibility = true
                Invincibility_timer = 6
            end

            Number_of_collectibles = Number_of_collectibles - 1
            table.remove(Collectibles, i)

            if Number_of_collectibles == 200 then
                NextLevel = NextLevel + 1
                CurrentLevel = Level[NextLevel]
                Love.audio.stop(Song)
                Gamestarted = false
                Level_control()
                return
            end
        end
    end
end
--fix AI Pdirs and hope that i didnt break collision detection