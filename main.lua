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
    g_player.collider = {
        pos = { x = 0, y = 0 },
        sprite_offset = { x = -4, y = -12 },
        width = 6,
        height = 4,
    }

    g_anims = {
        IdleDown = create_anim_flow(34, 1, 10, 2, false),
        WalkDown = create_anim_flow(32, 3, 10, 2, false),
        IdleUp = create_anim_flow(40, 1, 10, 2, false),
        WalkUp = create_anim_flow(38, 3, 10, 2, false),
        IdleRight = create_anim_flow(66, 1, 10, 2, false),
        WalkRight = create_anim_flow(64, 3, 10, 2, false),
        IdleLeft = create_anim_flow(66, 1, 10, 2, true),
        WalkLeft = create_anim_flow(64, 3, 10, 2, true),
        IdleUpRight = create_anim_flow(8, 1, 10, 2, false),
        WalkUpRight = create_anim_flow(6, 3, 10, 2, false),
        IdleDownRight = create_anim_flow(2, 1, 10, 2, false),
        WalkDownRight = create_anim_flow(0, 3, 10, 2, false),
        IdleUpLeft = create_anim_flow(8, 1, 10, 2, true),
        WalkUpLeft = create_anim_flow(6, 3, 10, 2, true),
        IdleDownLeft = create_anim_flow(2, 1, 10, 2, true),
        WalkDownLeft = create_anim_flow(0, 3, 10, 2, true),
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

    local player_tile_idx = get_player_tile_idx(g_map, g_player)
    if player_tile_idx != nil then
        local player_tile = g_map.cells[player_tile_idx.y][player_tile_idx.x]
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
end

function _draw()
    cls(Colors.BLACK)

    --
    -- draw the tiles
    --
    local map_pixel_width = g_map.width_in_tiles * TILE_SIZE()
    local map_pixel_height = g_map.height_in_tiles * TILE_SIZE()
    -- offsets to draw the map in the center of the board
    local pixel_row_offset = flr((SCREEN_SIZE() - map_pixel_height) / 2)
    local pixel_col_offset = flr((SCREEN_SIZE() - map_pixel_width) / 2)

    -- draw base map
    for row=0,g_map.height_in_tiles-1 do
        for col=0,g_map.width_in_tiles-1 do
            local tile = g_map.cells[row+1][col+1]
            local tile_x0 = col * TILE_SIZE() + g_map.pos.x
            local tile_x1 = tile_x0 + TILE_SIZE() - 1
            local tile_y0 = row * TILE_SIZE() + g_map.pos.y
            local tile_y1 = tile_y0 + TILE_SIZE() - 1

            rectfill(tile_x0, tile_y0, tile_x1, tile_y1, get_tile_color(tile))
        end
    end

    -- highlight player's current tile
    local player_tile_idx = get_player_tile_idx(g_map, g_player)
    if player_tile_idx != nil then
        highlight_player_tile(g_map, player_tile_idx)
    end

    --
    -- draw the player
    --
    local player_sprite_pos = sprite_pos_from_collider(g_player.collider)
    draw_anim(g_player, player_sprite_pos)

    -- DEBUG bring player pos
    --print("pos: ("..g_player.collider.pos.x..","..g_player.collider.pos.y..")", 60, 120, Colors.White)
    --
    -- draw the level UI
    --
    print("Level: "..g_map.level_id, 0, 120, Colors.White)
    if g_player_found_exit_timer != nil then
        print("FOUND EXIT", 100, 120, Colors.White)
    elseif g_player_respawn_timer != nil then
        print("DIED", 100, 120, Colors.White)
    end

    --
    -- draw the in-game timer UI
    --
    g_ingame_timer.draw()
end

function move_to_level(next_level)
    -- update the current map
    change_level(next_level)

    -- reset the player to the start of that map
    g_player.collider.pos = get_pos_to_center_on_tile(g_map, g_map.player_start_tile, g_player.collider.width, g_player.collider.height)
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
        next_map.width_in_tiles =  min(prev_map.width_in_tiles + 1, MAX_TILE_LINE())
        next_map.height_in_tiles = min(prev_map.height_in_tiles + 1, MAX_TILE_LINE())
    else
        next_map.width_in_tiles = 4
        next_map.height_in_tiles = 4
    end

    -- calculate the map's position so it's centered on the screen.
    local map_size = calc_map_size(next_map)
    local pixel_row_offset = flr((SCREEN_SIZE() - map_size.height) / 2)
    local pixel_col_offset = flr((SCREEN_SIZE() - map_size.width) / 2)
    next_map.pos = { x = pixel_row_offset, y = pixel_col_offset }

    -- generate the map
    next_map.cells = {}
    for row=1,next_map.height_in_tiles do
        add(next_map.cells, {})
        for col=1,next_map.width_in_tiles do
            add(next_map.cells[row], generate_rnd_tile())
        end
    end

    -- generate the player start position
    next_map.player_start_tile = select_random_empty_map_position(next_map)
    next_map.cells[next_map.player_start_tile.y][next_map.player_start_tile.x] = make_tile(true, TileType.Start)

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
    for y=1,map.height_in_tiles do
        for x=1,map.width_in_tiles do
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
    local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
    local movement = nil
    if g_input.btn_left then
        if g_input.btn_up then
            movement = { x = -1 * sqrt_half, y = -1 * sqrt_half }
        elseif g_input.btn_down then
            movement = { x = -1 * sqrt_half, y = sqrt_half }
        else
            movement = { x = -1, y = 0 }
        end
    elseif g_input.btn_right then
        if g_input.btn_up then
            movement = { x = sqrt_half, y = -1 * sqrt_half }
        elseif g_input.btn_down then
            movement = { x = sqrt_half, y = sqrt_half }
        else
            movement = { x = 1, y = 0 }
        end
    elseif g_input.btn_up then
        movement = { x = 0, y = -1 }
    elseif g_input.btn_down then
        movement = { x = 0, y = 1 }
    else
        return
    end

    local player_speed = 1.3
    movement.x *= player_speed
    movement.y *= player_speed

    local map_size = calc_map_size(g_map)
    g_player.collider.pos.x = clamp(g_map.pos.x, g_player.collider.pos.x + movement.x, g_map.pos.x + map_size.width - g_player.collider.width)
    g_player.collider.pos.y = clamp(g_map.pos.y, g_player.collider.pos.y + movement.y, g_map.pos.y + map_size.height - g_player.collider.height)
end

function animate_player(input)
    local anim = nil
    if g_input.btn_left then
        if g_input.btn_up then
            anim = g_anims.WalkUpLeft
        elseif g_input.btn_down then
            anim = g_anims.WalkDownLeft
        else
            anim = g_anims.WalkLeft
        end
    elseif g_input.btn_right then
        if g_input.btn_up then
            anim = g_anims.WalkUpRight
        elseif g_input.btn_down then
            anim = g_anims.WalkDownRight
        else
            anim = g_anims.WalkRight
        end
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
        elseif g_player.anim_state.last_flow == g_anims.WalkUpLeft then
            anim = g_anims.IdleUpLeft
        elseif g_player.anim_state.last_flow == g_anims.WalkUpRight then
            anim = g_anims.IdleUpRight
        elseif g_player.anim_state.last_flow == g_anims.WalkDownLeft then
            anim = g_anims.IdleDownLeft
        elseif g_player.anim_state.last_flow == g_anims.WalkDownRight then
            anim = g_anims.IdleDownRight
        else
            anim = g_player.anim_state.last_flow
        end
    end

    update_anim(g_player, anim)
end

function get_pos_to_center_on_tile(map, tile_pos, obj_width, obj_height)
    local tile_worldpos_x = (tile_pos.x - 1) * TILE_SIZE() + map.pos.x
    local tile_worldpos_y = (tile_pos.y - 1) * TILE_SIZE() + map.pos.y
    return {
        x = ((TILE_SIZE() - obj_width)  / 2 ) + tile_worldpos_x,
        y = ((TILE_SIZE() - obj_height)  / 2 ) + tile_worldpos_y,
    }
end

function copy_pos(pos)
    return { x = pos.x, y = pos.y }
end

function sprite_pos_from_collider(collider)
    return {
        x = collider.pos.x + collider.sprite_offset.x,
        y = collider.pos.y + collider.sprite_offset.y,
    }
end

function calc_map_size(map)
    return { width = map.width_in_tiles * TILE_SIZE(), height = map.height_in_tiles * TILE_SIZE() }
end

function get_player_tile_idx(map, player)
    local tile_x = flr((player.collider.pos.x - map.pos.x) / TILE_SIZE())
    local tile_y = flr((player.collider.pos.y - map.pos.y) / TILE_SIZE())

    -- check for off-map
    if (tile_x < 0) or (tile_y < 0) or (tile_x >= map.width_in_tiles) or (tile_y >= map.height_in_tiles) then
        return
    end

    local tile_collider = {
        pos = {
            x = tile_x * TILE_SIZE() + map.pos.x,
            y = tile_y * TILE_SIZE() + map.pos.y,
        },
        -- make the tile collider not the entire size of the tile that way players don't immediately trip a tile as
        -- soon as they hit the border of one
        width = 10,
        height = 12,
    }

    if rect_colliders_overlap(player.collider, tile_collider) then
        return { x = (tile_x + 1), y = (tile_y + 1) }
    else
        return nil
    end
end

function rect_colliders_overlap(c1, c2)
    local c2_left_of_c1 = c1.pos.x >= (c2.pos.x + c2.width)
    local c1_left_of_c1 = c2.pos.x >= (c1.pos.x + c1.width)
    if c2_left_of_c1 or c1_left_of_c1 then
        return false
    end

    local c2_below_c1 = c1.pos.y >= (c2.pos.y + c2.height)
    local c1_below_c1 = c2.pos.y >= (c1.pos.y + c1.height)
    if c2_below_c1 or c1_below_c1 then
        return false
    end

    return true
end

function highlight_player_tile(map, player_tile_idx)
    local player_tile_x0 = (player_tile_idx.x-1) * TILE_SIZE() + map.pos.x
    local player_tile_x1 = player_tile_x0 + TILE_SIZE() - 1
    local player_tile_y0 = (player_tile_idx.y-1) * TILE_SIZE() + map.pos.y
    local player_tile_y1 = player_tile_y0 + TILE_SIZE() - 1
    rect(player_tile_x0, player_tile_y0, player_tile_x1, player_tile_y1, Colors.White)
end
