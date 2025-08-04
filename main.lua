local love = require("love")
local level = require("levels")
local currentLevel = level[5]
local Packman = {
    { x = 8, y = 10 } -- Initial position of Packman
}
local ghosts = {
    { x = 11, y = 10, type = "blinky" },
    { x = 11, y = 9, type = "inky" },
    { x = 10, y = 9, type = "pinky" },
    { x = 10, y = 10, type = "clyde" }
}
local gridSize = 32
local timer = 0
local interval = 0.5
local dir = "right" -- Initial direction
local cherryspwn_delay = 0
cherry = nil -- Variable to hold the cherry position
local gameover = false
local font_size = love.graphics.newFont(25)
local song
local cherrySound
local death
local packman_image, point_image, wall_image, cherry_image, 
    bigPoint_image, blinky_image, inky_image, pinky_image, clyde_image --variables for images
local lives = 2
local points = 0
local invicibility = false
local points = 0
local cherryspwn_delay = 0
local nextDir = "up"
local bigPoint = nil
local pointPosition = nil -- Variable to hold the position of the points

function canMove(tempX, tempY)
--prechecking if the player can move
--[[
        return false
    else
        return true
    end ]]
    return true
end

function love.load()
    love.window.setTitle("Packman - but worse edition")
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
    if not gameover then
        timer = timer + dt
        cherryspwn_delay = cherryspwn_delay + dt -- timer for spawning cherries
        if timer >= interval then
            timer = 0
            local player = Packman[1]
            local newX, newY = player.x, player.y
            local tempX, tempY = newX, newY
            if nextDir == "right" then tempX = tempX + 1 end
            if nextDir == "left" then tempX = tempX - 1 end
            if nextDir == "up" then tempY = tempY - 1 end
            if nextDir == "down" then tempY = tempY + 1 end
            if canMove(tempX, tempY) then
                dir = nextDir
            end
            if dir == "right" then newX = newX + 1 end
            if dir == "left" then newX = newX - 1 end
            if dir == "up" then newY = newY - 1 end
            if dir == "down" then newY = newY + 1 end
            player.x = newX
            player.y = newY
            --love.checkColl(ghosts)
        end
    end
end

function love.draw()
for y, row in ipairs(currentLevel.map) do
    for x = 1, #row do
        local tile = row:sub(x, x)
        local drawX, drawY = (x - 1) * gridSize, (y - 1) * gridSize
        if tile == "#" then
            love.graphics.draw(wall_image, drawX, drawY)
        elseif tile == "." then
            love.graphics.draw(point_image, drawX, drawY)
        elseif tile == "C" then
            love.graphics.draw(cherry_image, drawX, drawY)
        elseif tile == "o" then
            love.graphics.draw(bigPoint_image, drawX, drawY)
        elseif tile == "b" then 
            love.graphics.draw(blinky_image, drawX, drawY)
        elseif tile == "i" then
            love.graphics.draw(inky_image, drawX, drawY)
        elseif tile == "p" then
            love.graphics.draw(pinky_image, drawX, drawY)
        elseif tile == "c" then
            love.graphics.draw(clyde_image, drawX, drawY)
        elseif tile == "P" then
            local player = Packman[1]
            love.graphics.draw(packman_image, player.x * gridSize, player.y * gridSize)
            
        end
    end
end
    love.graphics.setFont(font_size)
    love.graphics.setColor(1, 0, 0, 1)
    local pointsText = "Points: " .. tostring(points)
    local textWidth = font_size:getWidth(pointsText)
    love.graphics.print(pointsText, love.graphics.getWidth() - textWidth - 10, 10)
    love.graphics.setColor(1, 1, 1, 1) -- reset color to back white
    if gameover then
        love.graphics.setFont(font_size)
        love.graphics.setColor(1, 0, 0, 1) --red
        love.graphics.printf("YOU LOST, press r to restart the game", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "d" then nextDir = "right" end
    if key == "a" then nextDir = "left" end
    if key == "w" then nextDir = "up" end
    if key == "s" then nextDir = "down" end
    if key == "r" and gameover then
        love.event.quit("restart")
        gameover = false
    end
end

function love.checkColl()
    --needs to be fixed cuz ts is bad
    for i = 1, #ghosts do
        local ghost = ghosts[i]
        if ghost.x == Packman[1].x and ghost.y == Packman[1].y then
            if not invicibility then
                gameover = true
                love.audio.play(death)
            else
                points = points + 200 -- bonus for eating a ghost
                return points
            end
        end
    end
end
-- need to add teleportation man :(, AI is gonna kill me