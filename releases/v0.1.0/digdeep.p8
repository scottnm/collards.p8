pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
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
    return (5 * 60 * 30) -- five minutes worth of ticks
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
        pos = { x = 0, y = 0 },
        sprite_offset = { x = -8, y = -14 },
        collider = { radius = 3 },
        bomb_count = 0,
        collected_pages = {},
    }

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
    g_game_timer_ui = make_ui_timer(on_ui_timer_shake, MAINGAME_TIME_LIMIT())
    g_game_timer_ui.set_blinking(true)

    -- TODO: sometimes I refer to these as maps. Sometimes as levels. I should fix this. It's confusing
    g_maps = generate_maps(10)
    move_to_level(1, TileType.FloorEntry)
end

function _update()
    -- get input
    g_input = poll_input(g_input)

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

    -- if we aren't blocking new input process it
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
            if (g_player.die_state) == nil and (circ_colliders_overlap(g_player, e)) then
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
        g_game_over_state = {
            substate = "scroll_timer",
            timer_scroll = 0,
        }
        g_game_phase = GamePhase.GameOver
        g_game_timer_ui.set_blinking(true)
        music(-1, 1000)
    end
end

function collect_item(player, item_type, item_args)
    player.collect_item_state = {
        anim = g_anims.CollectItem,
        item = item_type,
        anim_timer = make_ingame_timer(45),
    }

    item_args = item_args or {}
    for k,v in pairs(item_args) do
        player.collect_item_state[k] = v
    end

    local item_text = nil
    if item_type == ItemType.Bomb then
        item_text = "bomb. ❎ to use"
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
        local player_cell = g_map.cells[player_iso_tile_idx]

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
    local try_place_bomb = g_input.btn_x and g_input.btn_x_change
    if try_place_bomb then
        if g_player.bomb_count > 0 then
            g_player.bomb_count -= 1
            add(g_bombs, new_bomb(g_player.pos, on_explosion_start))
        end
    end

end

function on_explosion_start()
    sfx(Sfxs.BombExplosion)
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
        -- after weve picked up the bomb, flip the cell to be just a plain ole empty cell without a hint
        tile.type = TileType.Empty
    elseif tile.type == TileType.PageItem then
        add(g_player.collected_pages, tile.page_frag)
        collect_item(g_player, ItemType.Page, { page_frag = tile.page_frag })
        -- after weve picked up the bomb, flip the cell to be just a plain ole empty cell without a hint
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
    local dir_vec = sub_vec2(camera_ofs, player_camera_center_ofs)

    -- take the distance and divide it out to get the unit vector
    local dist = sqrt(dist_squared)
    dir_vec.x /= dist
    dir_vec.y /= dist

    -- multiply the max distance to get our max distance from player
    dir_vec.x *= MAX_CAMERA_DISTANCE_FROM_PLAYER()
    dir_vec.y *= MAX_CAMERA_DISTANCE_FROM_PLAYER()

    new_ofs = add_vec2(player.pos, dir_vec)
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

    --
    -- draw the tiles
    --

    -- draw iso map
    for cell in all(g_map.cells) do
        local frame_idx = get_iso_tile_sprite_frame(cell.tile)
        if frame_idx != nil then
            -- DRAW A THIN BORDER
            spr(128, cell.pos.x - ISO_TILE_WIDTH()/2, cell.pos.y, 4, 2, false)
            spr(frame_idx, cell.pos.x - ISO_TILE_WIDTH()/2, cell.pos.y - ISO_TILE_HEIGHT()/2, 4, 2, false)

            if cell.tile.visible then
                -- draw the hint arrow if the empty hint cell is visible
                if (cell.tile.type == TileType.Empty) and (cell.tile.hint != nil) then
                    draw_hint_arrow(cell.pos, cell.tile.hint)
                -- If it's an unretrieved bomb cell, display an inactive bomb sprite in the middle of the cell.
                -- N.B. this basically only happens if you use a bomb to reveal another bomb.
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
        elseif g_player.collect_item_state.item == ItemType.Book then
            draw_book(item_pos, false)
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

    -- draw any banners if set
    if g_banner != nil then
        draw_banner(g_banner.text, g_banner.fg_color, g_banner.bg_color)
        g_banner.timer.update()
        if g_banner.timer.done() then
            g_banner = nil
        end
    end

    -- draw the bomb counter UI
    draw_bomb_item({ x = 4, y = 111 })
    print(":"..g_player.bomb_count, 8, 110, Colors.White)

    -- draw the page UI
    draw_page_ui(g_player)

    -- draw the in-game timer UI
    g_game_timer_ui.draw(g_maingame_tick_count)

    -- uncomment to display frame stats
    -- dbg_display_frame_stats({ x = 80, y = 80 })
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

        -- draw the page UI
        draw_page_ui(g_player)

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

        --

        game_over_text = sub(game_over_text, start_char, end_char)
        print(game_over_text, 10, 10, Colors.White)

        -- draw the page UI
        draw_page_ui(g_player)
    end
end

function draw_page_ui(player)
    -- Page UI is drawn in screnspace. Temporarily reset the camera.
    camera_x = peek2(0x5f28)
    camera_y = peek2(0x5f2a)
    camera(0, 0)

    local tile_px_width = 8
    local tile_px_height = 8
    for i=1,#g_player.collected_pages do
        local x = 128 - (i*tile_px_width)
        local y = 120
        draw_page_item({x=x, y=y}, g_player.collected_pages[i])
    end

    -- restore the camera
    camera(camera_x, camera_y)
end

function center_text(rect, text)
    local text_len = #text
    local text_pixel_width = 4 * text_len
    local text_pixel_height = 6
    local text_start_x = rect.x + (rect.width/2) - (text_pixel_width/2)
    local text_start_y = rect.y + (rect.height/2) - (text_pixel_height/2)
    -- N.B. y + 1 to account for the extra pixel buffer below the font
    return { x = text_start_x, y = text_start_y + 1 }
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

function draw_book(pos_center, on_altar)
    if on_altar then
        -- draw the book on the altar
        spr_centered(72, pos_center.x, pos_center.y - 4, 1, 1)
    else
        -- draw just the book on the floor
        spr_centered(72, pos_center.x, pos_center.y, 1, 1)
    end
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
    -- Banners are drawn in screen space.
    -- Grab the camera position from its memory mapped position so we can clear and later reset it
    camera_x = peek2(0x5f28)
    camera_y = peek2(0x5f2a)
    camera(0, 0)

    local bg_rect = { x = 0, y = 98, width = 128, height = 10 }
    rectfill(bg_rect.x, bg_rect.y, bg_rect.x + bg_rect.width, bg_rect.y + bg_rect.height, bg_color)
    rect(bg_rect.x + 1, bg_rect.y + 1, bg_rect.x + bg_rect.width - 2, bg_rect.y + bg_rect.height - 1, fg_color)
    local text_pos = center_text(bg_rect, text)
    print(text, text_pos.x, text_pos.y, fg_color)

    -- restore the camera
    camera(camera_x, camera_y)
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

    for i=1,(num_maps - 1) do
        -- the first level has map size 2
        -- the largest map is size MAX_TILE_LINE()
        local map_size_for_level = min((i + 1), MAX_TILE_LINE())
        add(maps, generate_empty_level(i, map_size_for_level))
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

    -- generate the trap cells in each map
    -- On each map, %30 of the tiles rounded down have traps
    for map in all(maps) do
        local trap_cell_cnt = flr(map.iso_width * map.iso_width * 0.30)
        local trap_cells = select_random_empty_tiles({map}, trap_cell_cnt)
        for trap_cell in all(trap_cells) do
            map.cells[trap_cell.idx].tile = make_tile(false, TileType.Trap)
        end
    end

    -- generate the bomb item cells
    -- There are a total of 10 bombs across the whole game
    local bomb_cell_cnt = 10
    local bomb_cells = select_random_empty_tiles(maps, bomb_cell_cnt)
    for bomb_cell in all(bomb_cells) do
        bomb_cell.map.cells[bomb_cell.idx].tile = make_tile(false, TileType.BombItem)
    end

    -- generate the page item cells
    local page_fragments = { 172, 173, 188, 189 }
    local next_page_frag_idx = 0

    local page_cell_cnt = TOTAL_PAGE_COUNT()
    local page_cells = select_random_empty_tiles(maps, page_cell_cnt)
    for page_cell in all(page_cells) do
        page_cell.map.cells[page_cell.idx].tile = make_tile(false, TileType.PageItem)
        page_cell.map.cells[page_cell.idx].tile.page_frag = page_fragments[next_page_frag_idx + 1]
        next_page_frag_idx = ((next_page_frag_idx + 1) % #page_fragments)
    end

    -- Now that all interesting cells have been placed, fill in the remaining empty
    -- cells with hint arrows
    for map in all(maps) do
        local iso_finish_cell_pos = map.cells[map.finish_cell_idx].pos
        for cell in all(map.cells) do
            if cell.tile.type == TileType.Empty then
                local dir_vec = sub_vec2(iso_finish_cell_pos, cell.pos)
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

    -- Last but not least, we'll generate the last level. This
    -- level is generated specially since it doesn't follow the rules of the previous maps.
    -- It's just the single goal item in the middle of an empty layer
    local final_map = generate_empty_level(num_maps, MAX_TILE_LINE())
    -- set the final level's entry
    local final_map_start_iso_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.cells[final_map_start_iso_idx].tile = make_tile(true, TileType.FloorEntry)
    -- set the altar point
    local altar_cell_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.cells[altar_cell_idx].tile = make_tile(true, TileType.Altar)
    final_map.cells[altar_cell_idx].tile.has_book = true
    -- turn every other cell into a stone floor cell
    for cell in all(final_map.cells) do
        if cell.tile.type == TileType.Empty then
            cell.tile = make_tile(true, TileType.StoneFloor)
        end
    end
    add(maps, final_map)

    -- uncomment this to make all tiles visible at start
    -- for map in all(maps) do
    --     for cell in all(map.cells) do
    --         cell.tile.visible = true
    --     end
    -- end

    -- uncomment this to make all exit tiles and page tiles visible at start
    -- for map in all(maps) do
    --     for cell in all(map.cells) do
    --         if cell.tile.type == TileType.PageItem then
    --             cell.tile.visible = true
    --         elseif cell.tile.type == TileType.FloorExit then
    --             cell.tile.visible = true
    --         end
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
    next_map.cells = {}
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

function get_iso_tile_sprite_frame(tile)
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
    g_player.pos = copy_vec2(player_start_cell.pos)
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

    local player_speed = 1.0 -- an arbitrary, tweakable speed factor to hand tune movement speed to feel good
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
    for cell in all(get_cells_under_actor(map, actor)) do
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

function highlight_cell(cell)
    local cell_pos_x = cell.pos.x
    local cell_pos_y = cell.pos.y
    -- N.B. for some reason, I need to subtract '1' from each of the y values. I haven't yet rationalized why
    -- the off-by-one pixel shift is needed. I'll figure it out later.
    local line_points = {
        { x = cell_pos_x - ISO_TILE_WIDTH()/2, y = cell_pos_y - 1 },
        { x = cell_pos_x,                      y = cell_pos_y - 1 - ISO_TILE_HEIGHT()/2 },
        { x = cell_pos_x + ISO_TILE_WIDTH()/2, y = cell_pos_y - 1},
        { x = cell_pos_x,                      y = cell_pos_y - 1+ ISO_TILE_HEIGHT()/2 },
    }

    line(line_points[1].x, line_points[1].y, line_points[2].x, line_points[2].y, Colors.White)
    line(line_points[2].x, line_points[2].y, line_points[3].x, line_points[3].y, Colors.White)
    line(line_points[3].x, line_points[3].y, line_points[4].x, line_points[4].y, Colors.White)
    line(line_points[4].x, line_points[4].y, line_points[1].x, line_points[1].y, Colors.White)
end

function new_bomb(pos, on_explosion_start)
    local self = {
        state = "Countdown",
        countdown_anim = g_anims.BombCountdown,
        explosion_timer = make_ingame_timer(32),
        explosions = {},
        active_explosions = {},
        pos = copy_vec2(pos),
        on_explosion_start = on_explosion_start
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

function generate_lose_text()
    return "you were unable to make\nyour way to the bottom\nof the grave in time.\n\nyour family's most\ncherished heirloom is\nlost. gone forever.\n\nthis is unacceptable.\nyou'll have to try again.\n\nx/c - to reset"
end

function generate_win_text(collected_page_count, total_page_count)
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

function handle_game_over(game_won)
    g_game_over_state = {
        substate = "scroll_timer",
        timer_scroll = 0,
    }
    if game_won then
        g_game_over_state.game_over_text = generate_win_text(#g_player.collected_pages, TOTAL_PAGE_COUNT())
    else
        g_game_over_state.game_over_text = generate_lose_text()
    end
    g_game_timer_ui.set_blinking(true)
    g_game_phase = GamePhase.GameOver
    music(-1, 1000)
end

-->8
-- sfx.lua - sfx & music helpers

-- enums
Sfxs = {
    Dig = 1,
    Death = 2,
    ClockBeep = 3,
    BombExplosion = 21,
    DownStairs = 5,
    UpStairs = 6,
    GetItem = 7,
}

-->8
-- anim.lua - animation logic

--
-- N.B. lots of this code is adapted from scathe's anim
-- function on the pico8 bbs
-- https://www.lexaloffle.com/bbs/?tid=3115&autoplay=1#pp
-- Thanks scathe!
--

function create_anim_flow(frames, speed, tile_size, flip)
    return {
        frames = frames,
        num_tiles = count(frames),
        speed = speed,
        tile_size = tile_size,
        flip = flip,
    }
end

function new_anim_state()
    return { a_ct = 0, a_st = 0, a_fr = 0, loop = 0 }
end

function reset_anim(obj)
    obj.anim_state.a_ct = 0
    obj.anim_state.a_st = 0
    obj.anim_state.loop = 0
end

function update_anim(obj, anim_flow)
    obj.anim_state = obj.anim_state or new_anim_state()
    local anim_state = obj.anim_state

    anim_state.a_ct += 1

    local move_to_next_frame = anim_state.a_ct % (30 / anim_flow.speed) == 0
    if move_to_next_frame then
        anim_state.a_st += 1
        if anim_state.a_st >= anim_flow.num_tiles then
            anim_state.a_st = 0
            anim_state.loop += 1
        end
    elseif anim_state.a_st >= anim_flow.num_tiles then
        anim_state.a_st = 0
    end

    local frame = anim_flow.frames[anim_state.a_st + 1]

    anim_state.a_fr = frame
    anim_state.flip = anim_flow.flip
    anim_state.tile_size = anim_flow.tile_size
    anim_state.last_flow = anim_flow
end

function draw_anim(obj, sprite_pos)
    spr(obj.anim_state.a_fr, sprite_pos.x, sprite_pos.y, obj.anim_state.tile_size, obj.anim_state.tile_size, obj.anim_state.flip)
end

-->8
-- timer.lua - timers

function make_ingame_timer(num_frames)
    local self = {
        frames = 0,
        num_frames = num_frames,
    }

    local update = function()
        if self.frames < self.num_frames then
            self.frames += 1
        end
    end

    local done = function()
        return self.frames >= self.num_frames
    end

    local get_elapsed_ratio = function()
        return self.frames / self.num_frames
    end

    return {
        get_elapsed_ratio = get_elapsed_ratio,
        update = update,
        done = done
    }
end

function make_ui_timer(on_shake, total_ticks)
    local self = {
        blinking = true,
        blink_ticks = 0,
        blink_period = 25,
        real_time_ticks = nil,
        shaking = false,
        on_shake = on_shake,
        total_ticks = total_ticks,
        pos_x = 42,
        pos_y = 10,
    }

    local get_timer_completion_ratio = function (current_tick_count)
        return current_tick_count / self.total_ticks
    end

    local should_shake_time = function (current_tick_count)
        if current_tick_count == 0 or current_tick_count == self.total_ticks then
            return false
        end

        local shake_start = flr(self.total_ticks / 24)
        local shake_duration_in_ticks = 10
        return (current_tick_count % shake_start) < shake_duration_in_ticks
    end

    local set_blinking = function(blinking)
        self.blinking = blinking
    end

    local hide_timer_for_blink = function ()
        if not self.blinking then
            return false
        end

        return self.blink_ticks >= self.blink_period
    end

    local generate_timestamp = function (time_in_minutes)
        local hrs_part = flr(time_in_minutes / 60)
        local fixed_point_minutes_part = time_in_minutes % 60
        local minutes_part = flr(fixed_point_minutes_part)
        local fixed_point_seconds_part = (fixed_point_minutes_part & 0x0000.ffff) * 60
        local seconds_part = flr(fixed_point_seconds_part)
        return { Hours = hrs_part, Minutes = minutes_part, Seconds = seconds_part }
    end

    local start_timer = function()
        self.started = true
    end

    local update_timer = function (current_tick_count)
        if self.blinking then
            self.blink_ticks += 1
            if self.blink_ticks > (self.blink_period * 1.5) then
                self.blink_ticks = 0
            end
        end

        local should_shake = should_shake_time(current_tick_count)
        if should_shake and (not self.shaking) then
            self.on_shake()
        end
        self.shaking = should_shake
    end

    local draw_timer = function(current_tick_count)
        -- render the timer
        if hide_timer_for_blink() then
            return
        end

        local text_color = Colors.White
        local text_pos_x = self.pos_x
        local text_pos_y = self.pos_y
        if self.shaking then
            text_color = Colors.Yellow
            -- add shake to timer
            text_pos_x += rnd_incrange(-1, 1)
            text_pos_y += rnd_incrange(-1, 1)
        end

        local time_elapsed_ratio = get_timer_completion_ratio(current_tick_count)
        local ingame_total_minutes = (24 * 60)
        local time_remaining_minutes = (1 - time_elapsed_ratio) * ingame_total_minutes
        local time_remaining_parts = generate_timestamp(time_remaining_minutes)

        local timer_text = format_int_base10(time_remaining_parts.Hours, 2) .. "H:" .. format_int_base10(time_remaining_parts.Minutes, 2) .. "M:" .. format_int_base10(time_remaining_parts.Seconds, 2) .. "S"

        -- render the timer text with a gray drop shadow
        print(timer_text, text_pos_x + 1, text_pos_y + 1, Colors.DarkGray)
        print(timer_text, text_pos_x, text_pos_y, text_color)
    end

    local move_timer = function(x, y)
        self.pos_x += x
        self.pos_y += y
    end

    return {
        set_blinking = set_blinking,
        update = update_timer,
        draw = draw_timer,
        move = move_timer,
    }
end

-->8
-- utils.lua - common utils

-- Enum for more readable colors
Colors = {
    Black = 0,
    Navy = 1,
    Maroon = 2,
    DarkGreen = 3,
    Brown = 4,
    DarkGray = 5,
    LightGray = 6,
    White = 7,
    Red = 8,
    Orange = 9,
    Yellow = 10,
    LightGreen = 11,
    SkyBlue = 12,
    BlueGray = 13,
    Pink = 14,
    Tan = 15,
}

-- pico8 constants
function SCREEN_SIZE()
    return 128
end

-- generate a random int from within a range inclusive
function rnd_incrange(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

-- generate a random int from within a range inclusive
function rnd_incrange(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

-- clamp a value within a range inclusively
function clamp(lower, value, upper)
    return mid(lower, value, upper)
end

-- poll for next frame's input, compared to previous frame
function poll_input(input)
    if input == nil then
        input = {
            btn_left = false,
            btn_left_change = false,
            btn_right = false,
            btn_right_change = false,
            btn_up = false,
            btn_up_change = false,
            btn_down = false,
            btn_down_change = false,
            btn_o = false,
            btn_o_change = false,
            btn_x = false,
            btn_x_change = false,
        }
    end

    local new_input = {
        btn_left = btn(0),
        btn_right = btn(1),
        btn_up = btn(2),
        btn_down = btn(3),
        btn_o = btn(4),
        btn_x = btn(5),
    }

    input.btn_left_change = (input.btn_left ~= new_input.btn_left)
    input.btn_left = new_input.btn_left
    input.btn_right_change = (input.btn_right ~= new_input.btn_right)
    input.btn_right = new_input.btn_right
    input.btn_up_change = (input.btn_up ~= new_input.btn_up)
    input.btn_up = new_input.btn_up
    input.btn_down_change = (input.btn_down ~= new_input.btn_down)
    input.btn_down = new_input.btn_down
    input.btn_o_change = (input.btn_o ~= new_input.btn_o)
    input.btn_o = new_input.btn_o
    input.btn_x_change = (input.btn_x ~= new_input.btn_x)
    input.btn_x = new_input.btn_x

    return input
end

-- format a base10 int as a string with left-padded zeros
function format_int_base10 (n, max_leading_zeroes)
    local str = ""
    while (max_leading_zeroes != 0) and (n != 0) do
        local next_digit = n%10
        str = next_digit..str
        n = flr(n/10)
        max_leading_zeroes -= 1
    end
    while (max_leading_zeroes != 0) do
        str = "0"..str
        max_leading_zeroes -= 1
    end

    return str
end

function sqr(x)
    return x * x
end

function sqr_dist(a, b)
    return sqr(a.x - b.x) + sqr(a.y - b.y)
end

__gfx__
00000000000000000000055555500000000000000000000000000000000000000000055555500000000000000000000000000000000000000000000000000000
00000555555000000000555555550000000005555550000000000555555000000000555555550000000005555550000000550555555000000220055555500000
00005555555500000005555555555000000055555555000000005555555500000005111115555000000055555555000005515555555500000000d1d555550000
00055555555550000005555999955000000555555555500000051115555550000005155511555000000555111155500055515555555550000051d1d555555000
00055559999550000005559999595000000555599995500000015551155550000001555551555000000551555515500055515555555550000551ddd559955000
00055599995950000005599599595000000555999959500000055555155550000001555551555000000551555515500055501555599950005551585599995000
00055995995950000005599599990000000559959959500000055555115550000001555551590000000551555515500005505555999900005555185995990000
00055995999900000000599999960000000559959999000000055555515900000000555555660000000555555559000000005559959900005550585995990000
00005999999660000000669999666000000059999996600000055555566660000006666666666000000065555556600000009999959900000550599699900000
00996699996699000009966666669000000666999966690000966666666699000099666666699000000966666666690000000999999000000000099966600000
09996666666999000009966666669000000999666666999009996666666699000099666666699000000966666666999000006666666600000000669966660000
09906666666990000009966666669000000999666666099009906666666690000099666666699000000966666666099000006699666600000000666666660000
00006666cccc00000000cccccccc00000000cccc6666000000006666cccc00000000cccccccc00000000cccc6666000000000c999cc0ddd000000cccccc00000
0000cccccc5500000000c5500c5500000000c55ccccc00000000ccccccc500000000cc500cc500000000cccccccc000000000cc99888d11000000cccc1100000
0000c550066600000000666006660000000066600c5500000000cc50066600000000666006660000000066600cc50000000005555dd0d220000005555dd00000
00006660000000000000000000000000000000000666000000006660000000000000000000000000000000000666000000000666600022220000066660002220
00000000000000000000055555550000000000000000000000000000000000000000055555500000000000000000000000000555555000000000055555550000
00000555555500000000555555555000000005555555000000000555555000000000555555550000000005555550000000005555555550000000555555555000
00005555555550000005555555555500000055555555500000005555555500000005555115555000000055555555000000005555999550000005555555555500
00055555555555000005555999955500000555555555550000055551115550000005551551555000000555111555500000515559999550000005555999955500
00055559999555000005559999995500000555599995550000055515551550000005515555155000000551555155500005551595599950000005559999995500
00055599999955000005595999595500000555999999550000055155555150000005515555155000000515555515500055551599999900000005595999595500
00055959995955000000595999595000000559599959550000055155555150000000995555990000000515555515500055515999999900000099595999595990
0000595999595000000009999999000000005959995950000000995555590000000066555566000000009555559900005550599999960dd00099099999990990
00000999999900000000669999966000000009999999600000066655555660000006666666666000000665555566600009900699966dddd00099669999966990
00996699999660000006666666669000000966999996690000966666666699000009666666669000009966666666690009996666666dd0000006666666666900
09996666666699000009666666669000000999666666999009996666666699000009666666669000009966666666999000999666666000000000666666660000
099066666669990000096666666690000009996666660990099066666666900000096666666690000009666666660990000006666660005d0000666666660000
00006666ccc990000000cccccccc00000000cccc6666000000006666cccc00000000cccccccc00000000cccc6666000000000cccccc1156d0000cccccccc0000
0000ccccc555000000005550055500000000555ccccc00000000cccccccc00000000ccc00ccc00000000cccccccc000000000ccccccc156d0000555005550000
0000555006660000000066600666000000006660055500000000ccc0066600000000666006660000000066600ccc00000000001111ccc56d0000666006660000
00006660000000000000000000000000000000000666000000006660000000000000000000000000000000000666000000000000000cc5600000000000000000
00005555555000000000000000000000000055555550000000000000000000000d99999000000000000000000000000000000000000000444400000000000000
00515555555550000000055555500000005155555555500000000000000000000d9ddd9000888800000900000009000000000000000044444444000000000000
05515555555550000051555555550000055155555555500000000000000000000d99999000099000000090000000900000000000004444999944440000000000
55515555555550000551555555555000555155555555500000000000005555500d93339000888800001111000088880000000000444499999999444400000000
55551555999950005551555555555000555515559999500000000000055555550d93b39008881880011611100886888000000044499999948999944444000000
55505559999900005555155559995000555055599999000000000000055555550d93b39008188180016111100868888000004444999888888888899444440000
05505559959900005550555599990000055055599599000000000000000511100d99b990088188800111111008888880004444888888a8888888888888444400
00009999959900000550555995990000000099999599000000000000955155500d999990088888800011110000888800444488858888888888a8888888844444
00dd69999990000000009999959900000000099999900dd0001cc669955555550000000000000000000000000008800044444888888888888a8a888888844444
00dd666666600990000009999990000000996666666dddd0d1ccc66995555555000000000000000000000000008998000044444488888aa88888888884444400
0000666669999990000066666666000000999666666dd000dcccc66999555555000000000000000000099000089aa98000004444444888888888884444440000
0000c6666699900000006699666600000099066666600000d6ccc969599555550000666666660000009aa90089aaaa98000000444444888a8888444444000000
065ccccccc15d00000000c99ccc0000000990cccccc00560d65c9969559955550005dddddddd6000009aa90089aaaa9800000000444444888844444400000000
065ccccc1115d00000000c99c11000000000dccccccc05600650996999995555005dddddddddd60000099000089aa98000000000004444448444440000000000
065ccc0000000000000005555dd000000000d51111ccc56006509900999955500005dddddddd5000000000000889980000000000000044444444000000000000
065000000000000000000666600000000000d500000cc56000000000055555000000555555550000000000000008800000000000000000444400000000000000
00000000000000444400000000000000000000000000004444000000000000000000000000000044440000000000000000000000000000444400000000000000
00000000000044444444000000000000000000000000444444440000000000000000000000004444444400000000000000000000000044222222222220000000
000000000044444444444400000000000000000000444422244444000000000000000000004444444244440000000000000000000044222ddd22666222220000
00000000444444424444444400000000000000004444222222244444000000000000000044444422222244440000000000000000442226622dd22222ddd20000
00000044444444442444444444000000000000444422222222222444440000000000004444422222222222444400000000000044442d226622dddd2dddd20000
00004444444444444444444444440000000044444222222222222224444400000000444442222222222222244444000000004422222ddd2266222d2dddd20000
0044444424444444444444444444440000444444222222dddddd222244444400004444222222222222222222244444000044442d266222dd2266222ddd224400
4444444244444444444444444444444444444442dddddddddd2dddd22444444444444222666222d6622ddd22224444444444442dd2266222dd222dddd2224444
444444444444444444444424444444444444444dddddddddd2d2ddddd444444444444442dd6662ddd662ddd22444444444444422ddd2266222dd2dddd2244444
0044444444444444244444444444440000444444ddddd22dddddddd44444440000444444222d6662ddd622dd444444000044444422ddd2266622ddd224444400
0000444444444442424444444444000000004444444ddddddddd444444440000000044444422dd6622dd622444440000000044444222ddd2222dd22444440000
00000044444444444444444444000000000000444444ddd2dd44444444000000000000444444222d66224444440000000000004444422dd2ddd2244444000000
0000000044444444444444440000000000000000444444ddd44444440000000000000000444444222dd44444000000000000000044444222d224444400000000
00000000004444444444440000000000000000000044444444444400000000000000000000444444244444000000000000000000004444422444440000000000
00000000000044444444000000000000000000000000444444440000000000000000000000004444444400000000000000000000000044444444000000000000
00000000000000444400000000000000000000000000004444000000000000000000000000000044440000000000000000000000000000444400000000000000
220000000000000000000000000000dd0000000000000000000000000000000000000000000000dddd0000000000000000000000000000444400000000000000
2222000000000000000000000000dddd00022000000000000000200000000000000000000000dd6666dd00000000000000000000000044443444000000000000
22222200000000000000000000dddddd002222000002222000002200000000000000000000dd66dddd66dd000000000000000000004444444444440000000000
222222220000000000000000dddddddd0222222000002220022222200000000000000000dd66dd66dddd66dd00000000000000004444344444b4444400000000
2222222222000000000000dddddddddd00022000000220200222222000000000000000dd66dddddddddddd66dd00000000000044444b4444b44444b444000000
22222222222200000000dddddddddddd000220000022000000002200000000000000dd66dddddddddddd5ddd66dd000000004444844444444444434344440000
222222222222220000dddddddddddddd0002200002200000000020000000000000dd66dddd5ddddddddddddddd66dd0000444e48a8444444444444444e444400
0022222222222222dddddddddddddd0000000000000000000000000000000000dd66d6dd55dddddd5ddddddd6ddd66dd4444eae48444434444444444eae44444
0000222222222222dddddddddddd0000000000000000000000000000000000005555dddddddddddddddddddddddd555544444eb4b34444444444b444be444444
0000002222222222dddddddddd00000000000000000000000000000000000000005555dddddddddddddddddddd555500004443b4b444b4448444443b34444400
0000000022222222dddddddd000000000000000000000000000000000000000000005555dddd6ddddddd5ddd555500000000444b4443b448a844444b44440000
0000000000222222dddddd0000000000000000000000000000000000000000000000005555dddddddd5ddd555500000000000044444444438444434444000000
0000000000002222dddd00000000000000000000000000000000000000000000000000005555dddddddd5555000000000000000044443444b344444400000000
0000000000000022dd000000000000000000000000000000000000000000000000000000005555dddd555500000000000000000000444444b444440000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000044444444000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000444400000000000000
00000000000000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000008800
00000000000044444444000000000000000000000000000000000000000000000000000000000000000000000000000000999990000999000008800000088000
00000000004444555444440000000000000000000000000000000000000000000000000000000000000000000000000000955590000959000088880000888800
00000000444455555554444400000000000000000000000000000000000000000000000000000000000000000000000000999990000999000089980000899800
000000444455555ffffff444440000000000000000000000000000000000000000000000000000000000000000000000009dd900009dd900089aa980089aa980
0000444455fffffffffffff44444000000000000000000000000000000000000000000000000000000000000000000000099990000999900089aa980089aa980
004444455fffffffffffffff44444400000000000000000000000000000000000000000000000000000000000000000000999000099990000089980000899800
444444ffffffffffffffffffff444444000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000088000
444444fffffffffffffffffff4444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000808000080008
0044444fffffffffffffffff44444400000000000000000000000000000000000000000000000000000000000000000000000000000009000008800000088000
000044444ffffffffffffff444440000000000000000000000000000000000000000000000000000000000000000000000999900099999000088880000888800
0000004444ffffffffff4444440000000000000000000000000000000000000000000000000000000000000000000000009dd900099dd9000089980000899800
000000004444ffffff4444440000000000000000000000000000000000000000000000000000000000000000000000000099999000999900089aa980089aa980
000000000044444ff4444400000000000000000000000000000000000000000000000000000000000000000000000000009ddd90009dd900089aa980089aa980
00000000000044444444000000000000000000000000000000000000000000000000000000000000000000000000000000999990009999000089980000899800
00000000000000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000088000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001065009650056500a550025500d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a650286502565021650334501d650186502b75026750284500f6501f7501c7501a75018750056501775016750176501665013650145500f6500c650120500d750070500b75001650001500975008750
30030000115502a0503805000000000000000000000000000f5503805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000266005670026600066002660006600067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9c0c0000186750c6350c6000c67516600136000c67510600106000c6000c6050c6050c6050c60513600116000e6001760013600106001660013600116000c6050c6050c6050c6000060000600006000000000000
9c0c00000c675186350c600186751660018600186750c6000c6050c6050c6050c605186050c6050e6001760013600106001660013600116000c6050c6050c6050c60000600006000060000000000000000000000
100500001c05317055190501e05023050200502a050000002a040000002a030000002a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155081550c155051550c155081550c155051550c155081550c155051550c137081550c155
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1370c1550f155
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1370a1550e155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
00040000176301d6302163025630286302b6302e630306302d6302663022630136300463000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 09454308
00 0a424308
00 090c4344
00 0a0d4344
00 090c1108
00 0a0d1208
00 0b0e4344
00 100f4344
00 0b0e1308
02 100f1408

