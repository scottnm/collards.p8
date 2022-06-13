-- utils

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

function SCREEN_SIZE()
    return 128
end

-- generate random int from inclusive range
function rnd_incrange(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

function clamp(lower, value, upper)
    return mid(lower, value, upper)
end

function poll_input()
    return {
        btn_left = btn(0),
        btn_left_change = btnp(0),
        btn_right = btn(1),
        btn_right_change = btnp(1),
        btn_up = btn(2),
        btn_up_change = btnp(2),
        btn_down = btn(3),
        btn_down_change = btnp(3),
        btn_o = btn(4),
        btn_o_change = btnp(4),
        btn_x = btn(5),
        btn_x_change = btnp(5),
        any_change = btnp() != 0,
    }
end

-- format a base10 int as a string with left-padded zeros
function int_leftpad(n, width)
    local s = tostr(n)
    repeat
        n = flr(n/10)
        width -= 1
    until (width <= 0) or (n <= 0)

    while (width > 0) do
        s = "0"..s
        width -= 1
    end

    return s
end

function sqr(x)
    return x * x
end

function sqr_dist(a, b)
    return sqr(a.x - b.x) + sqr(a.y - b.y)
end

function save_cam_state()
    return { x = peek2(0x5f28), y = peek2(0x5f2a) }
end

function restore_cam_state(c)
    camera(c.x, c.y)
end

function vec(x,y)
    return { x=x, y=y }
end

function vec_copy(v)
    return vec(v.x, v.y)
end

function vec_add(v1, v2)
    return vec(v1.x + v2.x, v1.y + v2.y)
end

function vec_sub(v1, v2)
    return vec(v1.x - v2.x, v1.y - v2.y)
end

function vec_scale(v, s)
    return vec(v.x * s, v.y * s)
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
