-- main.lua - main game logic

GamePhase = {
    PreGame = 1,
    MainGame = 2,
    GameOver = 3,
}

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
function ISO_TILE_WIDTH()
    return 32
end

function ISO_TILE_HEIGHT()
    return 16
end

function MAX_TILE_LINE()
    return 9
end

function MAX_CAMERA_DISTANCE_FROM_PLAYER()
    return 20
end

function TOTAL_PAGE_COUNT()
    return 10
end

function MAINGAME_TIME_LIMIT()
    return 5 * 60 * 30 -- five minutes worth of ticks
end

function _init()
    reset()
end

function reset()
    -- All global variables initialized here
    g_banner = nil
    g_maingame_tick_count = 0
    g_game_phase = GamePhase.PreGame
    g_game_over_state = nil
    g_player = {
        book_state = BookState.NotFound,
        pos = vec_new(0, 0),
        sprite_offset = vec_new(-8, -14),
        collider = { radius = 3 },
        bomb_count = 0,
        collected_pages = {},
    }

    g_camera_player_offset = vec_new(0, 0)

    g_anims = {
        IdleDown = create_anim({34}, 10, 2, false),
        WalkDown = create_anim({32, 34, 36}, 10, 2, false),
        IdleUp = create_anim({40}, 10, 2, false),
        WalkUp = create_anim({38, 40, 42}, 10, 2, false),
        IdleRight = create_anim({66}, 10, 2, false),
        WalkRight = create_anim({64, 66, 68}, 10, 2, false),
        IdleLeft = create_anim({66}, 10, 2, true),
        WalkLeft = create_anim({64, 66, 68}, 10, 2, true),
        IdleUpRight = create_anim({8}, 10, 2, false),
        WalkUpRight = create_anim({6, 8, 10}, 10, 2, false),
        IdleDownRight = create_anim({2}, 10, 2, false),
        WalkDownRight = create_anim({0, 2, 4}, 10, 2, false),
        IdleUpLeft = create_anim({8}, 10, 2, true),
        WalkUpLeft = create_anim({6, 8, 10}, 10, 2, true),
        IdleDownLeft = create_anim({2}, 10, 2, true),
        WalkDownLeft = create_anim({0, 2, 4}, 10, 2, true),
        DigRight = create_anim({12, 12, 14}, 5, 2, false),
        DigLeft = create_anim({12, 12, 14}, 5, 2, true),
        DieLeft = create_anim({70, 70, 238}, 5, 2, true),
        DieRight = create_anim({70, 70, 238}, 5, 2, false),
        CollectItem = create_anim({46}, 1, 2, false),
        BombFlash = create_anim({74, 74, 74, 74, 74, 74, 74, 75, 74, 74, 75, 74, 74, 75, 74}, 15, 1, false),
    }
    g_game_timer_ui = make_ui_timer(on_ui_timer_shake, MAINGAME_TIME_LIMIT())
    g_game_timer_ui.set_blinking(true)

    g_maps = gen_maps(10)
    move_to_level(1, TileType.FloorEntry)

    g_detector = { cursor_val = 0, cursor_target = 0, next_scan = 0 }
end

function _update()
    g_input = poll_input()

    if g_game_phase == GamePhase.MainGame then
        main_game_update(g_input)
    elseif g_game_phase == GamePhase.PreGame then
        pre_game_update(g_input)
    elseif g_game_phase == GamePhase.GameOver then
        game_over_update(g_input)
    end
end

function pre_game_update(input)
    local any_btn = (
       input.btn_left or
       input.btn_right or
       input.btn_up or
       input.btn_down or
       input.btn_o or
       input.btn_x)

    g_game_timer_ui.update(g_maingame_tick_count)
    if any_btn then
        g_game_timer_ui.set_blinking(false)
        g_game_phase = GamePhase.MainGame
        music(0, 1000, 7)
    end
end

function main_game_update(input)
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
        start_move_to_floor(g_map.level_id + 1, TileType.FloorEntry, Sfxs.UpStairs)
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
    return  vec_new(player.pos.x - 64, player.pos.y - 64)
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

function game_over_update(input)
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
        if text_finished and (input.btn_x or input.btn_o) then
            reset()
        end
    end
end

function _draw()
    if g_game_phase == GamePhase.MainGame or
       g_game_phase == GamePhase.PreGame then
       draw_game()
    elseif g_game_phase == GamePhase.GameOver then
        draw_game_over()
    end
end

function draw_game()
    cls(Colors.BLACK)

    -- Set the camera view so that the world is draw relative to its position
    camera_follow_player(g_player, g_camera_player_offset)
    camera(g_camera_player_offset.x, g_camera_player_offset.y);

    -- draw the tiles
    for cell in all(g_map.cells) do
        local frame_idx = get_tile_sprite_frame(cell.tile)
        if frame_idx != nil then
            -- DRAW A THIN BORDER
            spr(128, cell.pos.x - ISO_TILE_WIDTH()/2, cell.pos.y, 4, 2, false)
            spr(frame_idx, cell.pos.x - ISO_TILE_WIDTH()/2, cell.pos.y - ISO_TILE_HEIGHT()/2, 4, 2, false)

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

    -- if the player is standing on their last visited isotile, highlight it
    if circ_colliders_overlap(g_player, g_player.last_visited_cell) then
        highlight_cell(g_player.last_visited_cell)
    end

    -- draw the player
    draw_anim(g_player, sprite_pos(g_player))

    -- if the player is collecting an item, draw the item above their collect animation
    if g_player.collect_item_state != nil then
        local item_pos = vec_sub(g_player.pos, vec_new(0, 16))
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
    draw_bomb_item(vec_new(4, 111))
    print(":"..g_player.bomb_count, 8, 110, Colors.White)

    -- draw the book UI
    draw_book_ui(g_player)

    -- draw the in-game timer UI
    g_game_timer_ui.draw(g_maingame_tick_count)
end

function draw_game_over()
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
        local game_over_text = g_game_over_state.game_over_text
        local rolled_text_ratio = (g_game_over_state.game_over_text_roll_spd * g_game_over_state.game_over_text_frame_cnt) / g_game_over_state.game_over_text_final_frame_cnt
        local end_char = flr((#game_over_text) * rolled_text_ratio)

        -- get the start char by reverse iterating
        local start_char = 1
        local newline_cnt = 0
        local newline_overflow = 17
        for i=1,end_char do
            local next_char_idx = end_char - (i - 1) -- iterate in reverse
            local next_char = sub(game_over_text, next_char_idx, next_char_idx)
            if next_char == "\n" then
                newline_cnt += 1
                if newline_cnt >= newline_overflow then
                    start_char = next_char_idx + 1
                    break
                end
            end
        end

        print(sub(game_over_text, start_char, end_char), 10, 10, Colors.White)

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
        draw_page_item(vec_new(120-x_ofs, 120), g_player.collected_pages[i])
    end

    if player.book_state == BookState.Holding then
        draw_book(vec_new(120, 120), false)
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
    return vec_new(text_x, text_y + 1)
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


function gen_maps(num_maps)
    local maps = {}

    for i=1,(num_maps - 1) do
        -- the levels increase in size from 2 -> MAX_TILE_LINE()
        local map_size = min((i + 1), MAX_TILE_LINE())
        add(maps, gen_empty_level(i, map_size))
    end

    -- Place the start and end tile on each map FIRST (we have to have these tiles. The rest aren't guaranteed to be
    -- present on every layer)
    for map in all(maps) do
        -- set the start cell on this map.
        local player_start_iso_idx = select_random_empty_tile_idx_from_map(map)
        map.cells[player_start_iso_idx].tile = make_tile(true, TileType.FloorEntry)

        -- set the finish cell on this map.
        map.finish_cell_idx = select_random_empty_tile_idx_from_map(map)
        map.cells[map.finish_cell_idx].tile = make_tile(false, TileType.FloorExit)
    end

    -- set the trap cells in each map
    -- On each map, %30 of the tiles rounded down have traps
    for map in all(maps) do
        local trap_cell_cnt = flr(map.iso_width * map.iso_width * 0.30)
        local trap_cells = select_random_empty_tiles({map}, trap_cell_cnt)
        for trap_cell in all(trap_cells) do
            map.cells[trap_cell.idx].tile = make_tile(false, TileType.Trap)
        end
    end

    -- set the bomb item cells
    -- There are a total of 10 bombs across the whole game
    local bomb_cell_cnt = 10
    local bomb_cells = select_random_empty_tiles(maps, bomb_cell_cnt)
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
        local iso_finish_cell_pos = map.cells[map.finish_cell_idx].pos
        for cell in all(map.cells) do
            if cell.tile.type == TileType.Empty then
                local dir_vec = vec_sub(iso_finish_cell_pos, cell.pos)
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
    local final_map_start_iso_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.cells[final_map_start_iso_idx].tile = make_tile(true, TileType.FloorEntry)
    -- turn every other cell into a stone floor cell
    for cell in all(final_map.cells) do
        if cell.tile.type == TileType.Empty then
            cell.tile = make_tile(true, TileType.StoneFloor)
        end
    end
    add(maps, final_map)

    return maps
end

function gen_empty_level(level_id, map_iso_width)
    -- create a new map
    local next_map = {}
    next_map.level_id = level_id
    next_map.iso_width = map_iso_width
    next_map.cells = {}

    -- wrap the map with a ring of invisible fall tiles. adds 2 rows to each side
    local visible_row_cnt = next_map.iso_width * 2 - 1
    local row_cnt = visible_row_cnt + 4

    -- initialize all the border cells as fall tiles and all the interior cells as empty
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
                pos = vec_new(
                    SCREEN_SIZE()/2 + col_offset,
                    SCREEN_SIZE()/2 + row_offset),
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
    local empty_cell_cnt = 0
    local empty_cells = {}
    for map in all(maps) do
        for cell in all(map.cells) do
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

function get_tile_sprite_frame(tile)
    if tile.visible then
        if tile.type == TileType.Empty then
            return 160
        elseif tile.type == TileType.FloorEntry then
            return 108
        elseif tile.type == TileType.FloorExit then
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
        elseif tile.type == TileType.Altar then
            return 140
        elseif tile.type == TileType.StoneFloor then
            return 136
        else
            return nil
        end
    else
        -- these two tile types should never be covered
        assert(tile.type != TileType.Altar)
        assert(tile.type != TileType.StoneFloor)
        return 96
    end
end

function move_to_level(next_level, start_tile_type)
    -- update the current map
    g_map = g_maps[next_level]

    -- place the player on the center of the iso tile
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
    local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
    local dx = 0
    local dy = 0
    if input.btn_left then
        if input.btn_up then
            dx = -2 * sqrt_half
            dy = -1 * sqrt_half
        elseif input.btn_down then
            dx = -2 * sqrt_half
            dy = sqrt_half
        else
            dx = -2
            dy = 0
        end
    elseif input.btn_right then
        if input.btn_up then
            dx = 2 * sqrt_half
            dy = -1 * sqrt_half
        elseif input.btn_down then
            dx = 2 * sqrt_half
            dy = sqrt_half
        else
            dx = 2
            dy = 0
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

    local player_spd = 1.0 -- an arbitrary speed factor to hand tune movement speed to feel good
    dx *= player_spd
    dy *= player_spd

    -- copy the old position in case we need to roll back
    local old_player_pos = vec_copy(g_player.pos)

    -- test all potential movements and use the first one that doesn't put us on a fall tile
    local move_candidates = {}
    add(move_candidates, vec_new(dx, dy))
    if dx != 0 then
        add(move_candidates, vec_new(dx, 0))
    end
    if dy != 0 then
        add(move_candidates, vec_new(0, dy))
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
        -- Do an additional smaller circle collider check so that we only activate at most one tile at a time
        -- even if we are standing in between two
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
    -- divide up an iso-tile into 3 rect colliders
    local iso_sub_colliders = {
        { width = 12, height = 12 },
        { width = 18, height =  9 },
        { width = 26, height =  5 },
    }

    -- setup a simple rect-collider for the actor wrapping their circle collider
    local actor_rect_collider = {
        pos = vec_new(
            actor.pos.x - actor.collider.radius,
            actor.pos.y - actor.collider.radius),
        width = (actor.collider.radius + actor.collider.radius),
        height = (actor.collider.radius + actor.collider.radius),
    }

    for sub_collider in all(iso_sub_colliders) do
        -- center the subcollider in the iso cell
        sub_collider.pos = vec_new(cell.pos.x - (sub_collider.width/2), cell.pos.y - (sub_collider.height/2))
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

function highlight_cell(cell)
    local cell_pos_x = cell.pos.x
    -- For some reason, I need to subtract '1' from each of the y values. I haven't yet rationalized why. Figure out later.
    local cell_pos_y = cell.pos.y - 1
    local corners = {
        vec_new(cell_pos_x - ISO_TILE_WIDTH()/2, cell_pos_y),
        vec_new(cell_pos_x, cell_pos_y - ISO_TILE_HEIGHT()/2),
        vec_new(cell_pos_x + ISO_TILE_WIDTH()/2, cell_pos_y),
        vec_new(cell_pos_x, cell_pos_y + ISO_TILE_HEIGHT()/2),
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

    function get_center_draw_pos(pos, width, height)
        return vec_new(pos.x - width/2, pos.y - height/2)
    end

    function gen_explosions(pos)
        local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
        local up_right = vec_new(2 * sqrt_half, -1 * sqrt_half)
        local up_left = vec_new(-2 * sqrt_half, -1 * sqrt_half)
        local down_right = vec_new(2 * sqrt_half, 1 * sqrt_half)
        local down_left = vec_new(-2 * sqrt_half, 1 * sqrt_half)

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

function split_text(text)
    local split_text = ""
    local chars_processed = 0
    while chars_processed < #text do
        local end_char = min(chars_processed + 1 + 25, #text)
        local next_chunk = nil

        if end_char == #text then
            next_chunk = sub(text, chars_processed + 1)
        else
            local new_line_idx = nil
            for i=(chars_processed+1),end_char do
                if sub(text, i, i) == "\n" then
                    new_line_idx = i
                end
            end

            if new_line_idx != nil then
                -- if there's a new line. process up to but not including that newline char
                -- include an extra space at the end of this chunk so that we skip past the
                -- newline when updating chars_processed
                next_chunk = sub(text, chars_processed + 1, new_line_idx - 1).." "
            else
                while sub(text, end_char, end_char) != " " do
                    end_char -= 1
                end
                next_chunk = sub(text, chars_processed + 1, end_char)
            end
        end

        if split_text == "" then
            split_text = next_chunk
        else
            split_text = split_text.."\n"..next_chunk
        end
        chars_processed += #next_chunk
    end
    return split_text
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
    g_game_phase = GamePhase.GameOver
    music(-1, 1000)
end
