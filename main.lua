-- main.lua - main game logic

TileType = {
    Empty = 1,
    Start = 2,
    Finish = 3,
    Trap = 4,
}

-- constants
function TILE_SIZE()
    return 16
end

function MAX_TILE_LINE()
    return SCREEN_SIZE() /  TILE_SIZE()
end

-- global variables
g_maps = nil
g_map = nil
g_player = nil
g_input = nil
g_player_found_exit_timer = nil
g_player_respawn_timer = nil
g_ingame_timer = nil
g_anims = nil

function _init()
    g_player = {}
    g_anims = {
        IdleDown = create_anim_flow(34, 1, 10, 2, false),
        WalkDown = create_anim_flow(32, 3, 10, 2, false),
        IdleRight = create_anim_flow(2, 1, 10, 2, false),
        WalkRight = create_anim_flow(0, 3, 10, 2, false),
        IdleLeft = create_anim_flow(2, 1, 10, 2, true),
        WalkLeft = create_anim_flow(0, 3, 10, 2, true),
        IdleUp = create_anim_flow(40, 1, 10, 2, false),
        WalkUp = create_anim_flow(38, 3, 10, 2, false),
    }
    g_ingame_timer = make_ui_timer()

    g_maps = {}
    move_to_level(1)
end

function _update()
    -- get input
    g_input = poll_input(g_input)

    -- update our in-game accelerated timer UI
    g_ingame_timer.update(g_input)

    -- handle the block state
    if g_player_found_exit_timer != nil then
        g_player_found_exit_timer.update()
        if g_player_found_exit_timer.done() then
            g_player_found_exit_timer = nil
            move_to_level(g_map.level_id + 1)
        end
        return
    elseif g_player_respawn_timer != nil then
        g_player_respawn_timer.update()
        if g_player_respawn_timer.done() then
            g_player_respawn_timer = nil
            move_to_level(1)
        end
        return
    end

    move_player(g_input)
    animate_player(g_input)

    local player_tile = g_map.cells[g_player.pos.y][g_player.pos.x]

    -- potentially flip the player tile
    if g_input.btn_o and g_input.btn_o_change then
        player_tile.visible = true
    end

    if player_tile.visible then
        if player_tile.type == TileType.Finish then
            g_player_found_exit_timer = make_ingame_timer(60)
        elseif player_tile.type == TileType.Trap then
            g_player_respawn_timer = make_ingame_timer(60)
        end
    end
end

function _draw()
    cls(Colors.BLACK)

    -- draw the tiles
    local map_pixel_width = g_map.width * TILE_SIZE()
    local map_pixel_height = g_map.height * TILE_SIZE()
    -- offsets to draw the map in the center of the board
    local pixel_row_offset = flr((SCREEN_SIZE() - map_pixel_height) / 2)
    local pixel_col_offset = flr((SCREEN_SIZE() - map_pixel_width) / 2)

    -- draw base map
    for row=0,g_map.height-1 do
        for col=0,g_map.width-1 do
            local tile = g_map.cells[row+1][col+1]
            local tile_x0 = col * TILE_SIZE() + pixel_col_offset
            local tile_x1 = tile_x0 + TILE_SIZE() - 1
            local tile_y0 = row * TILE_SIZE() + pixel_row_offset
            local tile_y1 = tile_y0 + TILE_SIZE() - 1

            rectfill(tile_x0, tile_y0, tile_x1, tile_y1, get_tile_color(tile))
        end
    end

    -- draw player position
    local player_tile_x = (g_player.pos.x-1) * TILE_SIZE() + pixel_col_offset
    local player_tile_y = (g_player.pos.y-1) * TILE_SIZE() + pixel_row_offset
    draw_anim(g_player, { x = player_tile_x, y = player_tile_y })

    -- print the level
    print("Level: "..g_map.level_id, 0, 120, Colors.White)
    if g_player_found_exit_timer != nil then
        print("FOUND EXIT", 100, 120, Colors.White)
    elseif g_player_respawn_timer != nil then
        print("DIED", 100, 120, Colors.White)
    end

    g_ingame_timer.draw()
end

function move_to_level(next_level)
    -- update the current map
    change_level(next_level)

    -- reset the player to the start of that map
    g_player.pos = copy_pos(g_map.player_start)
    update_anim(g_player, g_anims.IdleDown)
end

function change_level(next_level)
    -- if we've already visited this level, use it rather than generating a new level
    if g_maps[next_level] != nil then
        g_map = g_maps[next_level]
        return
    end

    -- generate a new map
    local next_map = {}
    next_map.level_id = next_level

    -- update the map size
    if g_maps[next_level - 1] != nil then
        local prev_map = g_maps[next_level - 1]
        next_map.width =  min(prev_map.width + 1, MAX_TILE_LINE())
        next_map.height = min(prev_map.height + 1, MAX_TILE_LINE())
    else
        next_map.width = 4
        next_map.height = 4
    end

    -- generate the map
    next_map.cells = {}
    for row=1,next_map.height do
        add(next_map.cells, {})
        for col=1,next_map.width do
            add(next_map.cells[row], generate_rnd_tile())
        end
    end

    -- generate the player start position
    next_map.player_start = select_random_empty_map_position(next_map)
    next_map.cells[next_map.player_start.y][next_map.player_start.x] = make_tile(true, TileType.Start)

    -- place the finish
    local finish_point = select_random_empty_map_position(next_map)
    next_map.cells[finish_point.y][finish_point.x] = make_tile(false, TileType.Finish)

    g_maps[next_level] = next_map
    g_map = next_map
end

function generate_rnd_tile()
    -- TODO: better tile generation (or maybe using predefined maps?)
    if rnd() < 0.3 then
        return make_tile(false, TileType.Trap)
    else
        return make_tile(false, TileType.Empty)
    end

end

function make_tile(visible, tile_type)
    return { visible = visible, type = tile_type }
end

function select_random_empty_map_position(map)
    local choice_cnt = 0
    local choices = {}
    for y=1,map.height do
        for x=1,map.width do
            local tile = map.cells[y][x]
            if tile.type == TileType.Empty then
                add(choices, { x = x, y = y })
                choice_cnt += 1
            end
        end
    end

    local rnd_choice_index = rnd_incrange(1, choice_cnt)
    return choices[rnd_choice_index]
end

function get_tile_color(tile)
    if tile.visible then
        if tile.type == TileType.Empty then
            return Colors.Tan
        elseif tile.type == TileType.Start then
            return Colors.Tan
        elseif tile.type == TileType.Finish then
            return Colors.LightGreen
        elseif tile.type == TileType.Trap then
            return Colors.Red
        else
            return nil
        end
    else
        return Colors.Brown
    end
end

function move_player(input)
    local movement = nil
    if g_input.btn_left and g_input.btn_left_change then
        movement = { x = -1, y = 0 }
    elseif g_input.btn_right and g_input.btn_right_change then
        movement = { x = 1, y = 0 }
    elseif g_input.btn_up and g_input.btn_up_change then
        movement = { x = 0, y = -1 }
    elseif g_input.btn_down and g_input.btn_down_change then
        movement = { x = 0, y = 1 }
    else
        return
    end

    g_player.pos.x = clamp(1, g_player.pos.x + movement.x, g_map.width)
    g_player.pos.y = clamp(1, g_player.pos.y + movement.y, g_map.height)
end

function animate_player(input)
    local anim = nil
    if g_input.btn_left then
        anim = g_anims.WalkLeft
    elseif g_input.btn_right then
        anim = g_anims.WalkRight
    elseif g_input.btn_up then
        anim = g_anims.WalkUp
    elseif g_input.btn_down then
        anim = g_anims.WalkDown
    else
        if g_player.anim_state.last_flow == g_anims.WalkLeft then
            anim = g_anims.IdleLeft
        elseif g_player.anim_state.last_flow == g_anims.WalkRight then
            anim = g_anims.IdleRight
        elseif g_player.anim_state.last_flow == g_anims.WalkUp then
            anim = g_anims.IdleUp
        elseif g_player.anim_state.last_flow == g_anims.WalkDown then
            anim = g_anims.IdleDown
        else
            anim = g_player.anim_state.last_flow
        end
    end

    update_anim(g_player, anim)
end

function copy_pos(pos)
    return { x = pos.x, y = pos.y }
end
