
function AI(Packman_x, Pacman_y, Ghosts)
    for i, ghost in ipairs(Ghosts) do
        -- Example AI logic for each ghost
        if ghost.x < Packman_x then
            ghost.x = ghost.x + 1  -- Move right towards Packman
        elseif ghost.x > Packman_x then
            ghost.x = ghost.x - 1  -- Move left towards Packman
        end
        
        if ghost.y < Pacman_y then
            ghost.y = ghost.y + 1  -- Move down towards Packman
        elseif ghost.y > Pacman_y then
            ghost.y = ghost.y - 1  -- Move up towards Packman
        end
    end


    print("AI function called")
end

return AI
