-- main.lua - main game logic

TileType = {
    Empty = 1,
    Start = 2,
    Finish = 3,
    Trap = 4,
    Fall = 5,
    BombItem = 6,
    PageItem = 7,
}

ItemType = {
    Bomb = 1,
    Page = 2,
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
    return 10
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
g_ingame_timer = nil
g_anims = nil
g_camera_player_offset = nil
g_bombs = nil

function _init()
    g_player = {}
    g_player.pos = { x = 0, y = 0 }
    g_player.sprite_offset = { x = -8, y = -14 }
    g_player.collider = { radius = 3 }
    g_player.bomb_count = 0
    g_player.page_count = 0

    g_camera_player_offset = { x = 0, y = 0 }

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
        DieLeft = create_anim_flow({70, 70, 238}, 5, 2, true),
        DieRight = create_anim_flow({70, 70, 238}, 5, 2, false),
        CollectItem = create_anim_flow({46}, 1, 2, false),
        BombCountdown = create_anim_flow({74, 74, 74, 74, 74, 74, 74, 75, 74, 74, 75, 74, 74, 75, 74}, 15, 1, false),
    }
    g_ingame_timer = make_ui_timer(on_ui_timer_flash)

    -- TODO: sometimes I refer to these as maps. Sometimes as levels. I should fix this. It's confusing
    g_maps = generate_maps(10)
    move_to_level(1)
end

function _update()
    -- get input
    g_input = poll_input(g_input)

    -- update our in-game accelerated timer UI
    g_ingame_timer.update(g_input)

    -- handle input blocking animation states
    local block_input = false
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
        block_input = true
    elseif g_player.collect_item_state != nil then
        -- update the collect bomb animation
        update_anim(g_player, g_player.collect_item_state.anim)
        g_player.collect_item_state.anim_timer.update()
        if g_player.collect_item_state.anim_timer.done() then
            g_player.collect_item_state = nil
        end
        block_input = true
    elseif g_player_found_exit_timer != nil then
        g_player_found_exit_timer.update()
        if g_player_found_exit_timer.done() then
            g_player_found_exit_timer = nil
            move_to_level(g_map.level_id + 1)
        end
        block_input = true
    elseif g_player.die_state != nil then
        update_anim(g_player, g_player.die_state.anim)
        g_player.die_state.respawn_timer.update()
        if g_player.die_state.respawn_timer.done() then
            g_player.die_state = nil
            move_to_level(1)
        end
        block_input = true
    end

    -- if we aren't blocking new input process it
    if not block_input then
        handle_new_input(g_input)
    end

    -- update bomb states. We update these regardless of input blocks because bomb updates
    -- are passive and don't depend on user input
    local finished_bombs = {}
    for bomb in all(g_bombs) do
        bomb.update()
        if bomb.done() then
            add(finished_bombs, bomb)
        end

        for e in all(bomb.get_explosions()) do
            local explosion_cells = get_iso_cells_under_actor(g_map, e)
            for cell in all(explosion_cells) do
                cell.tile.visible = true
            end

            -- check for player-explosion collisions if the player isn't already dead
            if (g_player.die_state) == nil and (circ_colliders_overlap(g_player, e)) then
                kill_player(g_player)
            end
        end
    end

    -- clean up any bombs which have finished
    for bomb in all(finished_bombs) do
        del(g_bombs, bomb)
    end
end

function handle_new_input(input)
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

    local player_iso_tile_idx = get_actor_iso_tile_idx(g_map, g_player)
    if player_iso_tile_idx != nil then
        local player_iso_tile = g_map.isocells[player_iso_tile_idx].tile

        -- If we've just dug up a tile, we'll set a callback so that after
        -- the digging animation reveals the tile, we'll automatically
        -- interact with it.
        if is_digging then
            local reveal_tile_callback = function()
                sfx(Sfxs.Dig)
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

    -- Handle placing new bombs
    local try_place_bomb = g_input.btn_x and g_input.btn_x_change
    if try_place_bomb then
        if g_player.bomb_count > 0 then
            g_player.bomb_count -= 1
            add(g_bombs, new_bomb(g_player.pos))
        end
    end

end

function kill_player(player)
    player.die_state = {
        anim = get_die_anim_for_player(player),
        respawn_timer = make_ingame_timer(60)
    }
    sfx(Sfxs.Death)
end

function interact_with_tile(tile)
    if tile.type == TileType.Finish then
        g_player_found_exit_timer = make_ingame_timer(15)
    elseif tile.type == TileType.Trap then
        kill_player(g_player)
    elseif tile.type == TileType.BombItem then
        g_player.bomb_count += 1
        g_player.collect_item_state = {
            anim = g_anims.CollectItem,
            item = ItemType.Bomb,
            anim_timer = make_ingame_timer(30),
        }
        -- after weve picked up the bomb, flip the cell to be just a plain ole empty cell without a hint
        tile.type = TileType.Empty
    elseif tile.type == TileType.PageItem then
        g_player.page_count += 1
        g_player.collect_item_state = {
            anim = g_anims.CollectItem,
            item = ItemType.Page,
            page_frag = tile.page_frag,
            anim_timer = make_ingame_timer(30),
        }
        -- after weve picked up the bomb, flip the cell to be just a plain ole empty cell without a hint
        tile.type = TileType.Empty
        tile.page_frag = nil
    end
end

function on_ui_timer_flash()
    sfx(Sfxs.ClockBeep)
end

function is_player_facing_left(player)
    return (player.anim_state.last_flow == g_anims.IdleLeft or
            player.anim_state.last_flow == g_anims.WalkLeft or
            player.anim_state.last_flow == g_anims.IdleUpLeft or
            player.anim_state.last_flow == g_anims.WalkUpLeft or
            player.anim_state.last_flow == g_anims.IdleDownLeft or
            player.anim_state.last_flow == g_anims.WalkDownLeft)
end

function get_dig_anim_for_player(player)
    if is_player_facing_left(player) then
        return g_anims.DigLeft
    else
        return g_anims.DigRight
    end
end

function get_die_anim_for_player(player)
    if is_player_facing_left(player) then
        return g_anims.DieLeft
    else
        return g_anims.DieRight
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

            if isocell.tile.visible then
                -- draw the hint arrow if the empty hint cell is visible
                if (isocell.tile.type == TileType.Empty) and (isocell.tile.hint != nil) then
                    draw_hint_arrow(isocell.pos, isocell.tile.hint)
                -- If it's an unretrieved bomb cell, display an inactive bomb sprite in the middle of the cell.
                -- N.B. this basically only happens if you use a bomb to reveal another bomb.
                elseif isocell.tile.type == TileType.BombItem then
                    draw_bomb_item(isocell.pos)
                elseif isocell.tile.type == TileType.PageItem then
                    draw_page_item(isocell.pos, isocell.tile.page_frag)
                end
            end
        end
    end

    local player_iso_tile_idx = get_actor_iso_tile_idx(g_map, g_player)
    if player_iso_tile_idx != nil then
        highlight_player_iso_tile(g_map, player_iso_tile_idx)
    end

    --
    -- draw the player
    --
    local player_sprite_pos = sprite_pos(g_player)
    draw_anim(g_player, player_sprite_pos)

    -- if the player is collecting an item, draw the item above their collect animation
    if g_player.collect_item_state != nil then
        local item_pos = add_vec2(g_player.pos, { x = 0, y = -16 })
        if g_player.collect_item_state.item == ItemType.Bomb then
            draw_bomb_item(item_pos)
        elseif g_player.collect_item_state.item == ItemType.Page then
            draw_page_item(item_pos, g_player.collect_item_state.page_frag)
        end
    end

    --
    -- draw any active bombs
    --
    for bomb in all(g_bombs) do
        bomb.draw()
    end

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
    elseif g_player.die_state != nil then
        local bg_rect = { x = 0, y = 40, width = 128, height = 10 }
        rectfill(bg_rect.x, bg_rect.y, bg_rect.x + bg_rect.width, bg_rect.y + bg_rect.height, Colors.Navy)
        local text = "DIED"
        local text_pos = center_text(bg_rect, text)
        print(text, text_pos.x, text_pos.y, Colors.Red)
    end

    -- draw the bomb counter UI
    draw_bomb_item({ x = 4, y = 111 })
    print(":"..g_player.bomb_count, 8, 110, Colors.White)

    -- draw the in-game timer UI
    g_ingame_timer.draw()

    -- uncomment to display frame stats
    -- dbg_display_frame_stats({ x = 80, y = 80 })
end

function center_text(rect, text)
    local text_len = #text
    local text_pixel_width = 4 * text_len
    local text_pixel_height = 6
    local text_start_x = rect.x + (rect.width/2) - (text_pixel_width/2)
    local text_start_y = rect.y + (rect.height/2) - (text_pixel_height/2)
    return { x = text_start_x, y = text_start_y }
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
    for bomb in all(g_bombs) do
        for e in all(bomb.get_explosions()) do
            circ(e.pos.x, e.pos.y, e.collider.radius, Colors.White)
        end
    end
end

function draw_hint_arrow(pos_center, hint)
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

    spr_centered(frame, pos_center.x, pos_center.y, 1, 1, flip_x, flip_y)
end

function draw_bomb_item(pos_center)
    spr_centered(74, pos_center.x, pos_center.y, 1, 1)
end

function draw_page_item(pos_center, sprite)
    spr_centered(sprite, pos_center.x, pos_center.y, 1, 1)
end

function spr_centered(frame, x, y, tile_width, tile_height, flip_x, flip_y)
    flip_x = flip_x or false
    flip_y = flip_y or false
    spr(frame, x - (tile_width * 8/2), y - (tile_height * 8/2), tile_width, tile_height, flip_x, flip_y)
end

function sspr_centered(frame, x, y, tile_width, tile_height, scale, flip_x, flip_y)
    flip_x = flip_x or false
    flip_y = flip_y or false
    local sx = (frame % 16) * 8
    local sy = flr(frame / 16) * 8
    local sw = tile_width * 8
    local sh = tile_height * 8
    local scaled_sw = scale * sw
    local scaled_sh = scale * sh
    local pos_x = (x - scaled_sw/2)
    local pos_y = (y - scaled_sh/2)
    sspr(sx, sy, sw, sh, pos_x, pos_y, scaled_sw, scaled_sh, flip_x, flip_y)
end


function generate_maps(num_maps)
    local maps = {}

    for i=1,10 do
        -- the first level has map size 2
        -- the largest map is size MAX_TILE_LINE()
        local map_size_for_level = min((i + 1), MAX_TILE_LINE())
        add(maps, generate_empty_level(i, map_size_for_level))
    end

    -- generate the trap cells in each map
    -- On each map, %30 of the tiles rounded down have traps
    for map in all(maps) do
        local trap_cell_cnt = flr(map.iso_width * map.iso_width * 0.30)
        local trap_cells = select_random_empty_tiles({map}, trap_cell_cnt)
        for trap_cell in all(trap_cells) do
            map.isocells[trap_cell.idx].tile = make_tile(false, TileType.Trap)
        end
    end

    -- generate the bomb item cells
    -- There are a total of 10 bombs across the whole game
    local bomb_cell_cnt = 10
    local bomb_cells = select_random_empty_tiles(maps, bomb_cell_cnt)
    for bomb_cell in all(bomb_cells) do
        bomb_cell.map.isocells[bomb_cell.idx].tile = make_tile(false, TileType.BombItem)
    end

    -- generate the page item cells
    local page_fragments = { 172, 173, 188, 189 }
    local next_page_frag_idx = 0

    local page_cell_cnt = 10
    local page_cells = select_random_empty_tiles(maps, page_cell_cnt)
    for page_cell in all(page_cells) do
        page_cell.map.isocells[page_cell.idx].tile = make_tile(false, TileType.PageItem)
        page_cell.map.isocells[page_cell.idx].tile.page_frag = page_fragments[next_page_frag_idx + 1]
        next_page_frag_idx = ((next_page_frag_idx + 1) % #page_fragments)
    end

    -- Place the start and end tile on each map
    for map in all(maps) do
        -- set the start cell on this map.
        map.player_start_iso_idx = select_random_empty_tile_idx_from_map(map)
        map.isocells[map.player_start_iso_idx].tile = make_tile(true, TileType.Start)

        -- set the finish cell on this map.
        map.finish_cell_idx = select_random_empty_tile_idx_from_map(map)
        map.isocells[map.finish_cell_idx].tile = make_tile(false, TileType.Finish)
    end

    -- Lastly, now that all interesting cells have been placed, fill in the remaining empty
    -- cells with hint arrows
    for map in all(maps) do
        local iso_finish_cell_pos = map.isocells[map.finish_cell_idx].pos
        for cell in all(map.isocells) do
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
    end

    -- uncomment this to make all tiles visible at start
    -- for map in all(maps) do
    --     for cell in all(map.isocells) do
    --         cell.tile.visible = true
    --     end
    -- end

    return maps
end

function generate_empty_level(level_id, map_iso_width)
    -- generate a new map
    local next_map = {}
    next_map.level_id = level_id
    next_map.iso_width = map_iso_width

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

    return next_map
end

function make_tile(visible, tile_type)
    return { visible = visible, type = tile_type }
end

function select_random_empty_tile_idx_from_map(map)
    return select_random_empty_tiles({map}, 1)[1].idx
end

function select_random_empty_tiles(maps, select_count)
    local empty_cell_cnt = 0
    local empty_cells = {}
    for map in all(maps) do
        for cell in all(map.isocells) do
            if cell.tile.type == TileType.Empty then
                add(empty_cells, { map = map, idx = cell.idx })
                empty_cell_cnt += 1
            end
        end
    end

    local selected_cells = {}
    for i=1,select_count do
        local next_selected_empty_cell_idx = rnd_incrange(1, empty_cell_cnt)

        -- take the selected cell and update our collection so we have one less cell to select from
        local next_selected_empty_cell = empty_cells[next_selected_empty_cell_idx]
        empty_cells[next_selected_empty_cell_idx] = empty_cells[empty_cell_cnt]
        empty_cells[empty_cell_cnt] = nil

        add(selected_cells, next_selected_empty_cell)
    end

    return selected_cells
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
            --- return nil so we don't draw any sprites
            return nil
        elseif tile.type == TileType.BombItem then
            return 160
        elseif tile.type == TileType.PageItem then
            return 160
        else
            return nil
        end
    else
        return 96
    end
end

function move_to_level(next_level)
    -- update the current map
    g_map = g_maps[next_level]

    -- place the player on the center of the iso tile
    g_player.pos = copy_vec2(g_map.isocells[g_map.player_start_iso_idx].pos)
    -- place the camera on top of the player
    g_camera_player_offset = get_centered_camera_on_player(g_player)

    -- reset the player's animation
    update_anim(g_player, g_anims.IdleDown)

    -- clear away any bombs on the board
    g_bombs = {}
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
    local old_player_pos = copy_vec2(g_player.pos)

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
        local cells = get_iso_cells_under_actor(g_map, g_player)
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

function sprite_pos(obj)
    return {
        x = obj.pos.x + obj.sprite_offset.x,
        y = obj.pos.y + obj.sprite_offset.y,
    }
end

function get_actor_iso_tile_idx(map, actor)
    -- N.B. Currently we do an extra smaller circle collider check so that we only activate at most one tile at a time
    -- even if we are standing in between two..
    for cell in all(get_iso_cells_under_actor(map, actor)) do
        if circ_colliders_overlap(actor, cell) then
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

function get_iso_cells_under_actor(map, actor)
    cells = {}
    for cell in all(map.isocells) do
        if is_iso_cell_under_actor(cell, actor) then
            add(cells, cell)
        end
    end

    return cells
end

function is_iso_cell_under_actor(cell, actor)
    -- divide up an iso-tile into 3 rect colliders
    local iso_sub_colliders = {
        { width = 12, height = 12 },
        { width = 18, height = 9 },
        { width = 26, height = 5 },
    }

    -- setup a simple rect-collider for the actor wrapping their circle collider
    local actor_rect_collider = {
        pos = {
            x = actor.pos.x - actor.collider.radius,
            y = actor.pos.y - actor.collider.radius,
        },
        width = (actor.collider.radius + actor.collider.radius),
        height = (actor.collider.radius + actor.collider.radius),
    }

    local cell_pos_x = cell.pos.x
    local cell_pos_y = cell.pos.y
    for sub_collider in all(iso_sub_colliders) do
        -- center the subcollider in the iso cell
        sub_collider.pos = { x = cell_pos_x - (sub_collider.width/2), y = cell_pos_y - (sub_collider.height/2) }
        if rect_colliders_overlap(actor_rect_collider, sub_collider) then
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

function new_bomb(pos)
    local self = {
        state = "Countdown",
        countdown_anim = g_anims.BombCountdown,
        explosion_timer = make_ingame_timer(32),
        explosions = {},
        active_explosions = {},
        pos = copy_vec2(pos),
    }

    function get_center_draw_pos(pos, width, height)
        return { x = pos.x - width/2, y = pos.y - height/2 }
    end

    function generate_explosions(pos)
        local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
        local up_right = { x =  2 * sqrt_half, y = -1 * sqrt_half }
        local up_left = { x = -2 * sqrt_half, y = -1 * sqrt_half }
        local down_right = { x =  2 * sqrt_half, y =  1 * sqrt_half }
        local down_left = { x = -2 * sqrt_half, y =  1 * sqrt_half }

        function generate_explosion(frame, pos)
            return { frame = frame, pos = pos, collider = { radius = 3 } }
        end

        local explosion_scale = 10
        return {
            generate_explosion(  0, copy_vec2(pos)),       -- center
            generate_explosion( -8, add_vec2(pos, scale_vec2(   up_left, 1 * explosion_scale))), -- up left 1
            generate_explosion(-16, add_vec2(pos, scale_vec2(   up_left, 2 * explosion_scale))), -- up left 2
            generate_explosion(-24, add_vec2(pos, scale_vec2(   up_left, 3 * explosion_scale))), -- up left 3
            generate_explosion( -8, add_vec2(pos, scale_vec2(  up_right, 1 * explosion_scale))), -- up right 1
            generate_explosion(-16, add_vec2(pos, scale_vec2(  up_right, 2 * explosion_scale))), -- up right 2
            generate_explosion(-24, add_vec2(pos, scale_vec2(  up_right, 3 * explosion_scale))), -- up right 3
            generate_explosion( -8, add_vec2(pos, scale_vec2( down_left, 1 * explosion_scale))), -- down left 1
            generate_explosion(-16, add_vec2(pos, scale_vec2( down_left, 2 * explosion_scale))), -- down left 2
            generate_explosion(-24, add_vec2(pos, scale_vec2( down_left, 3 * explosion_scale))), -- down left 3
            generate_explosion( -8, add_vec2(pos, scale_vec2(down_right, 1 * explosion_scale))), -- down right 1
            generate_explosion(-16, add_vec2(pos, scale_vec2(down_right, 2 * explosion_scale))), -- down right 2
            generate_explosion(-24, add_vec2(pos, scale_vec2(down_right, 3 * explosion_scale))), -- down right 3
        }
    end

    local update = function()
        if self.state == "Countdown" then
            update_anim(self, self.countdown_anim)
            if self.anim_state.loop > 0 then
                self.state = "Explode"
                self.explosions = generate_explosions(self.pos)
            end
        elseif self.state == "Explode" then
            self.explosion_timer.update()
            if self.explosion_timer.done() then
                self.state = "Done"
                self.explosions = {}
                self.active_explosions = {}
            end
            for e in all(self.explosions) do
                e.frame += 1
                if e.frame == 1 then
                    add(self.active_explosions, e)
                elseif e.frame == 13 then
                    del(self.active_explosions, e)
                end
            end
        else
            -- Done; noop
        end
    end

    local done = function()
        return self.state == "Done"
    end

    local draw = function()
        if self.state == "Countdown" then
            -- draw the bomb sprite
            draw_anim(self, get_center_draw_pos(self.pos, 8, 8))
        elseif self.state == "Explode" then
            for e in all(self.explosions) do
                local full_scale = 2
                local scale = (full_scale - 1) * ((6 - abs(e.frame - 6)) / 6) + 1
                if     e.frame < 0 then
                    -- noop, this part of the explosion hasn't started yet
                elseif e.frame < 4 then
                    sspr_centered(90, e.pos.x, e.pos.y, 1, 1, scale)
                elseif e.frame < 8 then
                    sspr_centered(91, e.pos.x, e.pos.y, 1, 1, scale)
                elseif e.frame < 12 then
                    sspr_centered(90, e.pos.x, e.pos.y, 1, 1, scale)
                else
                    -- noop, the explosion is over
                end
            end
        else
            -- Done; noop
        end
    end

    local get_explosions = function ()
        return self.active_explosions
    end

    return {
        update = update,
        draw = draw,
        done = done,
        get_explosions = get_explosions
    }
end

function isomap_row_cnt(map)
    return map.iso_width * 2 - 1
end

function copy_vec2(v)
    return { x = v.x, y = v.y }
end

function add_vec2(v1, v2)
    return { x = v1.x + v2.x, y = v1.y + v2.y }
end

function sub_vec2(v1, v2)
    return { x = v1.x - v2.x, y = v1.y - v2.y }
end

function scale_vec2(v, s)
    return { x = v.x * s, y = v.y * s }
end
