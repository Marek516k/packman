local love = require("love")
local gridSize = 32
local timer = 0
local interval = 0.3
local dir = "right" -- Initial direction
local Packman = {
    {x = 10, y = 10}}
local cherryspwn_delay = 0
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


function love.load()
    love.window.setTitle("Packman - temu edition")
    love.window.setMode(800, 600, { resizable = false, vsync = true })
    font_size = love.graphics.newFont(20)
    packman_image = love.graphics.newImage("packman.aseprite")
    point_image = love.graphics.newImage("point.aseprite")
    wall_image = love.graphics.newImage("wall.aseprite")
    cherry_image = love.graphics.newImage("cherry.aseprite")
    bigPoint_image = love.graphics.newImage("bigPoint.aseprite")
    blinky_image = love.graphics.newImage("blinky.aseprite")
    inky_image = love.graphics.newImage("inky.aseprite")
    pinky_image = love.graphics.newImage("pinky.aseprite")
    clyde_image = love.graphics.newImage("clyde.aseprite")
    cherrySound = love.audio.newSource("", "static")
    song = love.audio.newSource("", "stream")
    death = love.audio.newSource("", "stream")
end


function love.update(dt)
    if not gameover then --checks if the game is over
        timer = timer + dt-- basic timer for the snake movement and ingame stuff
        if timer >= interval then
            timer = 0
        end
    end
    
end

function love.draw()
    love.graphics.setFont(font_size)
    love.graphics.setColor(1, 1, 1, 1) -- white
    local pointsText = "Points: " .. tostring(points)
    local textWidth = font_size:getWidth(pointsText)
    love.graphics.print(pointsText, love.graphics.getWidth() - textWidth - 10, 10)
    
end