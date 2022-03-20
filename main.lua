-- main.lua - main game logic

-- TODO: refactor the banner system for simplicity
-- each component just calls some queue_banner and it overwrites the current banner with a manually tracked time limit

GameStateType = {
    PreGame = 1,
    MainGame = 2,
    LoseGame = 3,
    WinGame = 4,
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

PlayerBookState = {
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

-- global variables
g_maps = nil
g_map = nil
g_player = nil
g_input = nil
g_player_move_to_floor_state = nil
g_game_state = nil
g_game_timer_ui = nil
g_anims = nil
g_camera_player_offset = nil
g_bombs = nil
g_lose_game_state = nil
g_win_game_state = nil
g_warning_banner = nil

g_maingame_tick_count = 0
g_maingame_time_limit = (5 * 60 * 30) -- five minutes worth of ticks

function _init()
    reset()
end

function reset()
    g_warning_banner = nil
    g_maingame_tick_count = 0
    g_game_state = GameStateType.PreGame
    g_lose_game_state = nil
    g_player = {}
    g_player.book_state = PlayerBookState.NotFound
    g_player.pos = { x = 0, y = 0 }
    g_player.sprite_offset = { x = -8, y = -14 }
    g_player.collider = { radius = 3 }
    g_player.bomb_count = 0
    g_player.collected_pages = {}

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
    g_game_timer_ui = make_ui_timer(on_ui_timer_flash, g_maingame_time_limit)
    g_game_timer_ui.set_blinking(true)

    -- TODO: sometimes I refer to these as maps. Sometimes as levels. I should fix this. It's confusing
    g_maps = generate_maps(10)
    move_to_level(1, TileType.FloorEntry)
end

function _update()
    -- get input
    g_input = poll_input(g_input)

    if g_game_state == GameStateType.MainGame then
        main_game_update(g_input)
    elseif g_game_state == GameStateType.PreGame then
        pre_game_update(g_input)
    elseif g_game_state == GameStateType.LoseGame then
        lose_game_update(g_input)
    elseif g_game_state == GameStateType.WinGame then
        win_game_update(g_input)
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
        g_game_state = GameStateType.MainGame
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
            local explosion_cells = get_iso_cells_under_actor(g_map, e)
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

    if g_maingame_tick_count >= g_maingame_time_limit then
        g_lose_game_state = {
            substate = "scroll_timer",
            timer_scroll = 0,
        }
        g_game_state = GameStateType.LoseGame
        g_game_timer_ui.set_blinking(true)
        music(-1, 1000)
    end
end

function collect_item(player, item_type, item_args)
    player.collect_item_state = {
        anim = g_anims.CollectItem,
        item = item_type,
        anim_timer = make_ingame_timer(60),
    }

    item_args = item_args or {}
    for k,v in pairs(item_args) do
        player.collect_item_state[k] = v
    end

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
        local player_iso_cell = g_map.isocells[player_iso_tile_idx]

        -- If we've just dug up a tile, we'll set a callback so that after
        -- the digging animation reveals the tile, we'll automatically
        -- interact with it.
        if is_digging then
            local reveal_tile_callback = function()
                sfx(Sfxs.Dig)
                player_iso_cell.tile.visible = true
                interact_with_tile(player_iso_cell.tile)
            end
            g_player.dig_state.on_dig_up = reveal_tile_callback
        elseif player_iso_cell.tile.visible then
            interact_with_tile(player_iso_cell.tile)
            g_player.last_interacted_isocell = player_iso_cell
        elseif player_iso_cell.tile.has_book then
            -- HACK: special case to support picking up books from unrevealed tiles
            g_player.book_state = PlayerBookState.Holding
            player_iso_cell.tile.has_book = false
            g_player.collect_item_state = {
                anim = g_anims.CollectItem,
                item = ItemType.Book,
                anim_timer = make_ingame_timer(60),
            }
            g_player.last_interacted_isocell = player_iso_cell
        end

        g_player.last_visited_isocell = player_iso_cell
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
    local had_book = false
    if player.book_state == PlayerBookState.Holding then
        -- drop the book in a random safe cell
        local safe_tile_idx = select_random_empty_tile_idx_from_map(map)
        map.isocells[safe_tile_idx].tile.has_book = true
        g_player.book_state = PlayerBookState.FoundButLost
        had_book = true
    end
    player.die_state = {
        anim = get_die_anim_for_player(player),
        respawn_timer = make_ingame_timer(60),
        had_book = had_book,
    }
    sfx(Sfxs.Death)
end

function interact_with_tile(tile)
    -- only interact with a tile the first time you step on it.
    if tile == g_player.last_interacted_isocell.tile then
        return
    end

    if tile.type == TileType.FloorExit then
        start_move_to_floor(g_map.level_id + 1, TileType.FloorEntry, Sfxs.UpStairs)
    elseif tile.type == TileType.FloorEntry then
        -- if we haven't found the book and we try to leave, warn the player
        if g_player.book_state == PlayerBookState.NotFound then
            g_warning_banner = {
                timer = make_ingame_timer(90),
                text = "Can't leave until I find it."
            }
        elseif g_player.book_state == PlayerBookState.FoundButLost then
            -- if we've found the book but lost it we can freely traverse all floors... EXCEPT we can't leave
            if g_map.level_id != 1 then
                start_move_to_floor(g_map.level_id - 1, TileType.FloorExit, Sfxs.UpStairs)
            else
                g_warning_banner = {
                    timer = make_ingame_timer(90),
                    text = "Can't leave. I dropped the book."
                }
            end
        elseif g_player.book_state == PlayerBookState.Holding then
            -- we have the book. we can traverse up any floor AND win the game by leaving the last floor
            if g_map.level_id != 1 then
                start_move_to_floor(g_map.level_id - 1, TileType.FloorExit, Sfxs.UpStairs)
            else
                g_win_game_state = {
                    substate = "scroll_timer",
                    timer_scroll = 0,
                }
                g_game_timer_ui.set_blinking(true)
                g_game_state = GameStateType.WinGame
                music(-1, 1000)
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
        g_player.book_state = PlayerBookState.Holding
        tile.has_book = false
        collect_item(g_player, ItemType.Book)
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

function lose_game_update(input)
    g_game_timer_ui.update(g_maingame_tick_count)

    if g_lose_game_state.substate == "scroll_timer" then
        g_lose_game_state.timer_scroll += 1
        g_game_timer_ui.move(0, 0.5)
        if g_lose_game_state.timer_scroll == 120 then
            g_lose_game_state.substate = "brief_blink"
            g_lose_game_state.final_blink = make_ingame_timer(120)
        end
    elseif g_lose_game_state.substate == "brief_blink" then
        g_lose_game_state.final_blink.update()
        if g_lose_game_state.final_blink.done() then
            g_lose_game_state.substate = "display_lose_text"
            g_lose_game_state.lose_text_roll_timer = make_ingame_timer(240)
            g_lose_game_state.lose_text = "you were unable to make\nyour way to the bottom\nof the grave in time.\n\nyour family's most\ncherished heirloom is\nlost. gone forever.\n\nthis is unacceptable.\nwe'll have to try again.\n\nx/c - to reset"
        end
    elseif g_lose_game_state.substate == "display_lose_text" then
        g_lose_game_state.lose_text_roll_timer.update()
        if g_lose_game_state.lose_text_roll_timer.done() and (input.btn_x or input.btn_o) then
            reset()
        end
    end
end

function win_game_update(input)
    g_game_timer_ui.update(g_maingame_tick_count)

    if g_win_game_state.substate == "scroll_timer" then
        g_win_game_state.timer_scroll += 1
        g_game_timer_ui.move(0, 0.5)
        if g_win_game_state.timer_scroll == 120 then
            g_win_game_state.substate = "brief_blink"
            g_win_game_state.final_blink = make_ingame_timer(120)
        end
    elseif g_win_game_state.substate == "brief_blink" then
        g_win_game_state.final_blink.update()
        if g_win_game_state.final_blink.done() then
            g_win_game_state.substate = "display_win_text"
            g_win_game_state.win_text_roll_timer = make_ingame_timer(240)
            g_win_game_state.win_text = generate_win_text(#g_player.collected_pages, TOTAL_PAGE_COUNT())
        end
    elseif g_win_game_state.substate == "display_win_text" then
        g_win_game_state.win_text_roll_timer.update()
        if g_win_game_state.win_text_roll_timer.done() and (input.btn_x or input.btn_o) then
            reset()
        end
    end
end

function _draw()
    if g_game_state == GameStateType.MainGame or
       g_game_state == GameStateType.PreGame then
       draw_game()
    elseif g_game_state == GameStateType.LoseGame then
        draw_lose_game()
    elseif g_game_state == GameStateType.WinGame then
        draw_win_game()
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
                elseif isocell.tile.type == TileType.Altar then
                    -- draw the altar
                    spr_centered(88, isocell.pos.x, isocell.pos.y, 2, 1)
                end
            end

            if isocell.tile.has_book then
                draw_book(isocell.pos, isocell.tile.type == TileType.Altar)
            end
        end
    end

    -- if the player is standing on their last visited isotile, highlight it
    if circ_colliders_overlap(g_player, g_player.last_visited_isocell) then
        highlight_iso_cell(g_player.last_visited_isocell)
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
            draw_item_banner("bomb")
        elseif g_player.collect_item_state.item == ItemType.Page then
            draw_page_item(item_pos, g_player.collect_item_state.page_frag)
            draw_item_banner("page fragment")
        elseif g_player.collect_item_state.item == ItemType.Book then
            draw_book(item_pos, false)
            draw_item_banner("granddaddy's book")
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
    if g_player_move_to_floor_state != nil then
        -- noop? I'm not sure why I added this before and am not sure if it's
        -- necessary. Keep it around to avoid mucking with the game this late
        -- in the jam.
    elseif g_player.die_state != nil then
        local died_text = "died."
        if g_player.die_state.had_book then
            died_text = died_text.." dropped book."
        end
        draw_banner(died_text, Colors.Red, Colors.Navy)
    end

    if g_warning_banner != nil then
        draw_banner(g_warning_banner.text, Colors.Tan, Colors.BlueGray)
        g_warning_banner.timer.update()
        if g_warning_banner.timer.done() then
            g_warning_banner = nil
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

function draw_lose_game()
    cls(Colors.BLACK)

    if g_lose_game_state.substate != "display_lose_text" then
        -- Set the camera view so that the world is draw relative to its position
        camera_follow_player(g_player, g_camera_player_offset)
        camera(g_camera_player_offset.x, g_camera_player_offset.y);

        -- draw the player frozen at the lose state
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
        local rolled_text_ratio = g_lose_game_state.lose_text_roll_timer.get_elapsed_ratio()
        local end_char = flr((#g_lose_game_state.lose_text) * rolled_text_ratio)
        local lose_text = sub(g_lose_game_state.lose_text, 1, end_char)
        print(lose_text, 10, 10, Colors.White)

        -- draw the page UI
        draw_page_ui(g_player)
    end
end

function draw_win_game()
    cls(Colors.BLACK)

    if g_win_game_state.substate != "display_win_text" then
        -- Set the camera view so that the world is draw relative to its position
        camera_follow_player(g_player, g_camera_player_offset)
        camera(g_camera_player_offset.x, g_camera_player_offset.y);

        -- draw the player frozen at the win state
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
        local rolled_text_ratio = g_win_game_state.win_text_roll_timer.get_elapsed_ratio()
        local end_char = flr((#g_win_game_state.win_text) * rolled_text_ratio)
        local win_text = sub(g_win_game_state.win_text, 1, end_char)
        print(win_text, 10, 10, Colors.White)

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

function draw_book(pos_center, on_altar)
    if on_altar then
        -- draw the book on the altar
        spr_centered(72, pos_center.x, pos_center.y - 4, 1, 1)
    else
        -- draw just the book on the floor
        spr_centered(72, pos_center.x, pos_center.y, 1, 1)
    end
end

function draw_item_banner(item_name)
    draw_banner("got: "..item_name, Colors.DarkGreen, Colors.Tan)
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
        map.isocells[player_start_iso_idx].tile = make_tile(true, TileType.FloorEntry)

        -- set the finish cell on this map.
        map.finish_cell_idx = select_random_empty_tile_idx_from_map(map)
        map.isocells[map.finish_cell_idx].tile = make_tile(false, TileType.FloorExit)
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

    local page_cell_cnt = TOTAL_PAGE_COUNT()
    local page_cells = select_random_empty_tiles(maps, page_cell_cnt)
    for page_cell in all(page_cells) do
        page_cell.map.isocells[page_cell.idx].tile = make_tile(false, TileType.PageItem)
        page_cell.map.isocells[page_cell.idx].tile.page_frag = page_fragments[next_page_frag_idx + 1]
        next_page_frag_idx = ((next_page_frag_idx + 1) % #page_fragments)
    end

    -- Now that all interesting cells have been placed, fill in the remaining empty
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

    -- Last but not least, we'll generate the last level. This
    -- level is generated specially since it doesn't follow the rules of the previous maps.
    -- It's just the single goal item in the middle of an empty layer
    local final_map = generate_empty_level(num_maps, MAX_TILE_LINE())
    -- set the final level's entry
    local final_map_start_iso_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.isocells[final_map_start_iso_idx].tile = make_tile(true, TileType.FloorEntry)
    -- set the altar point
    local altar_cell_idx = select_random_empty_tile_idx_from_map(final_map)
    final_map.isocells[altar_cell_idx].tile = make_tile(true, TileType.Altar)
    final_map.isocells[altar_cell_idx].tile.has_book = true
    -- turn every other cell into a stone floor cell
    for cell in all(final_map.isocells) do
        if cell.tile.type == TileType.Empty then
            cell.tile = make_tile(true, TileType.StoneFloor)
        end
    end
    add(maps, final_map)

    -- uncomment this to make all tiles visible at start
    -- for map in all(maps) do
    --     for cell in all(map.isocells) do
    --         cell.tile.visible = true
    --     end
    -- end

    -- uncomment this to make all exit tiles and page tiles visible at start
    -- for map in all(maps) do
    --     for cell in all(map.isocells) do
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
    for cell in all(g_map.isocells) do
        if cell.tile.type == start_tile_type then
            player_start_cell = cell
            break
        end
    end
    assert(player_start_cell != nil)
    g_player.pos = copy_vec2(player_start_cell.pos)
    g_player.last_visited_isocell = player_start_cell
    g_player.last_interacted_isocell = player_start_cell

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

function highlight_iso_cell(cell)
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

function generate_win_text(collected_page_count, total_page_count)
    local text = "you made it back with the book, a brown book stitched together with strong thread and thick brown pages, a family heirloom."
    if collected_page_count == 0 then
        text = text .. " opening the book you realize several pages are missing. maybe they're back down in the grave, but there isn't time to check. i guess there's some comfort knowing you have the book at all. in another life, maybe you could find those pages.\n\nx/c - to reset"
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

        text = text .. " setting the "..collected_page_count.." recovered "..page_plural.." in the book you realize there "..gap_plural.." back down in the grave. there's no time to check. it's not whole, but there's comfort in what you have. in another life, maybe we could recover the rest.\n\nx/c - to reset"
    else
        text = text .. " setting all "..total_page_count.." pages you found below in the book you realize the book is complete.\n\nx/c - to reset"
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

-- TODO: keep track of things I still need to do so I don't forget
-- boulders falling after collecting items?
-- title screen
-- last minute ideas. a trap which disorients you
-- last minute ideas. an item which slows down time for a bit
