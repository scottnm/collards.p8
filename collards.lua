-- main file for sweep.p8

-- Enums
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

TileType = {
    Empty = 1,
    Finish = 2,
}

-- constants
function TILE_SIZE()
    return 16
end

function SCREEN_SIZE()
    return 128
end

function MAX_TILE_LINE()
    return SCREEN_SIZE() /  TILE_SIZE()
end

-- global variables
g_level = nil
g_map_size = nil
g_map = nil
g_player_pos = nil
g_input = nil
g_player_found_exit_timer = nil

function _init()
    -- noop
    advance_level()
end

function _update()
    -- handle the block state
    if g_player_found_exit_timer != nil then
        g_player_found_exit_timer += 1
        if g_player_found_exit_timer >= 60 then -- 2 seconds
            g_player_found_exit_timer = nil
            advance_level()
        end
        return
    end

    -- get input
    g_input = poll_input(g_input)
    if g_input.btn_o and g_input.btn_o_change then
        -- flip the player tile
        flip_player_tile()
    end

    move_player(g_input)
end

function _draw()
    cls(Colors.BLACK)

    -- draw the tiles
    local map_pixel_width = g_map_size.width * TILE_SIZE()
    local map_pixel_height = g_map_size.height * TILE_SIZE()
    -- offsets to draw the map in the center of the board
    local pixel_row_offset = flr((SCREEN_SIZE() - map_pixel_height) / 2)
    local pixel_col_offset = flr((SCREEN_SIZE() - map_pixel_width) / 2)

    -- draw base map
    for row=0,g_map_size.height-1 do
        for col=0,g_map_size.width-1 do
            local tile = g_map[row+1][col+1]
            local tile_x0 = col * TILE_SIZE() + pixel_col_offset
            local tile_x1 = tile_x0 + TILE_SIZE() - 1
            local tile_y0 = row * TILE_SIZE() + pixel_row_offset
            local tile_y1 = tile_y0 + TILE_SIZE() - 1

            rectfill(tile_x0, tile_y0, tile_x1, tile_y1, get_tile_color(tile))
        end
    end

    -- draw player position
    local player_tile_x0 = (g_player_pos.x-1) * TILE_SIZE() + pixel_col_offset
    local player_tile_x1 = player_tile_x0 + TILE_SIZE() - 1
    local player_tile_y0 = (g_player_pos.y-1) * TILE_SIZE() + pixel_row_offset
    local player_tile_y1 = player_tile_y0 + TILE_SIZE() - 1
    rect(player_tile_x0, player_tile_y0, player_tile_x1, player_tile_y1, Colors.White)

    -- print the level
    print("Level: "..g_level, 0, 0)
    if g_player_found_exit_timer != nil then
        print("FOUND EXIT", 0, 5)
    end

end

function advance_level()
    -- update the level
    if g_level != nil then
        g_level += 1
    else
        g_level = 1
    end

    -- update the map size
    if g_map_size != nil then
        g_map_size.width = min(g_map_size.width + 1, MAX_TILE_LINE())
        g_map_size.height = min(g_map_size.height + 1, MAX_TILE_LINE())
    else
        g_map_size = { width = 4, height = 4 }
    end

    -- generate the map
    g_map = {}
    for row=1,g_map_size.height do
        add(g_map, {})
        for col=1,g_map_size.width do
            add(g_map[row], generate_tile())
        end
    end

    -- place the player
    g_player_pos = generate_random_map_position()

    -- place the finish
    local finish_point = generate_random_map_position()
    g_map[finish_point.y][finish_point.x].type = TileType.Finish
end

function generate_tile()
    -- TODO: actually generate interesting tiles. For now just generate empty/safe tiles
    return { visible = false, type = TileType.Empty }
end

function rndrange_inc(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

function generate_random_map_position()
    local x = rndrange_inc(1, g_map_size.width)
    local y = rndrange_inc(1, g_map_size.height)
    return { x = x, y = y }
end

function get_tile_color(tile)
    if tile.visible then
        if tile.type == TileType.Empty then
            return Colors.Tan
        elseif tile.type == TileType.Finish then
            return Colors.LightGreen
        else
            return nil
        end
    else
        return Colors.Brown
    end
end

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

function flip_player_tile()
    local tile = g_map[g_player_pos.y][g_player_pos.x]
    if tile.visible then
        -- tile already visible. do nothing
        return
    end

    tile.visible = true
    if tile.type == TileType.Finish then
        g_player_found_exit_timer = 0
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

    g_player_pos.x = clamp(1, g_player_pos.x + movement.x, g_map_size.width)
    g_player_pos.y = clamp(1, g_player_pos.y + movement.y, g_map_size.height)
end

function clamp(lower, value, upper)
    return mid(lower, value, upper)
end

