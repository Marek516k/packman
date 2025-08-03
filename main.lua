local love = require("love")
local level1 = require("levels")
local gridSize = 32
local timer = 0
local interval = 0.3
local dir = "right" -- Initial direction
local Packman = {
    {x = 12, y = 9} -- Initial position of Packman
    }
local cherryspwn_delay = 0
cherry = nil -- Variable to hold the cherry position
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
local nextDir = "right"
ghosts = {
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0}
}
local bigPoint = nil
local pointPosition = nil -- Variable to hold the position of the points

function canMove(newX, newY)
    --actual wall logit and stuff soon since i need to make levels first anyways
    return true
end

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
        end
    end
end

function love.draw()
for y, row in ipairs(level1.map) do
    for x = 1, #row do
        local tile = row:sub(x, x)
        local drawX, drawY = (x - 1) * gridSize, (y - 1) * gridSize

        if tile == "#" then
            love.graphics.draw(wall_image, drawX, drawY)
        elseif tile == "." then
            love.graphics.draw(point_image, drawX, drawY)
        elseif tile == "C" then
            love.graphics.draw(cherry_image, drawX, drawY)
        elseif tile == "O" then
            love.graphics.draw(bigPoint_image, drawX, drawY)
        end
    end
end
    love.graphics.setFont(font_size)
    love.graphics.setColor(1, 1, 1, 1) -- white
    local pointsText = "Points: " .. tostring(points)
    local textWidth = font_size:getWidth(pointsText)
    love.graphics.print(pointsText, love.graphics.getWidth() - textWidth - 10, 10)
    local player = Packman[1]
    love.graphics.draw(packman_image, player.x * gridSize, player.y * gridSize)
    --[[if cherry then
        love.graphics.draw(cherry_image, cherry.x * gridSize, cherry.y * gridSize)
    end
    if pointPosition then
        love.graphics.draw(point_image, pointPosition.pointx * gridSize, pointPosition.pointy * gridSize)
    end
    if bigPoint then
        love.graphics.draw(bigPoint_image, bigPoint.x * gridSize, bigPoint.y * gridSize)
    end
    ]]
    if gameover then -- if the game is over it draws the game over screen
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

function love.checkColl(ghosts, points, cherries, bigPoint,point)
    --game collisions for ghosts,points and cherries
    for i = 1, #ghosts do
        local ghost = ghosts[i]
        if ghost.x == Packman[1].x and ghost.y == Packman[1].y then   
            if not invicibility then
                gameover = true
                love.audio.play(death)
            else
                points = points + 200 -- bonus for eating a ghost
            end
        end
    end
end
--[[to be implemented if i dont find a better way to do this
function pointPosition(pointx,pointy)
    -- Function to set the position of the points
    pointPosition = {pointx = nil, pointy = nil}
end

function bigPoint()
    -- Function to set the position of the big point
    bigPoint = {x = nil, y = nil}
    
end
]]