function _init()
    game_over=false
    make_walls()
    make_player()
    make_ducklings()
    following_ducklings = {}
    player_trail = {}
    trail_length = 110
    player_moved = false
end

function _update()
    if (not game_over) then
        move_player()
        if player_moved then
            update_player_trail()
        end
        check_hit()
        check_duckling_collision()
        update_following_ducklings()
    end
end

function _draw()
    cls()
    draw_walls()
    draw_ducklings()
    draw_player()
end

function make_walls()
    walls = {}
    walls[1] = {x=0, y=0, width=2, height=120} -- left wall
    walls[2] = {x=120, y=0, width=2, height=122} -- right wall
    walls[3] = {x=0, y=0, width=120, height=2} -- top wall
    walls[4] = {x=0, y=120, width=120, height=2} -- bottom wall
end

function draw_walls()
    for _, wall in ipairs(walls) do
        rectfill(wall.x, wall.y, wall.x + wall.width, wall.y + wall.height)
    end
end

function check_player_wall_collision()
    for _, wall in ipairs(walls) do
        if player.x >= wall.x and player.x <= wall.x + wall.width and player.y >= wall.y and player.y <= wall.y + wall.height then
            return true
        end
    end
    return false
end

function make_player()
    player = {}
    player.x = 64
    player.y = 64
    player.speed = 1
    player.direction = "right"
    player.left_sprite = 5
    player.right_sprite = 6
    player.up_sprite = 7
    player.down_sprite = 8
    player.current_sprite = player.right_sprite
end

function move_player()
    local new_x = player.x
    local new_y = player.y
    local old_x = player.x
    local old_y = player.y
    
    if btn(0) then
        new_x = player.x - 1
        player.current_sprite = player.left_sprite
    end
    if btn(1) then
        new_x = player.x + 1
        player.current_sprite = player.right_sprite
    end
    if btn(2) then
        new_y = player.y - 1
        player.current_sprite = player.up_sprite
    end
    if btn(3) then
        new_y = player.y + 1
        player.current_sprite = player.down_sprite
    end
    
    -- Check collision before applying movement
    if not check_wall_collision(new_x, new_y) then
        player.x = new_x
        player.y = new_y
    end
    
    -- Check if player actually moved
    player_moved = (player.x ~= old_x or player.y ~= old_y)
end

function update_player_trail()
    -- Add current player position to trail
    add(player_trail, {x=player.x, y=player.y})
    
    -- Keep trail at maximum length
    if #player_trail > trail_length then
        deli(player_trail, 1)
    end
end

function check_wall_collision(x, y)
    -- Player sprite is 8x8 pixels
    local player_size = 8
    
    for _, wall in ipairs(walls) do
        -- Check if player bounding box overlaps with wall
        if x < wall.x + wall.width and 
           x + player_size > wall.x and
           y < wall.y + wall.height and
           y + player_size > wall.y then
            return true
        end
    end
    return false
end

function draw_player()
    spr(player.current_sprite, player.x, player.y)
end

function check_hit()
    for _, wall in ipairs(walls) do
        if player.x + 7 >= wall.x and player.x + 7 <= wall.x + wall.width and player.y + 7 >= wall.y and player.y + 7 <= wall.y + wall.height then
            print("\n\nhit wall")
        end
    end
end

function make_ducklings()
    total_ducklings = 10
    current_ducklings = 0
    ducklings = {}
    ducklings.left_sprite = 9
    ducklings.right_sprite = 10
    ducklings.down_sprite = 11
    ducklings.up_sprite = 12
    for i=1, total_ducklings do
        ducklings[i] = {}
        ducklings[i].x = flr(rnd(112 - 2)) + 2
        ducklings[i].y = flr(rnd(112 - 2)) + 2
        ducklings[i].speed = flr(rnd(2))
        ducklings[i].direction = flr(rnd(4))
        if ducklings[i].direction == 0 then
            ducklings[i].current_sprite = ducklings.left_sprite
        elseif ducklings[i].direction == 1 then
            ducklings[i].current_sprite = ducklings.right_sprite
        elseif ducklings[i].direction == 2 then
            ducklings[i].current_sprite = ducklings.down_sprite
        elseif ducklings[i].direction == 3 then
            ducklings[i].current_sprite = ducklings.up_sprite
        end
    end
end

function draw_ducklings()
    -- Draw free ducklings
    for _, duckling in ipairs(ducklings) do
        if duckling.x and duckling.y then
            spr(duckling.current_sprite, duckling.x, duckling.y)
        end
    end
    
    -- Draw following ducklings
    for _, duckling in ipairs(following_ducklings) do
        spr(duckling.current_sprite, duckling.x, duckling.y)
    end
end

function check_duckling_collision()
    -- Player and ducklings are both 8x8 pixels
    local player_size = 8
    local duckling_size = 8
    
    -- Iterate backwards to safely remove items from array
    for i = #ducklings, 1, -1 do
        local duckling = ducklings[i]
        -- Skip if this is not a duckling object (like sprite properties)
        if duckling.x and duckling.y and not duckling.following then
            -- Check if player bounding box overlaps with duckling bounding box
            if player.x < duckling.x + duckling_size and 
               player.x + player_size > duckling.x and
               player.y < duckling.y + duckling_size and
               player.y + player_size > duckling.y then
                -- Mark duckling as following and add to following list
                duckling.following = true
                add(following_ducklings, duckling)
                del(ducklings, duckling)
            end
        end
    end
end

function update_following_ducklings()
    local follow_distance = 5  -- Distance between ducklings in the line
    local follow_speed = 1      -- Speed at which ducklings move toward their target
    local catch_up_threshold = 3  -- Distance threshold for ducklings to keep moving when player stops
    
    for i = 1, #following_ducklings do
        local duckling = following_ducklings[i]
        local target_index = #player_trail - (i * follow_distance)
        
        if target_index > 0 and target_index <= #player_trail then
            local target = player_trail[target_index]
            
            -- Calculate direction to target
            local dx = target.x - duckling.x
            local dy = target.y - duckling.y
            local distance = abs(dx) + abs(dy)
            
            -- Only move duckling if player moved OR duckling is far from target (catching up)
            local should_move = player_moved or distance > catch_up_threshold
            
            if should_move then
                -- Move duckling toward target
                if abs(dx) > follow_speed then
                    if dx > 0 then
                        duckling.x = duckling.x + follow_speed
                    else
                        duckling.x = duckling.x - follow_speed
                    end
                else
                    duckling.x = target.x
                end
                
                if abs(dy) > follow_speed then
                    if dy > 0 then
                        duckling.y = duckling.y + follow_speed
                    else
                        duckling.y = duckling.y - follow_speed
                    end
                else
                    duckling.y = target.y
                end
                
                -- Update sprite based on movement direction
                if abs(dx) > abs(dy) then
                    if dx > 0 then
                        duckling.current_sprite = ducklings.right_sprite
                    else
                        duckling.current_sprite = ducklings.left_sprite
                    end
                else
                    if dy > 0 then
                        duckling.current_sprite = ducklings.down_sprite
                    else
                        duckling.current_sprite = ducklings.up_sprite
                    end
                end
            end
        end
    end
end