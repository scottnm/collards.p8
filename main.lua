-- main game

TileType = {
    Empty = 1,
    FloorEntry = 2,
    FloorExit = 3,
    Trap = 4,
    Fall = 5,
    BombItem = 6,
    PageItem = 7,
    Altar = 8,
    StoneFloor = 9,
}

ItemType = {
    Bomb = 1,
    Page = 2,
    Book = 3,
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

BookState = {
    NotFound = 1,
    FoundButLost = 2,
    Holding = 3,
}

-- constants
function TILE_SIZE() return 11.3135 end -- precomputed; results in 32x16 iso tiles
function ISO_TILE_WIDTH() return 32 end -- FIXME: still using?
function ISO_TILE_HEIGHT() return 16 end
function MAX_TILE_LINE() return 9 end
function MAX_CAMERA_DISTANCE_FROM_PLAYER() return 20 end
function TOTAL_PAGE_COUNT() return 10 end
function MAINGAME_TIME_LIMIT() return 5 * 60 * 30  end -- five minutes in ticks
SQRT_HALF = 0.70710678118 -- sqrt(0.5); hardcode since sqrt is expensive

function world_to_iso(wp)
    local ip = vec(SQRT_HALF * (wp.x - wp.y), SQRT_HALF * (wp.x + wp.y)) -- rotate
    ip.x *= 2 -- scale
    return vec_add(ip, vec(64,64)) -- translate to center
end

function iso_to_world(ip)
    local wp = vec_add(ip, vec(-64,-64)) -- translate from center
    wp.x /= 2 -- scale
    return vec(SQRT_HALF * (wp.x - wp.y), SQRT_HALF * (wp.x + wp.y)) -- rotate
end

function _init_main_game()
    g_banner = nil
    g_maingame_tick_count = 0
    g_game_over_state = nil
    g_player = {
        book_state = BookState.NotFound,
        pos = vec(0, 0),
        sprite_offset = vec(-8, -14),
        collider = { radius = 3 },
        bomb_count = 0,
        collected_pages = {},
    }

    g_camera_player_offset = vec(0, 0)

    g_game_timer_ui = make_ui_timer(on_ui_timer_shake, MAINGAME_TIME_LIMIT())

    g_maps = gen_maps(10)
    move_to_level(1, TileType.FloorEntry)

    g_detector = { cursor_val = 0, cursor_target = 0, next_scan = 0 }
    music(0, 1000, 7)
end

function _init_game_over()
    -- noop
end

function _update_main_game(input)
    g_maingame_tick_count += 1

    -- update our in-game accelerated timer UI
    g_game_timer_ui.update(g_maingame_tick_count)

    -- update the metal detector ui
    update_detector(g_detector)

    -- handle input blocking animation states
    local block_input = false
    if g_player.dig_state != nil then
        -- update the dig animation
        update_anim(g_player, g_player.dig_state.anim)

        -- fire the on_dig_up callback exactly once when we start the 'dig up' animation
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
        -- update the collect item animation
        update_anim(g_player, g_player.collect_item_state.anim)
        g_player.collect_item_state.anim_timer.update()
        if g_player.collect_item_state.anim_timer.done() then
            g_player.collect_item_state = nil
        end
        block_input = true
    elseif g_player_move_to_floor_state != nil then
        g_player_move_to_floor_state.timer.update()
        if g_player_move_to_floor_state.timer.done() then
            local next_level = g_player_move_to_floor_state.next_level
            local next_start_tile = g_player_move_to_floor_state.start_tile
            g_player_move_to_floor_state = nil
            move_to_level(next_level, next_start_tile)
        end
        block_input = true
    elseif g_player.die_state != nil then
        update_anim(g_player, g_player.die_state.anim)
        g_player.die_state.respawn_timer.update()
        if g_player.die_state.respawn_timer.done() then
            g_player.die_state = nil
            move_to_level(1, TileType.FloorEntry)
        end
        block_input = true
    end

    -- if we aren't blocking new input, process it
    if not block_input then
        handle_new_input(input)
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
            local explosion_cells = get_cells_under_actor(g_map, e)
            for cell in all(explosion_cells) do
                cell.tile.visible = true
            end

            -- check for player-explosion collisions if the player isn't already dead
            if (g_player.die_state == nil) and (circ_colliders_overlap(g_player, e)) then
                kill_player(g_player, g_map)
            end
        end
    end

    -- clean up any bombs which have finished
    for bomb in all(finished_bombs) do
        del(g_bombs, bomb)
    end

    if g_maingame_tick_count >= MAINGAME_TIME_LIMIT() then
        handle_game_over(false)
    end
end

function collect_item(player, item_type, item_args)
    player.collect_item_state = {
        anim = g_anims.CollectItem,
        item = item_type,
        anim_timer = make_ingame_timer(45),
    }

    for k,v in pairs(item_args or {}) do
        player.collect_item_state[k] = v
    end

    local item_text = nil
    if item_type == ItemType.Bomb then
        item_text = "bomb. \151 to use"
    elseif item_type == ItemType.Page then
        item_text = "page fragment"
    elseif item_type == ItemType.Book then
        item_text = "granddaddy's book"
    else
        assert(false)
    end
    set_banner("got: "..item_text, "item", 60)

    sfx(Sfxs.GetItem)
end

function start_move_to_floor(next_level, start_tile_type, stair_sfx)
    g_player_move_to_floor_state = {
        timer = make_ingame_timer(15),
        next_level = next_level,
        start_tile = start_tile_type,
    }
    sfx(stair_sfx)
end

function handle_new_input(input)
    move_player(input)
    animate_player(input)

    local is_digging = input.btn_o and input.btn_o_change

    if is_digging then
        g_player.dig_state = {
            anim = get_dig_anim_for_player(g_player),
            previous_anim = g_player.anim_state.last_anim }
        -- reset the anim state so the digging animation always starts on frame 0
        reset_anim(g_player)

    end

    local player_tile_idx = get_actor_tile_idx(g_map, g_player)
    if player_tile_idx != nil then
        local player_cell = g_map.cells[player_tile_idx]

        -- If we've just dug up a tile, we'll set a callback so that after
        -- the digging animation reveals the tile, we'll automatically
        -- interact with it.
        if is_digging then
            local reveal_tile_callback = function()
                sfx(Sfxs.Dig)
                player_cell.tile.visible = true
                interact_with_tile(player_cell.tile)
            end
            g_player.dig_state.on_dig_up = reveal_tile_callback
        elseif player_cell.tile.visible then
            interact_with_tile(player_cell.tile)
            g_player.last_interacted_cell = player_cell
        elseif player_cell.tile.has_book then
            -- HACK: special case to support picking up books from unrevealed tiles
            g_player.book_state = BookState.Holding
            player_cell.tile.has_book = false
            collect_item(g_player, ItemType.Book)
            g_player.last_interacted_cell = player_cell
        end

        g_player.last_visited_cell = player_cell
    end

    -- Handle placing new bombs
    local try_place_bomb = input.btn_x and input.btn_x_change
    if try_place_bomb then
        if g_player.bomb_count > 0 then
            g_player.bomb_count -= 1
            add(g_bombs, new_bomb(g_player.pos, on_explosion_start))
        end
    end

end

function on_explosion_start()
    sfx(Sfxs.Explosion)
end

function kill_player(player, map)
    local died_text = "died."
    if player.book_state == BookState.Holding then
        -- drop the book in a random safe cell
        local safe_tile_idx = select_random_empty_tile_idx_from_map(map)
        map.cells[safe_tile_idx].tile.has_book = true
        g_player.book_state = BookState.FoundButLost
        died_text = died_text.." dropped book."
    end

    player.die_state = {
        anim = get_die_anim_for_player(player),
        respawn_timer = make_ingame_timer(60),
    }

    set_banner(died_text, "death", 60)
    sfx(Sfxs.Death)
end

function interact_with_tile(tile)
    -- only interact with a tile the first time you step on it.
    if tile == g_player.last_interacted_cell.tile then
        return
    end

    if tile.type == TileType.FloorExit then
        start_move_to_floor(g_map.level_id + 1, TileType.FloorEntry, Sfxs.DownStairs)
    elseif tile.type == TileType.FloorEntry then
        -- if we haven't found the book and we try to leave, warn the player
        if g_player.book_state == BookState.NotFound then
            set_banner("can't leave until i find it.", "warning", 90)
        elseif g_player.book_state == BookState.FoundButLost then
            -- if we've found the book but lost it we can freely traverse all floors... EXCEPT we can't leave
            if g_map.level_id != 1 then
                start_move_to_floor(g_map.level_id - 1, TileType.FloorExit, Sfxs.UpStairs)
            else
                set_banner("can't leave. i lost the book.", "warning", 90)
            end
        elseif g_player.book_state == BookState.Holding then
            -- we have the book. we can traverse up any floor AND win the game by leaving the last floor
            if g_map.level_id != 1 then
                start_move_to_floor(g_map.level_id - 1, TileType.FloorExit, Sfxs.UpStairs)
            else
                handle_game_over(true)
            end
        else
            assert(false)
        end
    elseif tile.type == TileType.Trap then
        kill_player(g_player, g_map)
    elseif tile.type == TileType.BombItem then
        g_player.bomb_count += 1
        collect_item(g_player, ItemType.Bomb)
        -- after we've picked up the bomb, turn the cell into a hintless empty cell
        tile.type = TileType.Empty
    elseif tile.type == TileType.PageItem then
        add(g_player.collected_pages, tile.page_frag)
        collect_item(g_player, ItemType.Page, { page_frag = tile.page_frag })
        -- after we've picked up the page, turn the cell into a hintless empty cell
        tile.type = TileType.Empty
        tile.page_frag = nil
    elseif tile.has_book then
        g_player.book_state = BookState.Holding
        tile.has_book = false
        collect_item(g_player, ItemType.Book)
    end
end

function on_ui_timer_shake()
    sfx(Sfxs.ClockBeep)
end

function is_player_facing_left(player)
    local last_anim = player.anim_state.last_anim
    return (last_anim == g_anims.IdleLeft or
            last_anim == g_anims.WalkLeft or
            last_anim == g_anims.IdleUpLeft or
            last_anim == g_anims.WalkUpLeft or
            last_anim == g_anims.IdleDownLeft or
            last_anim == g_anims.WalkDownLeft)
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
    return vec(player.pos.x - 64, player.pos.y - 64)
end

function camera_follow_player(player, camera_ofs)
    -- If the camera is already within the max allowed distance from the player don't move the camera
    local player_camera_center_ofs = get_centered_camera_on_player(player)
    local dist_squared = sqr_dist(player_camera_center_ofs, camera_ofs)
    if dist_squared <= sqr(MAX_CAMERA_DISTANCE_FROM_PLAYER()) then
        return
    end

    -- If the camera is outside of the max allowed distance, move it closer
    local dir_vec = vec_sub(camera_ofs, player_camera_center_ofs)

    -- get a unit vector for the direction to move the camera
    local dist = sqrt(dist_squared)
    dir_vec.x /= dist
    dir_vec.y /= dist

    -- multiply the max distance to get our max distance from player
    dir_vec.x *= MAX_CAMERA_DISTANCE_FROM_PLAYER()
    dir_vec.y *= MAX_CAMERA_DISTANCE_FROM_PLAYER()

    new_ofs = vec_add(player.pos, dir_vec)
    camera_ofs.x = new_ofs.x - 64
    camera_ofs.y = new_ofs.y - 64
end

function _update_game_over(input)
    g_game_timer_ui.update(g_maingame_tick_count)

    if g_game_over_state.substate == "scroll_timer" then
        g_game_over_state.timer_scroll += 1
        g_game_timer_ui.move(0, 0.5)
        if g_game_over_state.timer_scroll == 120 then
            g_game_over_state.substate = "brief_blink"
            g_game_over_state.final_blink = make_ingame_timer(120)
        end
    elseif g_game_over_state.substate == "brief_blink" then
        g_game_over_state.final_blink.update()
        if g_game_over_state.final_blink.done() then
            g_game_over_state.substate = "display_game_over_text"
            g_game_over_state.game_over_text_roll_spd = 0.8 -- chars per frame
            g_game_over_state.game_over_text_frame_cnt = 0
            g_game_over_state.game_over_text_final_frame_cnt = (#g_game_over_state.game_over_text) / g_game_over_state.game_over_text_roll_spd
        end
    elseif g_game_over_state.substate == "display_game_over_text" then
        g_game_over_state.game_over_text_frame_cnt += 1
        local text_finished = g_game_over_state.game_over_text_frame_cnt >= g_game_over_state.game_over_text_final_frame_cnt
        if text_finished and (input.btn_x_change or input.btn_o_change) then
            set_phase(GamePhase.PreGame)
        end
    end
end

function _draw_main_game()
    cls(Colors.BLACK)

    -- Set the camera view so that the world is draw relative to its position
    camera_follow_player(g_player, g_camera_player_offset)
    camera(g_camera_player_offset.x, g_camera_player_offset.y);

    -- draw the tiles
    for cell in all(g_map.cells) do
        local frame_idx = get_tile_sprite_frame(cell.tile)
        if frame_idx != nil then
            -- DRAW A THIN BORDER
            local icp = world_to_iso(cell.pos)
            spr(128, icp.x - ISO_TILE_WIDTH()/2, icp.y, 4, 2, false)
            spr(frame_idx, icp.x - ISO_TILE_WIDTH()/2, icp.y - ISO_TILE_HEIGHT()/2, 4, 2, false)

            if cell.tile.visible then
                -- draw the hint arrow if the empty hint cell is visible
                if (cell.tile.type == TileType.Empty) and (cell.tile.hint != nil) then
                    draw_hint_arrow(cell.pos, cell.tile.hint)
                -- If it's an unretrieved bomb cell, display an inactive bomb sprite in the middle of the cell.
                -- This basically only happens if you use a bomb to reveal another bomb.
                elseif cell.tile.type == TileType.BombItem then
                    draw_bomb_item(cell.pos)
                elseif cell.tile.type == TileType.PageItem then
                    draw_page_item(cell.pos, cell.tile.page_frag)
                elseif cell.tile.type == TileType.Altar then
                    -- draw the altar
                    spr_centered(88, cell.pos.x, cell.pos.y, 2, 1)
                end
            end

            if cell.tile.has_book then
                draw_book(cell.pos, cell.tile.type == TileType.Altar)
            end
        end
    end

    -- if the player is standing on their last visited tile, highlight it
    if circ_colliders_overlap(g_player, g_player.last_visited_cell) then
        highlight_cell(g_player.last_visited_cell)
    end

    -- draw the player
    draw_anim(g_player, sprite_pos(g_player))

    -- if the player is collecting an item, draw the item above their collect animation
    if g_player.collect_item_state != nil then
        local item_pos = vec_sub(g_player.pos, vec(0, 16))
        if g_player.collect_item_state.item == ItemType.Bomb then
            draw_bomb_item(item_pos)
        elseif g_player.collect_item_state.item == ItemType.Page then
            draw_page_item(item_pos, g_player.collect_item_state.page_frag)
        elseif g_player.collect_item_state.item == ItemType.Book then
            draw_book(item_pos, false)
        end
    end

    -- draw any active bombs
    for bomb in all(g_bombs) do
        bomb.draw()
    end

    --
    -- Draw all UI unaffected by the camera
    --

    -- reset the camera to 0 keep the UI fixed on screen
    camera(0, 0)

    -- draw the level UI
    print("Level: "..g_map.level_id, 0, 120, Colors.White)

    -- draw any banners if set
    if g_banner != nil then
        draw_banner(g_banner.text, g_banner.fg_color, g_banner.bg_color)
        g_banner.timer.update()
        if g_banner.timer.done() then
            g_banner = nil
        end
    end

    -- draw the metal detector
    draw_detector_ui(g_detector)

    -- draw the bomb counter UI
    draw_bomb_item(vec(4, 111))
    print(":"..g_player.bomb_count, 8, 110, Colors.White)

    -- draw the book UI
    draw_book_ui(g_player)

    -- draw the in-game timer UI
    g_game_timer_ui.draw(g_maingame_tick_count)
end

function _draw_game_over()
    cls(Colors.BLACK)

    if g_game_over_state.substate != "display_game_over_text" then
        -- Set the camera view so that the world is draw relative to its position
        camera_follow_player(g_player, g_camera_player_offset)
        camera(g_camera_player_offset.x, g_camera_player_offset.y);

        -- draw the player frozen at the game_over state
        local player_sprite_pos = sprite_pos(g_player)
        draw_anim(g_player, player_sprite_pos)

        -- draw the book UI
        draw_book_ui(g_player)

        -- reset the camera to 0 keep the UI fixed on screen
        camera(0, 0)

        -- draw the level UI
        print("Level: "..g_map.level_id, 0, 120, Colors.White)

        -- draw the in-game timer UI
        g_game_timer_ui.draw(g_maingame_tick_count)
    else

        local rolled_text_ratio = (g_game_over_state.game_over_text_roll_spd * g_game_over_state.game_over_text_frame_cnt) / g_game_over_state.game_over_text_final_frame_cnt
        draw_text_roll(g_game_over_state.game_over_text, rolled_text_ratio, 10, 10, nil, 17)

        -- draw the book UI
        draw_book_ui(g_player)
    end
end

function update_detector(detector)
    g_cursor_speed = 0.04

    local do_proximity_scan = false
    detector.next_scan -= 1
    if detector.next_scan <= 0 then
        do_proximity_scan = true
        detector.next_scan = 15
    end

    -- if we need to do a proximity scan, calculate the
    if do_proximity_scan then
        local max_interference = 0
        for cell in all(g_map.cells) do
            local ttype = cell.tile.type
            if ttype == TileType.BombItem or ttype == TileType.PageItem then
                local item_dist = sqrt(sqr_dist(g_player.pos, cell.pos));
                -- detector values move between 0 and 1
                local item_interference = clamp(0, 1 - (item_dist/48), 1)
                max_interference = max(max_interference, item_interference)
            end
        end
        detector.cursor_target = max_interference
    end

    if detector.cursor_val > detector.cursor_target then
        detector.cursor_val = max(detector.cursor_val - g_cursor_speed, detector.cursor_target)
    else
        detector.cursor_val = min(detector.cursor_val + g_cursor_speed, detector.cursor_target)
    end
end

function draw_detector_ui(detector)
    g_dui = { x = 2, y = 20, w = 8, h = 50 }

    rect(g_dui.x, g_dui.y, g_dui.x + g_dui.w, g_dui.y + g_dui.h, Colors.White)

    -- add some shake on ~30% of frames
    local cursor_shake = 0
    if rnd(1) > 0.7 then
        cursor_shake = (rnd(2) - 1) / g_dui.h
    end

    -- cursor_val is a ratio between 0->1 of how far up the detector bar the cursor should be
    -- invert the ratio since y values grow downwards
    -- clamp between 0.05 and 0.95 so our cursor is always within the detector UI
    local adj_cursor_val = clamp(0.05, 1 - detector.cursor_val + cursor_shake, 0.95)
    local cursor_y = g_dui.y + (g_dui.h * adj_cursor_val)
    line(g_dui.x, cursor_y, g_dui.x + (g_dui.w * .60), cursor_y)

    -- draw markers on the meter to make this look more like a measuring device
    g_num_markers = 5
    for i=1,g_num_markers do
        local marker_ofs = flr(g_dui.h/(g_num_markers+1)) * i
        pset(g_dui.x+g_dui.w-1, g_dui.y + marker_ofs, Colors.White)
    end
end

function draw_book_ui(player)
    -- Book UI is drawn in screenspace. Temporarily reset the camera.
    cam_state = save_cam_state()
    camera(0, 0)

    local tile_px_width = 8
    for i=1,#g_player.collected_pages do
        local x_ofs = i*tile_px_width
        draw_page_item(vec(120-x_ofs, 120), g_player.collected_pages[i])
    end

    if player.book_state == BookState.Holding then
        draw_book(vec(120, 120), false)
    end

    restore_cam_state(cam_state)
end

function center_text(rect, text)
    local text_len = #text
    local text_width = 4 * text_len
    local text_height = 6
    local text_x = rect.x + (rect.width/2) - (text_width/2)
    local text_y = rect.y + (rect.height/2) - (text_height/2)
    -- y + 1 to account for the extra pixel buffer below the font
    return vec(text_x, text_y + 1)
end

function draw_hint_arrow(pos, hint)
    local frame = nil
    local flip_x = false
    local flip_y = false

    if     hint == HintArrow.Right then
        frame = 134
    elseif hint == HintArrow.DownRight then
        frame = 133
        flip_y = true
    elseif hint == HintArrow.Down then
        frame = 132
        flip_y = true
    elseif hint == HintArrow.DownLeft then
        frame = 133
        flip_x = true
        flip_y = true
    elseif hint == HintArrow.Left then
        frame = 134
        flip_x = true
    elseif hint == HintArrow.UpLeft then
        frame = 133
        flip_x = true
    elseif hint == HintArrow.Up then
        frame = 132
    else -- hint == HintArrow.UpRight
        frame = 133
    end

    spr_centered(frame, pos.x, pos.y, 1, 1, flip_x, flip_y)
end

function draw_bomb_item(pos)
    spr_centered(74, pos.x, pos.y, 1, 1)
end

function draw_page_item(pos, sprite)
    spr_centered(sprite, pos.x, pos.y, 1, 1)
end

function draw_book(pos, on_altar)
    local y_ofs = 0 -- book on floor
    if on_altar then
        y_ofs = 4 -- book on altar
    end
    spr_centered(72, pos.x, pos.y - y_ofs, 1, 1)
end

function set_banner(text, banner_type, banner_time)
    local fg_color, bg_color = nil, nil
    if banner_type == "warning" then
        fg_color, bg_color = Colors.Tan, Colors.BlueGray
    elseif banner_type == "item" then
        fg_color, bg_color = Colors.DarkGreen, Colors.Tan
    elseif banner_type == "death" then
        fg_color, bg_color = Colors.Red, Colors.Navy
    end

    g_banner = {
        text = text,
        fg_color = fg_color,
        bg_color = bg_color,
        timer = make_ingame_timer(banner_time),
    }
end

function draw_banner(text, fg_color, bg_color)
    -- Banners are drawn in screenspace. Temporarily reset the camera.
    cam_state = save_cam_state()
    camera(0, 0)

    local bg_rect = { x = 0, y = 98, width = 128, height = 10 }
    rectfill(bg_rect.x, bg_rect.y, bg_rect.x + bg_rect.width, bg_rect.y + bg_rect.height, bg_color)
    rect(bg_rect.x + 1, bg_rect.y + 1, bg_rect.x + bg_rect.width - 2, bg_rect.y + bg_rect.height - 1, fg_color)
    local text_pos = center_text(bg_rect, text)
    print(text, text_pos.x, text_pos.y, fg_color)

    restore_cam_state(cam_state)
end

function gen_maps(num_maps)
    local maps = {}

    for i=1,(num_maps - 1) do
        -- the levels increase in size from 2 -> MAX_TILE_LINE()
        local map_size = min((i + 1), MAX_TILE_LINE())
        add(maps, gen_empty_level(i, map_size))
    end

    -- Place the start and finish tile on each map FIRST to guarantee there's room
    for map in all(maps) do
        local player_start_idx = select_random_empty_tile_idx_from_map(map)
        map.cells[player_start_idx].tile = make_tile(true, TileType.FloorEntry)

        map.finish_cell_idx = select_random_empty_tile_idx_from_map(map)
        map.cells[map.finish_cell_idx].tile = make_tile(false, TileType.FloorExit)
    end

    -- Set the trap cells on each map. On each map ~%30 of tiles have traps.
    for map in all(maps) do
        local trap_cnt = flr(map.size * map.size * 0.30)
        local trap_cells = select_random_empty_tiles({map}, trap_cnt)
        for trap_cell in all(trap_cells) do
            map.cells[trap_cell.idx].tile = make_tile(false, TileType.Trap)
        end
    end

    -- set the bomb item cells
    -- There are a total of 10 bombs across the whole game
    local bomb_cnt = 10
    local bomb_cells = select_random_empty_tiles(maps, bomb_cnt)
    for bomb_cell in all(bomb_cells) do
        bomb_cell.map.cells[bomb_cell.idx].tile = make_tile(false, TileType.BombItem)
    end

    -- set the page item cells
    local page_fragments = { 172, 173, 188, 189 }
    local next_page_frag_idx = 0

    local page_cell_cnt = TOTAL_PAGE_COUNT()
    local page_cells = select_random_empty_tiles(maps, page_cell_cnt)
    for page_cell in all(page_cells) do
        page_cell.map.cells[page_cell.idx].tile = make_tile(false, TileType.PageItem)
        page_cell.map.cells[page_cell.idx].tile.page_frag = page_fragments[next_page_frag_idx + 1]
        next_page_frag_idx = ((next_page_frag_idx + 1) % #page_fragments)
    end

    -- Now that all interesting cells have been placed, fill in the remaining empty cells with hint arrows
    for map in all(maps) do
        local finish_cell_iso_pos = world_to_iso(map.cells[map.finish_cell_idx].pos)
        for cell in all(map.cells) do
            if cell.tile.type == TileType.Empty then
                local cell_iso_pos = world_to_iso(cell.pos)
                local dir_vec = vec_sub(finish_cell_iso_pos, cell_iso_pos)
                local unit_circle_ratio = atan2(dir_vec.x, -1 * dir_vec.y)
                local angle_to_finish_point_deg = unit_circle_ratio * 360

                local hint = nil
                if     angle_to_finish_point_deg <  22.5 then
                    hint = HintArrow.Right
                elseif angle_to_finish_point_deg <  67.5 then
                    hint = HintArrow.DownRight
                elseif angle_to_finish_point_deg < 112.5 then
                    hint = HintArrow.Down
                elseif angle_to_finish_point_deg < 157.5 then
                    hint = HintArrow.DownLeft
                elseif angle_to_finish_point_deg < 202.5 then
                    hint = HintArrow.Left
                elseif angle_to_finish_point_deg < 247.5 then
                    hint = HintArrow.UpLeft
                elseif angle_to_finish_point_deg < 292.5 then
                    hint = HintArrow.Up
                elseif angle_to_finish_point_deg < 337.5 then
                    hint = HintArrow.UpRight
                else
                    hint = HintArrow.Right
                end

                cell.tile.hint = hint
            end
        end
    end

    -- Create the last level which has a unique structure:
    -- It's just the single goal item in the middle of an empty layer.
    local final_map = gen_empty_level(num_maps, MAX_TILE_LINE())
    -- set the altar point in middle
    local altar_cell_idx = flr(#final_map.cells / 2) + 1
    final_map.cells[altar_cell_idx].tile = make_tile(true, TileType.Altar)
    final_map.cells[altar_cell_idx].tile.has_book = true
    -- set the final level's entry
    local final_map_start_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.cells[final_map_start_idx].tile = make_tile(true, TileType.FloorEntry)
    -- turn every other cell into a stone floor cell
    for cell in all(final_map.cells) do
        if cell.tile.type == TileType.Empty then
            cell.tile = make_tile(true, TileType.StoneFloor)
        end
    end
    add(maps, final_map)

    return maps
end

function gen_empty_level(level_id, map_size)
    -- create a new map
    local next_map = {
        level_id=level_id,
        size=map_size,
        cells={} }

    -- wrap the map with a ring of invisible fall tiles. adds 2 rows to each side
    local idx = 1
    local size_with_border = map_size + 2
    local mid = flr((size_with_border + 1) / 2)
    for row=1,size_with_border do
        local row_offset = (row - mid) * TILE_SIZE()
        for col=1,size_with_border do
            local col_offset = (col - mid) * TILE_SIZE()

            local tile = nil
            local is_edge_tile = (row==1) or (row==size_with_border) or (col==1) or (col==size_with_border)
            local tile_type = nil

            -- initialize all the border cells as fall tiles and all the interior cells as empty
            if is_edge_tile then
                tile_type = TileType.Fall
            else
                tile_type = TileType.Empty
            end

            local cell = {
                idx = idx,
                tile = make_tile(is_edge_tile, tile_type),
                pos = vec(col_offset - TILE_SIZE()/2, row_offset - TILE_SIZE()/2),
                collider = { radius = 4 }
            }

            add(next_map.cells, cell)
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
    local empty_cells = {}
    for map in all(maps) do
        for cell in all(map.cells) do
            if cell.tile.type == TileType.Empty then
                add(empty_cells, { map=map, idx=cell.idx })
            end
        end
    end

    local selected_cells = {}
    for i=1,select_count do
        -- take the selected cell and update our collection so we have one less cell to select from
        local selected_cell_idx = rnd_incrange(1, #empty_cells)
        local cell = empty_cells[selected_cell_idx]
        empty_cells[selected_cell_idx] = deli(empty_cells)
        add(selected_cells, selected_cell)
    end

    return selected_cells
end

function get_tile_sprite_frame(tile)
    if tile.visible then
        local ttype = tile.type
        if ttype == TileType.Empty then
            return 160
        elseif ttype == TileType.FloorEntry then
            return 108
        elseif ttype == TileType.FloorExit then
            return 104
        elseif ttype == TileType.Trap then
            return 76
        elseif ttype == TileType.Fall then
            return nil -- return nil so we don't draw any sprites
        elseif ttype == TileType.BombItem then
            return 160
        elseif ttype == TileType.PageItem then
            return 160
        elseif ttype == TileType.Altar then
            return 140
        elseif ttype == TileType.StoneFloor then
            return 136
        else
            return nil
        end
    else
        -- tiles on the bottom floor are never be covered
        assert(ttype != TileType.Altar and ttype != TileType.StoneFloor)
        return 96
    end
end

function move_to_level(next_level, start_tile_type)
    -- update the current map
    g_map = g_maps[next_level]

    -- place the player on the center of the tile
    local player_start_cell = nil
    for cell in all(g_map.cells) do
        if cell.tile.type == start_tile_type then
            player_start_cell = cell
            break
        end
    end
    assert(player_start_cell != nil)
    g_player.pos = vec_copy(player_start_cell.pos)
    g_player.last_visited_cell = player_start_cell
    g_player.last_interacted_cell = player_start_cell

    -- place the camera on top of the player
    g_camera_player_offset = get_centered_camera_on_player(g_player)

    -- reset the player's animation
    update_anim(g_player, g_anims.IdleDown)

    -- clear away any bombs on the board
    g_bombs = {}
end

function move_player(input)
    -- when traveling diagnonally, multiply by the factor sqrt(0.5) to avoid traveling further by going diagonally
    local dx = 0
    local dy = 0
    if input.btn_left then
        if input.btn_up then
            dx = -1
            dy = 0
        elseif input.btn_down then
            dx = 0
            dy = 1
        else
            dx = -1 * SQRT_HALF
            dy = 1 * SQRT_HALF
        end
    elseif input.btn_right then
        if input.btn_up then
            dx = 0
            dy = -1
        elseif input.btn_down then
            dx = 1
            dy = 0
        else
            dx = 1 * SQRT_HALF
            dy = -1 * SQRT_HALF
        end
    elseif input.btn_up then
        dx = 0
        dy = -1
    elseif input.btn_down then
        dx = 0
        dy = 1
    else
        return
    end

    -- FIXME: remove if not used
    local player_spd = 1.0 -- an arbitrary speed factor to hand tune movement speed to feel good
    dx *= player_spd
    dy *= player_spd

    -- copy the old position in case we need to roll back
    local old_player_pos = vec_copy(g_player.pos)

    -- test all potential movements and use the first one that doesn't put us on a fall tile
    local move_candidates = {}
    add(move_candidates, vec(dx, dy))
    if dx != 0 then
        add(move_candidates, vec(dx, 0))
    end
    if dy != 0 then
        add(move_candidates, vec(0, dy))
    end

    for move in all(move_candidates) do
        g_player.pos = vec_add(old_player_pos, move)

        local cells = get_cells_under_actor(g_map, g_player)
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

    -- no movements worked, rollback
    g_player.pos = old_player_pos
end

function animate_player(input)
    local anim = nil
    if input.btn_left then
        if input.btn_up then
            anim = g_anims.WalkUpLeft
        elseif input.btn_down then
            anim = g_anims.WalkDownLeft
        else
            anim = g_anims.WalkLeft
        end
    elseif input.btn_right then
        if input.btn_up then
            anim = g_anims.WalkUpRight
        elseif input.btn_down then
            anim = g_anims.WalkDownRight
        else
            anim = g_anims.WalkRight
        end
    elseif input.btn_up then
        anim = g_anims.WalkUp
    elseif input.btn_down then
        anim = g_anims.WalkDown
    else
        if g_player.anim_state.last_anim == g_anims.WalkLeft then
            anim = g_anims.IdleLeft
        elseif g_player.anim_state.last_anim == g_anims.WalkRight then
            anim = g_anims.IdleRight
        elseif g_player.anim_state.last_anim == g_anims.WalkUp then
            anim = g_anims.IdleUp
        elseif g_player.anim_state.last_anim == g_anims.WalkDown then
            anim = g_anims.IdleDown
        elseif g_player.anim_state.last_anim == g_anims.WalkUpLeft then
            anim = g_anims.IdleUpLeft
        elseif g_player.anim_state.last_anim == g_anims.WalkUpRight then
            anim = g_anims.IdleUpRight
        elseif g_player.anim_state.last_anim == g_anims.WalkDownLeft then
            anim = g_anims.IdleDownLeft
        elseif g_player.anim_state.last_anim == g_anims.WalkDownRight then
            anim = g_anims.IdleDownRight
        else
            anim = g_player.anim_state.last_anim
        end
    end

    update_anim(g_player, anim)
end

function sprite_pos(obj)
    return vec_add(obj.pos, obj.sprite_offset)
end

function get_actor_tile_idx(map, actor)
    for cell in all(get_cells_under_actor(map, actor)) do
        -- Active tile is checked using smaller circ collider to so that between tiles, no tile is active
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

function get_cells_under_actor(map, actor)
    cells = {}
    for cell in all(map.cells) do
        if is_cell_under_actor(cell, actor) then
            add(cells, cell)
        end
    end

    return cells
end

function is_cell_under_actor(cell, actor)
    -- FIXME: should I use an actor rect collider natively
    -- wrap actor's circle collider with a rect collider for easier collision checks
    local actor_rect_collider = {
        pos = vec(
            actor.pos.x - actor.collider.radius,
            actor.pos.y - actor.collider.radius),
        width = (actor.collider.radius + actor.collider.radius),
        height = (actor.collider.radius + actor.collider.radius),
    }

    -- FIXME: maybe refactor into some helper function?
    local cell_rect_collider = {
        pos = vec_sub(cell.pos, vec(TILE_SIZE()/2, TILE_SIZE()/2)),
        width = TILE_SIZE(),
        height = TILE_SIZE(),
    }

    return rect_colliders_overlap(actor_rect_collider, cell_rect_collider)
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

function highlight_cell(cell)
    local iso_pos = world_to_iso(cell.pos)
    local ipx = iso_pos.x
    -- For some reason, I need to subtract '1' from each of the y values. I haven't yet rationalized why. Figure out later.
    local ipy = iso_pos.y - 1
    local corners = {
        vec(ipx - ISO_TILE_WIDTH()/2, ipy),
        vec(ipx, ipy - ISO_TILE_HEIGHT()/2),
        vec(ipx + ISO_TILE_WIDTH()/2, ipy),
        vec(ipx, ipy + ISO_TILE_HEIGHT()/2),
    }

    line(corners[1].x, corners[1].y, corners[2].x, corners[2].y, Colors.White)
    line(corners[2].x, corners[2].y, corners[3].x, corners[3].y, Colors.White)
    line(corners[3].x, corners[3].y, corners[4].x, corners[4].y, Colors.White)
    line(corners[4].x, corners[4].y, corners[1].x, corners[1].y, Colors.White)
end

function new_bomb(pos, on_explosion_start)
    local self = {
        state = "Countdown",
        countdown_anim = g_anims.BombFlash,
        explosion_timer = make_ingame_timer(32),
        explosions = {},
        active_explosions = {},
        pos = vec_copy(pos),
        on_explosion_start = on_explosion_start
    }

    function gen_explosions(pos)
        local up_right = vec(2 * SQRT_HALF, -1 * SQRT_HALF)
        local up_left = vec(-2 * SQRT_HALF, -1 * SQRT_HALF)
        local down_right = vec(2 * SQRT_HALF, 1 * SQRT_HALF)
        local down_left = vec(-2 * SQRT_HALF, 1 * SQRT_HALF)

        function gen_explosion(frame, pos)
            return { frame = frame, pos = pos, collider = { radius = 3 } }
        end

        local explosion_scale = 10
        return {
            gen_explosion(  0, vec_copy(pos)),
            gen_explosion( -8, vec_add(pos, vec_scale(   up_left, 1 * explosion_scale))),
            gen_explosion(-16, vec_add(pos, vec_scale(   up_left, 2 * explosion_scale))),
            gen_explosion(-24, vec_add(pos, vec_scale(   up_left, 3 * explosion_scale))),
            gen_explosion( -8, vec_add(pos, vec_scale(  up_right, 1 * explosion_scale))),
            gen_explosion(-16, vec_add(pos, vec_scale(  up_right, 2 * explosion_scale))),
            gen_explosion(-24, vec_add(pos, vec_scale(  up_right, 3 * explosion_scale))),
            gen_explosion( -8, vec_add(pos, vec_scale( down_left, 1 * explosion_scale))),
            gen_explosion(-16, vec_add(pos, vec_scale( down_left, 2 * explosion_scale))),
            gen_explosion(-24, vec_add(pos, vec_scale( down_left, 3 * explosion_scale))),
            gen_explosion( -8, vec_add(pos, vec_scale(down_right, 1 * explosion_scale))),
            gen_explosion(-16, vec_add(pos, vec_scale(down_right, 2 * explosion_scale))),
            gen_explosion(-24, vec_add(pos, vec_scale(down_right, 3 * explosion_scale))),
        }
    end

    local update = function()
        if self.state == "Countdown" then
            update_anim(self, self.countdown_anim)
            if self.anim_state.loop > 0 then
                self.state = "Explode"
                self.explosions = gen_explosions(self.pos)
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
                    self.on_explosion_start()
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
            draw_anim(self, vec(self.pos.x - 4, self.pos.y - 4))
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

function gen_lose_text()
    return "you were unable to make\nyour way to the bottom\nof the grave in time.\n\nyour family's most\ncherished heirloom is\nlost. gone forever.\n\nthis is unacceptable.\nyou'll have to try again.\n\nx/c - to reset"
end

function gen_win_text(collected_page_count, total_page_count)
    local text = "you made it back with the book. a brown book stitched together with strong thread and thick brown pages. a family heirloom."
    if collected_page_count == 0 then
        text = text .. " opening the book you realize several pages are missing. maybe they're back down in the grave. at least you saved the book. in another life, maybe you could find those pages.\n\nx/c - to reset"
    elseif collected_page_count < total_page_count then
        local page_plural = nil
        if collected_page_count == 1 then
            page_plural = "page"
        else
            page_plural = "pages"
        end

        local gap_plural = nil
        if collected_page_count == (total_page_count - 1) then
            gap_plural = "is still 1 page missing. maybe the last page is"
        else
            gap_plural = "are still "..(total_page_count-collected_page_count).." pages missing. maybe the rest are"
        end

        text = text .. " setting the "..collected_page_count.." recovered "..page_plural.." in the book you realize there "..gap_plural.." back down in the grave. it's not whole, but there's comfort in what you have. in another life, maybe you could recover the rest.\n\nx/c - to reset"
    else
        text = text .. " setting all "..total_page_count.." pages you found below in the book, you realize the book is complete.\nit reveals its story to you.\n\nthe first page reads:\n\"collard greens. wash greens 7 times. tear 'em up. throw 'em in a large pot. cover greens with water.  add onion, garlic, some peppa, spoonful of vinegar, and one ham hock. cover the pot and bring to a boil.\n\nthe book's previous owner was a driven, young man who desperately wanted to raise his daughter well. a self-taught cook, he learned that the collard recipe was full of love, flavor, and the secret ingredient, perseverance. a giant sunday pot of collards became tradition, providing them with greens for the whole week.\"\nx/c - to reset"
    end
    return split_text(text)
end

function handle_game_over(game_won)
    g_game_over_state = {
        substate = "scroll_timer",
        timer_scroll = 0,
    }

    if game_won then
        g_game_over_state.game_over_text = gen_win_text(#g_player.collected_pages, TOTAL_PAGE_COUNT())
    else
        g_game_over_state.game_over_text = gen_lose_text()
    end
    g_game_timer_ui.set_blinking(true)
    set_phase(GamePhase.GameOver)
    music(-1, 1000)
end
