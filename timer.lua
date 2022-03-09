-- main file for timer.p8

-- global variables
g_timer_blink = 0
g_timer_blink_period = 25
g_real_time_ticks = nil

function update_timer(input)
    if input.btn_o and input.btn_o_change and g_real_time_ticks == nil then
        g_real_time_ticks = 0
        g_timer_blink = nil
    end

    if g_timer_blink != nil then
        g_timer_blink += 1
        if g_timer_blink > (g_timer_blink_period * 1.5) then
            g_timer_blink = 0
        end
    end

    if g_real_time_ticks != nil then
        g_real_time_ticks += 1
    end
end

function draw_timer()
    -- render the timer
    local blink_state = get_timer_blink_state()
    local hide_timer_for_blink = (blink_state != nil) and (not blink_state)
    if not hide_timer_for_blink then
        local should_flash = should_flash_time(g_real_time_ticks)
        local text_color = Colors.White
        local text_pos_x = 64
        local text_pos_y = 64
        if should_flash and (blink_state == nil) then
            text_color = Colors.Yellow
            -- add shake to timer
            text_pos_x += rndrange_inc(-1, 1)
            text_pos_y += rndrange_inc(-1, 1)
        end

        local time_elapsed_ratio = get_realtime_completion_ratio(g_real_time_ticks)
        local ingame_total_minutes = (24 * 60)
        local time_remaining_minutes = (1 - time_elapsed_ratio) * ingame_total_minutes
        local time_remaining_parts = generate_timestamp(time_remaining_minutes)

        local timer_text = format_int_base10(time_remaining_parts.Hours, 2) .. "H:" .. format_int_base10(time_remaining_parts.Minutes, 2) .. "M:" .. format_int_base10(time_remaining_parts.Seconds, 2) .. "S"

        -- render the timer text with a gray drop shadow
        print(timer_text, text_pos_x + 1, text_pos_y + 1, Colors.DarkGray)
        print(timer_text, text_pos_x, text_pos_y, text_color)
    end
end

function get_timer_blink_state()
    if g_timer_blink == nil then
        return nil
    end

    return g_timer_blink < g_timer_blink_period
end

function get_time_elapsed(real_ticks)
    if real_ticks == nil then
        return 0
    else
        return real_ticks
    end
end

function get_realtime_completion_ratio(realtime_tick_tracker)
    local realtime_ticks = 0
    if realtime_tick_tracker != nil then
        realtime_ticks = realtime_tick_tracker
    end

    local total_realtime_ticks = (5 * 60 * 30) -- five minutes worth of ticks
    return realtime_ticks / total_realtime_ticks
end

function should_flash_time(realtime_tick_tracker)
    local realtime_ticks = 0
    if realtime_tick_tracker != nil then
        realtime_ticks = realtime_tick_tracker
    end
    local flash_start = flr(5 * 60 * 30 / 24)
    local flash_duration_in_ticks = 10
    return (realtime_ticks % flash_start) < flash_duration_in_ticks
end

function format_int_base10(n, max_leading_zeroes)
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

function generate_timestamp(time_in_minutes)
    local hrs_part = flr(time_in_minutes / 60)
    local fixed_point_minutes_part = time_in_minutes % 60
    local minutes_part = flr(fixed_point_minutes_part)
    local fixed_point_seconds_part = (fixed_point_minutes_part & 0x0000.ffff) * 60
    local seconds_part = flr(fixed_point_seconds_part)
    return { Hours = hrs_part, Minutes = minutes_part, Seconds = seconds_part }
end

function rndrange_inc(lower, upper)
    return flr(rnd(upper - lower)) + lower
end

