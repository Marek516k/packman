local love = require("love")
local gridSize = 32
local timer = 0
local interval = 0.3
local dir = "right" -- Initial direction
local Packman = {
    {x = 12, y = 9} -- Initial position of Packman
    }
local cherryspwn_delay = 0
local cherry = nil -- Variable to hold the cherry position
local gameover = false
local font_size
local song
local cherrySound
local death
local packman_image, point_image, wall_image, cherry_image, 
    bigPoint_image, blinky_image, inky_image, pinky_image, clyde_image --variables for images
local lives = 3
local points = 0
local invicibility = false
local points = 0
local cherryspwn_delay = 0

function love.load()
    love.window.setTitle("Packman - temu edition")
    love.window.setMode(800, 600, { resizable = false, vsync = true })
    font_size = love.graphics.newFont(20)
    packman_image = love.graphics.newImage("packman.png")
    point_image = love.graphics.newImage("point.png")
    wall_image = love.graphics.newImage("wall.png")
    cherry_image = love.graphics.newImage("cherry.png")
    bigPoint_image = love.graphics.newImage("bigPoint.png")
    blinky_image = love.graphics.newImage("blinky.png")
    inky_image = love.graphics.newImage("inky.png")
    pinky_image = love.graphics.newImage("pinky.png")
    clyde_image = love.graphics.newImage("clyde.png")
    --[[cherrySound = love.audio.newSource("", "static")
    song = love.audio.newSource("", "stream")
    death = love.audio.newSource("", "stream")
    ]]
end

function love.update(dt)
    if not gameover then --checks if the game is over
        timer = timer + dt
        cherryspwn_delay = cherryspwn_delay + dt -- timer for spawning cherries
        if timer >= interval then
            timer = 0
            local player = Packman[1]
            local newX, newY = player.x, player.y
            if dir == "right" then newX = newX + 1 end
            if dir == "left" then newX = newX - 1 end
            if dir == "up" then newY = newY - 1 end
            if dir == "down" then newY = newY + 1 end
        if cherryspwn_delay >= 5 then -- spawn a cherry every 5 seconds
            cherryspwn_delay = 0
            cherry = {x = math.random(0, 24), y = math.random(0, 18)} -- random position for the cherry
            --cherrySound:play() -- play sound when cherry spawns
        end
        end
    end
end

function love.draw()
    love.graphics.setFont(font_size)
    love.graphics.setColor(1, 1, 1, 1) -- white
    local pointsText = "Points: " .. tostring(points)
    local textWidth = font_size:getWidth(pointsText)
    love.graphics.print(pointsText, love.graphics.getWidth() - textWidth - 10, 10)
    local player = Packman[1]
    love.graphics.draw(packman_image, player.x * gridSize, player.y * gridSize)
    if cherry then
        love.graphics.draw(cherry_image, cherry.x * gridSize, cherry.y * gridSize)
    end

    if gameover then -- if the game is over it draws the game over screen
        love.graphics.setFont(font_size)
        love.graphics.setColor(1, 0, 0, 1) --red
        love.graphics.printf("YOU LOST, press r to restart the game", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
end

--simple key controls
function love.keypressed(key)
    if key == "d" and dir ~= "left" then dir = "right" end
    if key == "a" and dir ~= "right" then dir = "left" end
    if key == "w" and dir ~= "down" then dir = "up" end
    if key == "s" and dir ~= "up" then dir = "down" end
    if key == "r" and gameover then
        love.event.quit("restart") -- Restart the game
        gameover = false
    end
end