-- main.lua - main game logic

TileType = {
    Empty = 1,
    Start = 2,
    Finish = 3,
    Trap = 4,
    Fall = 5,
}

HintArrow = {
    Up = 1,
    UpRight = 2,
    Right = 3,
    DownRight = 4,
    Down = 5,
    DownLeft = 6,
    Left = 7,
    UpLeft = 8,
}

-- constants
function ISO_TILE_WIDTH()
    return 32
end

function ISO_TILE_HEIGHT()
    return 16
end

function MAX_TILE_LINE()
    return 8
end

function MAX_CAMERA_DISTANCE_FROM_PLAYER()
    return 20
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
g_camera_player_offset = nil

function _init()
    g_player = {}
    g_camera_player_offset = { x = 0, y = 0 }
    g_player.pos = { x = 0, y = 0 }
    g_player.sprite_offset = { x = -8, y = -14 }
    g_player.collider = { radius = 3 }

    g_anims = {
        IdleDown = create_anim_flow({34}, 10, 2, false),
        WalkDown = create_anim_flow({32, 34, 36}, 10, 2, false),
        IdleUp = create_anim_flow({40}, 10, 2, false),
        WalkUp = create_anim_flow({38, 40, 42}, 10, 2, false),
        IdleRight = create_anim_flow({66}, 10, 2, false),
        WalkRight = create_anim_flow({64, 66, 68}, 10, 2, false),
        IdleLeft = create_anim_flow({66}, 10, 2, true),
        WalkLeft = create_anim_flow({64, 66, 68}, 10, 2, true),
        IdleUpRight = create_anim_flow({8}, 10, 2, false),
        WalkUpRight = create_anim_flow({6, 8, 10}, 10, 2, false),
        IdleDownRight = create_anim_flow({2}, 10, 2, false),
        WalkDownRight = create_anim_flow({0, 2, 4}, 10, 2, false),
        IdleUpLeft = create_anim_flow({8}, 10, 2, true),
        WalkUpLeft = create_anim_flow({6, 8, 10}, 10, 2, true),
        IdleDownLeft = create_anim_flow({2}, 10, 2, true),
        WalkDownLeft = create_anim_flow({0, 2, 4}, 10, 2, true),
        DigRight = create_anim_flow({12, 12, 14}, 5, 2, false),
        DigLeft = create_anim_flow({12, 12, 14}, 5, 2, true),
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

    -- handle input blocking animation states
    if g_player.dig_state != nil then
        -- update the dig animation
        update_anim(g_player, g_player.dig_state.anim)

        -- if we just started the 'dig up' portion of our animation,
        -- fire the on_dig_up callback exactly one
        if (g_player.anim_state.a_st == 2) and g_player.dig_state.on_dig_up != nil then
            g_player.dig_state.on_dig_up()
            g_player.dig_state.on_dig_up = nil
        end

        -- check if we're done digging yet
        if g_player.anim_state.loop > 0 then
            -- reset our animation state to what is was before we started digging
            reset_anim(g_player)
            update_anim(g_player, g_player.dig_state.previous_anim)
            g_player.dig_state = nil
        end
        return
    elseif g_player_found_exit_timer != nil then
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

    local is_digging = g_input.btn_o and g_input.btn_o_change

    if is_digging then
        g_player.dig_state = {
            anim = get_dig_anim_for_player(g_player),
            previous_anim = g_player.anim_state.last_flow }
        -- reset the anim state so the digging animation always starts on frame 0
        reset_anim(g_player)

    end

    local player_iso_tile_idx = get_player_iso_tile_idx(g_map, g_player)
    if player_iso_tile_idx != nil then
        local player_iso_tile = g_map.isocells[player_iso_tile_idx].tile

        -- If we've just dug up a tile, we'll set a callback so that after
        -- the digging animation reveals the tile, we'll automatically
        -- interact with it.
        if is_digging then
            local reveal_tile_callback = function()
                player_iso_tile.visible = true
                interact_with_tile(player_iso_tile)
            end
            g_player.dig_state.on_dig_up = reveal_tile_callback
        -- If we aren't digging and the tile is already flipped,
        -- we'll proactively interact with it.
        elseif player_iso_tile.visible then
            interact_with_tile(player_iso_tile)
        end
    end
end

function interact_with_tile(tile)
    if tile.type == TileType.Finish then
        g_player_found_exit_timer = make_ingame_timer(15)
    elseif tile.type == TileType.Trap then
        g_player_respawn_timer = make_ingame_timer(30)
    end
end

function get_dig_anim_for_player(player)
    local should_dig_left = (
        player.anim_state.last_flow == g_anims.IdleLeft or
        player.anim_state.last_flow == g_anims.WalkLeft or
        player.anim_state.last_flow == g_anims.IdleUpLeft or
        player.anim_state.last_flow == g_anims.WalkUpLeft or
        player.anim_state.last_flow == g_anims.IdleDownLeft or
        player.anim_state.last_flow == g_anims.WalkDownLeft)

    if should_dig_left then
        return g_anims.DigLeft
    else
        return g_anims.DigRight
    end
end

function get_centered_camera_on_player(player)
    return  { x = player.pos.x - 64, y = player.pos.y - 64 }
end

function camera_follow_player(player, camera_ofs)
    -- If the camera is already within the max allowed distance from the player
    -- don't move the camera
    local player_camera_center_ofs = get_centered_camera_on_player(player)
    local dist_squared = sqr_dist(player_camera_center_ofs, camera_ofs)
    if dist_squared <= sqr(MAX_CAMERA_DISTANCE_FROM_PLAYER()) then
        return
    end

    -- If the camera is outside of the max allowed distance, move it closer
    local dir_vector = sub_vec2(camera_ofs, player_camera_center_ofs)

    -- take the distance and divide it out to get the unit vector
    local dist = sqrt(dist_squared)
    dir_vector.x /= dist
    dir_vector.y /= dist

    -- multiply the max distance to get our max distance from player
    dir_vector.x *= MAX_CAMERA_DISTANCE_FROM_PLAYER()
    dir_vector.y *= MAX_CAMERA_DISTANCE_FROM_PLAYER()

    new_ofs = add_vec2(player.pos, dir_vector)
    camera_ofs.x = new_ofs.x - 64
    camera_ofs.y = new_ofs.y - 64
end

function _draw()
    cls(Colors.BLACK)

    -- Set the camera view so that the world is draw relative to its position
    camera_follow_player(g_player, g_camera_player_offset)
    camera(g_camera_player_offset.x, g_camera_player_offset.y);

    --
    -- draw the tiles
    --

    -- draw iso map
    for isocell in all(g_map.isocells) do
        local frame_idx = get_iso_tile_sprite_frame(isocell.tile)
        if frame_idx != nil then
            -- DRAW A THIN BORDER
            spr(128, isocell.pos.x - ISO_TILE_WIDTH()/2, isocell.pos.y, 4, 2, false)
            spr(frame_idx, isocell.pos.x - ISO_TILE_WIDTH()/2, isocell.pos.y - ISO_TILE_HEIGHT()/2, 4, 2, false)

            -- draw the hint arrow if the empty hint cell is visible
            if isocell.tile.type == TileType.Empty and isocell.tile.visible then
                draw_hint_arrow(isocell.pos, isocell.tile.hint)
            end
        end
    end

    local player_iso_tile_idx = get_player_iso_tile_idx(g_map, g_player)
    if player_iso_tile_idx != nil then
        highlight_player_iso_tile(g_map, player_iso_tile_idx)
    end

    --
    -- draw the player
    --
    local player_sprite_pos = sprite_pos(g_player)
    draw_anim(g_player, player_sprite_pos)
    -- uncomment to display anim state for debugging
    -- dbg_display_anim_state(g_player, { x = 0, y = 60 }, g_anims)

    -- uncomment to display colliders on top of everything for debugging
    -- dbg_display_colliders()

    --
    -- Draw all UI unaffected by the camera
    --

    -- reset the camera to 0 keep the UI fixed on screen
    camera(0, 0)

    -- draw the level UI
    print("Level: "..g_map.level_id, 0, 120, Colors.White)
    if g_player_found_exit_timer != nil then
        print("FOUND EXIT", 100, 120, Colors.White)
    elseif g_player_respawn_timer != nil then
        print("DIED", 100, 120, Colors.White)
    end

    -- draw the in-game timer UI
    g_ingame_timer.draw()

    -- uncomment to display frame stats
    -- dbg_display_frame_stats({ x = 80, y = 80 })
end

function dbg_display_frame_stats(pos)
    print("mem:  "..  stat(0), pos.x, pos.y + 00, Colors.White)
    print("cpu:  "..  stat(1), pos.x, pos.y + 10, Colors.White)
    print("fps(t): "..stat(8), pos.x, pos.y + 20, Colors.White)
    print("fps(a): "..stat(7), pos.x, pos.y + 30, Colors.White)
end

function dbg_display_colliders()
    circ(g_player.pos.x, g_player.pos.y, g_player.collider.radius, Colors.White)
    for cell in all(g_map.isocells) do
        circ(cell.pos.x, cell.pos.y, cell.collider.radius, Colors.White)
    end
end

function draw_hint_arrow(pos_center, hint)
    local arrow_tile_px_size = 8
    local pos = {
        x = pos_center.x - (arrow_tile_px_size/2),
        y = pos_center.y - (arrow_tile_px_size/2) }

    local frame = nil
    local flip_x = nil
    local flip_y = nil

    if     hint == HintArrow.Right then
        frame = 134
        flip_x = false
        flip_y = false
    elseif hint == HintArrow.DownRight then
        frame = 133
        flip_x = false
        flip_y = true
    elseif hint == HintArrow.Down then
        frame = 132
        flip_x = false
        flip_y = true
    elseif hint == HintArrow.DownLeft then
        frame = 133
        flip_x = true
        flip_y = true
    elseif hint == HintArrow.Left then
        frame = 134
        flip_x = true
        flip_y = false
    elseif hint == HintArrow.UpLeft then
        frame = 133
        flip_x = true
        flip_y = false
    elseif hint == HintArrow.Up then
        frame = 132
        flip_x = false
        flip_y = false
    else -- hint == HintArrow.UpRight
        frame = 133
        flip_x = false
        flip_y = false
    end

    spr(frame, pos.x, pos.y, 1, 1, flip_x, flip_y)
end

function move_to_level(next_level)
    -- update the current map
    change_level(next_level)

    -- place the player on the center of the iso tile
    g_player.pos = copy_pos(g_map.isocells[g_map.player_start_iso_idx].pos)
    -- place the camera on top of the player
    g_camera_player_offset = get_centered_camera_on_player(g_player)

    -- reset the player's animation
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
        next_map.iso_width = min(prev_map.iso_width + 1, MAX_TILE_LINE())
    else
        next_map.iso_width = 2
    end

    -- generate the isomap. initialize all at the start to empty
    next_map.isocells = {}
    -- add an two extra rows to each side of the map so we can wrap the map with fall tiles
    local row_cnt = isomap_row_cnt(next_map) + 4
    local idx = 1
    for row = 1,row_cnt do
        local midpoint_row = flr((row_cnt + 1) / 2)

        local row_offset = (row - midpoint_row) * ISO_TILE_HEIGHT() / 2
        local col_cnt = nil
        if row <= midpoint_row then
            col_cnt = row
        else
            col_cnt = 2 * midpoint_row - row
        end

        for col = 1,col_cnt do
            local tile = nil

            local is_edge_tile = (col == 1) or (col == col_cnt)
            if is_edge_tile then
                tile = make_tile(true, TileType.Fall)
            else
                tile = make_tile(false, TileType.Empty)
            end

            local col_offset =
                -1 * ((col_cnt/2) * ISO_TILE_WIDTH()) -- shift half the board width to the left
                + (ISO_TILE_WIDTH()/2)                -- offset by half a tile width to move back into the center of the first tile
                + ((col - 1)*ISO_TILE_WIDTH())        -- add a tile width for each subsequent tile

            local cell = {
                idx = idx,
                tile = tile,
                pos = {
                    x = SCREEN_SIZE()/2 + col_offset,
                    y = SCREEN_SIZE()/2 + row_offset,
                },
                collider = { radius = 4 }
            }

            add(next_map.isocells, cell)
            idx += 1
        end
    end

    -- generate the iso trap cells. Generate 30% of the map as trap cells
    local trap_cell_cnt = flr(next_map.iso_width * next_map.iso_width * 0.30)
    for i = 1,trap_cell_cnt do
        local next_trap_cell_idx = select_random_empty_isomap_tile_idx(next_map)
        next_map.isocells[next_trap_cell_idx].tile = make_tile(false, TileType.Trap)
    end

    -- generate the player start position on an isotile
    next_map.player_start_iso_idx = select_random_empty_isomap_tile_idx(next_map)
    next_map.isocells[next_map.player_start_iso_idx].tile = make_tile(true, TileType.Start)

    -- place the iso finish
    local iso_finish_cell_idx = select_random_empty_isomap_tile_idx(next_map)
    next_map.isocells[iso_finish_cell_idx].tile = make_tile(false, TileType.Finish)

    -- now that we've placed the finish cell, update all the empty cells with hints
    local iso_finish_cell_pos = next_map.isocells[iso_finish_cell_idx].pos
    for cell in all(next_map.isocells) do
        if cell.tile.type == TileType.Empty then
            local dir_vector = sub_vec2(iso_finish_cell_pos, cell.pos)
            local unit_circle_ratio = atan2(dir_vector.x, -1 * dir_vector.y)
            local angle_to_finish_point_deg = unit_circle_ratio * 360

            local hint_arrow = nil
            if     angle_to_finish_point_deg <  22.5 then
                hint_arrow = HintArrow.Right
            elseif angle_to_finish_point_deg <  67.5 then
                hint_arrow = HintArrow.DownRight
            elseif angle_to_finish_point_deg < 112.5 then
                hint_arrow = HintArrow.Down
            elseif angle_to_finish_point_deg < 157.5 then
                hint_arrow = HintArrow.DownLeft
            elseif angle_to_finish_point_deg < 202.5 then
                hint_arrow = HintArrow.Left
            elseif angle_to_finish_point_deg < 247.5 then
                hint_arrow = HintArrow.UpLeft
            elseif angle_to_finish_point_deg < 292.5 then
                hint_arrow = HintArrow.Up
            elseif angle_to_finish_point_deg < 337.5 then
                hint_arrow = HintArrow.UpRight
            else
                hint_arrow = HintArrow.Right
            end

            cell.tile.hint = hint_arrow
        end
    end

    g_maps[next_level] = next_map
    g_map = next_map
end

function make_tile(visible, tile_type)
    return { visible = visible, type = tile_type }
end

function select_random_empty_isomap_tile_idx(map)
    local idx = 1
    local choice_cnt = 0
    local choices = {}
    for cell in all(map.isocells) do
        if cell.tile.type == TileType.Empty then
            add(choices, idx)
            choice_cnt += 1
        end
        idx += 1
    end

    local rnd_choice_index = rnd_incrange(1, choice_cnt)
    return choices[rnd_choice_index]
end

function get_iso_tile_sprite_frame(tile)
    if tile.visible then
        if tile.type == TileType.Empty then
            return 160
        elseif tile.type == TileType.Start then
            return 108
        elseif tile.type == TileType.Finish then
            return 104
        elseif tile.type == TileType.Trap then
            return 76
        elseif tile.type == TileType.Fall then
            return nil
        else
            return nil
        end
    else
        return 96
    end
end

function move_player(input)
    -- when traveling diagnonally, multiply by the factor sqrt(0.5) to avoid traveling further by going diagonally
    local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
    local movement_x = 0
    local movement_y = 0
    if g_input.btn_left then
        if g_input.btn_up then
            movement_x = -2 * sqrt_half
            movement_y = -1 * sqrt_half
        elseif g_input.btn_down then
            movement_x = -2 * sqrt_half
            movement_y = sqrt_half
        else
            movement_x = -2
            movement_y = 0
        end
    elseif g_input.btn_right then
        if g_input.btn_up then
            movement_x = 2 * sqrt_half
            movement_y = -1 * sqrt_half
        elseif g_input.btn_down then
            movement_x = 2 * sqrt_half
            movement_y = sqrt_half
        else
            movement_x = 2
            movement_y = 0
        end
    elseif g_input.btn_up then
            movement_x = 0
            movement_y = -1
    elseif g_input.btn_down then
            movement_x = 0
            movement_y = 1
    else
        return
    end

    local player_speed = 0.7 -- an arbitrary, tweakable speed factor to hand tune movement speed to feel good
    movement_x *= player_speed
    movement_y *= player_speed

    -- copy the old position in case we need to roll back
    local old_player_pos = copy_pos(g_player.pos)

    -- move the player, check if they've moved onto a fall tile
    local move_candidates = {}
    add(move_candidates, { x = movement_x, y = movement_y })
    if movement_x != 0 then
        add(move_candidates, { x = movement_x, y = 0 })
    end
    if movement_y != 0 then
        add(move_candidates, { x = 0, y = movement_y })
    end

    for move in all(move_candidates) do
        g_player.pos = add_vec2(old_player_pos, move)

        -- check if we've standing on any fall tiles and if so, rollback the movement
        local cells = get_iso_cells_under_player(g_map, g_player)
        local valid_move = true
        for cell in all(cells) do
            if cell.tile.type == TileType.Fall then
                valid_move = false
                break
            end
        end

        if valid_move then
            return
        end
    end

    -- rollback
    g_player.pos = old_player_pos
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

function copy_pos(pos)
    return { x = pos.x, y = pos.y }
end

function sprite_pos(obj)
    return {
        x = obj.pos.x + obj.sprite_offset.x,
        y = obj.pos.y + obj.sprite_offset.y,
    }
end

function get_player_iso_tile_idx(map, player)
    -- N.B. Currently we do an extra smaller circle collider check so that we only activate at most one tile at a time
    -- even if we are standing in between two..
    for cell in all(get_iso_cells_under_player(map, player)) do
        if circ_colliders_overlap(player, cell) then
            return cell.idx
        end
    end

    return nil
end

function circ_colliders_overlap(obj1, obj2)
    local max_dist_squared = sqr(obj1.collider.radius +  obj2.collider.radius)
    local dist_squared = sqr_dist(obj1.pos, obj2.pos)
    return dist_squared <= max_dist_squared
end

function get_iso_cells_under_player(map, player)
    cells = {}
    for cell in all(map.isocells) do
        if is_iso_cell_under_player(cell, player) then
            add(cells, cell)
        end
    end

    return cells
end

function is_iso_cell_under_player(cell, player)
    -- divide up an iso-tile into 3 rect colliders
    local iso_sub_colliders = {
        { width = 12, height = 12 },
        { width = 18, height = 9 },
        { width = 26, height = 5 },
    }

    -- setup a simple rect-collider for the player wrapping their circle collider
    local player_rect_collider = {
        pos = {
            x = player.pos.x - player.collider.radius,
            y = player.pos.y - player.collider.radius,
        },
        width = (player.collider.radius + player.collider.radius),
        height = (player.collider.radius + player.collider.radius),
    }

    local cell_pos_x = cell.pos.x
    local cell_pos_y = cell.pos.y
    for sub_collider in all(iso_sub_colliders) do
        -- center the subcollider in the iso cell
        sub_collider.pos = { x = cell_pos_x - (sub_collider.width/2), y = cell_pos_y - (sub_collider.height/2) }
        if rect_colliders_overlap(player_rect_collider, sub_collider) then
            return true
        end
    end
    return false
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

function highlight_player_iso_tile(map, player_tile_idx)
    local tile_pos = map.isocells[player_tile_idx].pos
    -- N.B. for some reason, I need to subtract '1' from each of the y values. I haven't yet rationalized why
    -- the off-by-one pixel shift is needed. I'll figure it out later.
    local line_points = {
        { x = tile_pos.x - ISO_TILE_WIDTH()/2, y = tile_pos.y - 1 },
        { x = tile_pos.x,                      y = tile_pos.y - 1 - ISO_TILE_HEIGHT()/2 },
        { x = tile_pos.x + ISO_TILE_WIDTH()/2, y = tile_pos.y - 1},
        { x = tile_pos.x,                      y = tile_pos.y - 1+ ISO_TILE_HEIGHT()/2 },
    }

    line(line_points[1].x, line_points[1].y, line_points[2].x, line_points[2].y, Colors.White)
    line(line_points[2].x, line_points[2].y, line_points[3].x, line_points[3].y, Colors.White)
    line(line_points[3].x, line_points[3].y, line_points[4].x, line_points[4].y, Colors.White)
    line(line_points[4].x, line_points[4].y, line_points[1].x, line_points[1].y, Colors.White)
end

function isomap_row_cnt(map)
    return map.iso_width * 2 - 1
end

function add_vec2(p1, p2)
    return { x = p1.x + p2.x, y = p1.y + p2.y }
end

function sub_vec2(p1, p2)
    return { x = p1.x - p2.x, y = p1.y - p2.y }
end
