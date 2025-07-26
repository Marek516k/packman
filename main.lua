local love = require("love")
local gridSize = 32
local timer = 0
local score = 0
local interval = 0.3
local dir = "right" -- Initial direction
local Packman = {
    {x = 10, y = 10}}
local pointspwn_delay = 0
local gameover = false
local font_size
local song
local pointEatenSound
local death
local packman_image, point_image, wall_image, cherry_image, 
    bigPoint_image, blinky, inky, pinky, clyde --variables for images


function love.load()
    love.window.setTitle("Packman - temu edition")
    love.window.setMode(800, 600, { resizable = false, vsync = true })
end


function love.update()
    
end

function love.draw()
    
end