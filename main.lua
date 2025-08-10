love = require("love")

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

function Is_wall(x, y)

    for _, wall in ipairs(Walls) do
        if wall.x - 1 == x and wall.y - 1 == y then
            return true
        end
    end

    return false
end

function Level_control()

    Collectibles = {}
    Teleports = {}
    TeleportSpots = {}
    Walls = {}
    Number_of_collectibles = 0
    Cherry_delay = 0
    Cherry_timer = 0
    Cherry_Pos = nil
    Cherry_con = false

    Packman = {
        x = 8,
        y = 10,
        dir = nil
    }

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
            end
        end
    end
end

function love.load()

    Level = require("Levels")
    NextLevel = 1
    CurrentLevel = Level[NextLevel]

    Ghosts = {
        {
            x = 11,
            y = 10,
            type = "blinky"
        },
        {
            x = 11,
            y = 9,
            type = "inky"
        },
        {
            x = 10,
            y = 9,
            type = "pinky"
        },
        {
            x = 10,
            y = 10,
            type = "clyde"
        }
    }

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

    if Gamestarted then
        Timer = Timer + dt
        Cherry_delay = Cherry_delay + dt

        if Timer >= Interval and not Gameover then
            Timer = 0
            local player = Packman
            local x, y = player.x, player.y

            if NextDir then
                local dx, dy = Key_cashe(NextDir)
                if not Is_wall(x + dx, y + dy) then
                    player.dir = NextDir
                    NextDir = nil
                end
            end

            if player.dir then
                local dx, dy = Key_cashe(player.dir)
                if not Is_wall(x + dx, y + dy) then
                    player.x = x + dx
                    player.y = y + dy
                end
            end

            for _, tp in ipairs(Teleports) do
                if Packman.x + 1 == tp.x and Packman.y + 1 == tp.y then
                    Packman.x = tp.tx -1
                    Packman.y = tp.ty -1
                    break
                end
            end
        end

        if Cherry_delay > 10 and not Cherry_con then
            Cherry_con = true
            Cherry_Pos = {
                x = 10, y = 12
            }
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

        love.checkColl()
    end
end

function love.draw()

love.graphics.setColor(1, 1, 1) -- reset

    local player = Packman
    love.graphics.draw(Packman_image, player.x * GridSize, player.y * GridSize)
    
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

    for y, row in ipairs(CurrentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            local drawX, drawY = (x - 1) * GridSize, (y - 1) * GridSize
            if tile == "b" then
                love.graphics.draw(Blinky_image, drawX, drawY)
            elseif tile == "i" then
                love.graphics.draw(Inky_image, drawX, drawY)
            elseif tile == "p" then
                love.graphics.draw(Pinky_image, drawX, drawY)
            elseif tile == "c" then
                love.graphics.draw(Clyde_image, drawX, drawY)
            end
        end
    end

    love.graphics.setFont(Font_size)
    love.graphics.setColor(1, 0, 0, 1) --red
    local PointsText = "Points: " .. tostring(Points)
    local textWidth = Font_size:getWidth(PointsText)
    love.graphics.print(PointsText, love.graphics.getWidth() - textWidth - 10, 10)
    love.graphics.setColor(1, 1, 1, 1) -- reset color to back white

    if Gameover then
        love.graphics.setFont(Font_size)
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("YOU LOST, press r to restart the game", 0, love.graphics.getHeight() / 2 - 20,
        love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1, 1)
    end

    if not Gamestarted then
        if not Song:isPlaying() then
            love.audio.play(Song)
        end
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("Move to start the game", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
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

    if key == "r" and Gameover then
        love.event.quit("restart")
        Gameover = false
    end
end

function love.checkColl()

    for i = 1, #Ghosts do
        local ghost = Ghosts[i]
        if ghost.x == Packman.x and ghost.y == Packman.y then
            if not Invincibility then
                Lives = Lives - 1
                if Lives > 0 then
                    love.audio.play(Hit)
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
                Points = Points + 190 -- bonus for eating a ghost
                return Points
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
            end
            Number_of_collectibles = Number_of_collectibles - 1
            table.remove(Collectibles, i)

            if Number_of_collectibles == 204 then

                NextLevel = NextLevel + 1
                CurrentLevel = Level[NextLevel]
                love.audio.play(Victory)
                love.audio.stop(Song)
                Gamestarted = false
                Level_control()
            end
        end
    end
end

-- AI is gonna kill me, cherry spaws need minor adjustments to support more locations