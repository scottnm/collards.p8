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

