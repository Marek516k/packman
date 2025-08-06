love = require("love")

function CanMove(tempX, tempY)
    --prechecking if the player can move
    --[[
        return false
    else
        return true
    end ]]
    return true
end

function love.load()
    Level = require("Levels")

    Packman = {
        x = 8,
        y = 10
    }

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
    Font_size = love.graphics.newFont(25)
    Death = love.audio.newSource("sounds/Death.wav", "static")
    CherryAlert = love.audio.newSource("sounds/cherryAlert.wav", "static")
    Song = love.audio.newSource("sounds/Song.wav", "stream")
    Hit = love.audio.newSource("sounds/hit.wav", "static")
    CherryEaten = love.audio.newSource("sounds/cherryEaten.wav", "static")
    Point_eaten = love.audio.newSource("sounds/point_pickedup.wav", "static")
    Bigpoint_eaten = love.audio.newSource("sounds/bigpoint.wav", "static")
    Victory = love.audio.newSource("sounds/victory.wav", "static")
    GridSize = 32
    Lives = 2
    Points = 0
    Cherry_delay = 0
    Cherry_timer = 0
    Cherry_Pos = nil
    Cherry_con = false
    Timer = 0
    Interval = 0.4
    Gameover = false
    Gamestarted = false
    Invincibility = false
    love.window.setTitle("Pack man - but worse edition")
    love.window.setMode(800, 600, { resizable = false, vsync = true })
    Font_size = love.graphics.newFont(20)
    Packman_image = love.graphics.newImage("sprites/packman.png")
    Point_image = love.graphics.newImage("sprites/point.png")
    Wall_image = love.graphics.newImage("sprites/wall.png")
    Cherry = love.graphics.newImage("sprites/cherry.png")
    BigPoint_image = love.graphics.newImage("sprites/bigPoint.png")
    Blinky_image = love.graphics.newImage("sprites/blinky.png")
    Inky_image = love.graphics.newImage("sprites/inky.png")
    Pinky_image = love.graphics.newImage("sprites/pinky.png")
    Clyde_image = love.graphics.newImage("sprites/clyde.png")
    Collectibles = {}
    Invincibility_timer = 0
    local currentLevel = Level[1]
    for y, row in ipairs(currentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            if tile == "." or tile == "o" then
                table.insert(Collectibles, {
                    x = x,
                    y = y,
                    type = tile
                })
            end
        end
    end
end

function love.update(dt)
    if Gamestarted then
        Timer = Timer + dt
        Cherry_delay = Cherry_delay + dt -- Timer for spawning cherries
        if Timer >= Interval and not Gameover then

            Timer = 0
            local player = Packman
            local newX, newY = player.x, player.y
            local tempX, tempY = newX, newY

            if NextDir == "right" then
                tempX = tempX + 1
            end
            if NextDir == "left" then
                tempX = tempX - 1
                end
            if NextDir == "up" then
                tempY = tempY - 1
                end
            if NextDir == "down" then
                tempY = tempY + 1
            end

            if CanMove(tempX, tempY) then
                Dir = NextDir
            end

            if Dir == "right" then
                newX = newX + 1
            end
            if Dir == "left" then
                newX = newX - 1
            end
            if Dir == "up" then
                newY = newY - 1
            end
            if Dir == "down" then
                newY = newY + 1
            end

            player.x = newX
            player.y = newY
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
    local currentLevel = Level[1]
    for y, row in ipairs(currentLevel.map) do
        for x = 1, #row do
            local tile = row:sub(x, x)
            local drawX, drawY = (x - 1) * GridSize, (y - 1) * GridSize
            if tile == "#" then
                love.graphics.draw(Wall_image, drawX, drawY)             --elseif tile == "t" then  -- teleportation tile, not implemented yet
            elseif tile == "b" then
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
        love.audio.play(Song)
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
    --mby i will adjust this later, but for now it works
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
                Points = Points + 200 -- bonus for eating a ghost
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
            elseif point.type == "o" then
                Points = Points + 50
                Invincibility = true
            end
            table.remove(Collectibles, i)
        end
    end
end

-- need to add teleportation man :(, AI is gonna kill me, cherry spaws need minor adjustments to support more locations