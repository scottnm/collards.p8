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

function draw_text_roll(text, t, x, y, c, wrap_line)
    c = c or Colors.White

    local start_char = 1
    local end_char = flr((#text) * t)

    local newline_cnt = 0
    for i=1,end_char do
        local next_char_idx = end_char - (i - 1) -- iterate in reverse
        local next_char = sub(text, next_char_idx, next_char_idx)
        if next_char == "\n" then
            newline_cnt += 1
            if newline_cnt >= wrap_line then
                start_char = next_char_idx + 1
                break
            end
        end
    end

    print(sub(text, start_char, end_char), x, y, c)
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

function chain_text_with_pauses(chunks, pause)
    local s = ""
    for i=1,(#chunks-1) do
        t = chunks[i]
        s = s..t
        for j=1,pause do s = s.." " end
        s = s.."\n\n"
    end
    return s..chunks[#chunks]
end
