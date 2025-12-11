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
        move_free_ducklings()
        check_hit()
        check_duckling_collision()
        update_following_ducklings()
    end
end

function _draw()
    cls(12)
    -- cls()
    draw_walls()
    draw_ducklings()
    draw_player()
end

function make_walls()
    walls = {}
    walls[1] = {x=0, y=0, width=2, height=128} -- left wall
    walls[2] = {x=125, y=0, width=2, height=128} -- right wall
    walls[3] = {x=0, y=0, width=128, height=2} -- top wall
    walls[4] = {x=0, y=125, width=128, height=2} -- bottom wall
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
    -- player.up_sprite = 7
    player.up_sprite_1 = 23
    player.up_sprite_2 = 39
    -- player.down_sprite = 8
    player.down_sprite_1 = 24
    player.down_sprite_2 = 40
    player.current_sprite = player.right_sprite
    
    player.current_direction_pixel_count = 0
    player.sprite_change_interval = 6
end

function move_player()
    local new_x = player.x
    local new_y = player.y
    local old_x = player.x
    local old_y = player.y

    local old_sprite = player.current_sprite
    local old_direction = player.direction
    
    if btn(0) then
        new_x = player.x - 1
        player.direction = "left"
        player.current_sprite = player.left_sprite
    end
    if btn(1) then
        new_x = player.x + 1
        player.direction = "right"
        player.current_sprite = player.right_sprite
    end
    if btn(2) then
        new_y = player.y - 1
        player.direction = "up"
        if player.current_direction_pixel_count >= player.sprite_change_interval then
            player.current_direction_pixel_count = 0
            if player.current_sprite == player.up_sprite_1 then
                player.current_sprite = player.up_sprite_2
            else
                player.current_sprite = player.up_sprite_1
            end
        end
    end
    if btn(3) then
        new_y = player.y + 1
        player.direction = "down"
        if player.current_direction_pixel_count >= player.sprite_change_interval then
            player.current_direction_pixel_count = 0
            if player.current_sprite == player.down_sprite_1 then
                player.current_sprite = player.down_sprite_2
            else
                player.current_sprite = player.down_sprite_1
            end
        end
    end

    if player.direction ~= old_direction then
        player.current_direction_pixel_count = 0
    else
        player.current_direction_pixel_count = player.current_direction_pixel_count + 1
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

function check_duckling_wall_collision(x, y)
    -- Duckling sprite is 8x8 pixels
    local duckling_size = 8
    
    for _, wall in ipairs(walls) do
        -- Check if duckling bounding box overlaps with wall
        if x < wall.x + wall.width and 
           x + duckling_size > wall.x and
           y < wall.y + wall.height and
           y + duckling_size > wall.y then
            return true
        end
    end
    return false
end

function get_valid_directions(duckling)
    -- Returns a list of valid directions that don't hit walls
    local valid_directions = {}
    local duckling_size = 8
    local test_distance = 1
    
    -- Test each direction: 0=left, 1=right, 2=down, 3=up
    for dir = 0, 3 do
        local test_x = duckling.x
        local test_y = duckling.y
        
        if dir == 0 then
            test_x = duckling.x - test_distance
        elseif dir == 1 then
            test_x = duckling.x + test_distance
        elseif dir == 2 then
            test_y = duckling.y + test_distance
        elseif dir == 3 then
            test_y = duckling.y - test_distance
        end
        
        if not check_duckling_wall_collision(test_x, test_y) then
            add(valid_directions, dir)
        end
    end
    
    return valid_directions
end

function move_free_ducklings()
    local duckling_size = 8
    local move_speed = 1
    local direction_change_probability = 0.02  -- 2% chance per frame to change direction
    
    for _, duckling in ipairs(ducklings) do
        -- Skip if this is not a duckling object (like sprite properties)
        if duckling.x and duckling.y and not duckling.following then
            -- Small probability to randomly change direction each frame
            if rnd(1) < direction_change_probability then
                local valid_directions = get_valid_directions(duckling)
                if #valid_directions > 0 then
                    duckling.direction = valid_directions[flr(rnd(#valid_directions)) + 1]
                end
            end
            
            local new_x = duckling.x
            local new_y = duckling.y
            
            -- Move based on current direction
            if duckling.direction == 0 then
                new_x = duckling.x - move_speed
            elseif duckling.direction == 1 then
                new_x = duckling.x + move_speed
            elseif duckling.direction == 2 then
                new_y = duckling.y + move_speed
            elseif duckling.direction == 3 then
                new_y = duckling.y - move_speed
            end
            
            -- Check if movement would cause wall collision
            if check_duckling_wall_collision(new_x, new_y) then
                -- Pick a random valid direction
                local valid_directions = get_valid_directions(duckling)
                if #valid_directions > 0 then
                    duckling.direction = valid_directions[flr(rnd(#valid_directions)) + 1]
                else
                    -- If no valid directions, stay in place (shouldn't happen, but safety check)
                    duckling.direction = flr(rnd(4))
                end
            else
                -- Move duckling
                duckling.x = new_x
                duckling.y = new_y
            end
            
            -- Update sprite based on direction
            if duckling.direction == 0 then
                duckling.current_sprite = ducklings.left_sprite
            elseif duckling.direction == 1 then
                duckling.current_sprite = ducklings.right_sprite
            elseif duckling.direction == 2 then
                duckling.current_sprite = ducklings.down_sprite
            elseif duckling.direction == 3 then
                duckling.current_sprite = ducklings.up_sprite
            end
        end
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