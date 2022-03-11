-- timer.lua - UI timers

function make_timer()
    local self = {
        timer_blink = 0,
        timer_blink_period = 25,
        real_time_ticks = nil
    }

    local get_realtime_completion_ratio = function (realtime_tick_tracker)
        local realtime_ticks = 0
        if realtime_tick_tracker != nil then
            realtime_ticks = realtime_tick_tracker
        end

        local total_realtime_ticks = (5 * 60 * 30) -- five minutes worth of ticks
        return realtime_ticks / total_realtime_ticks
    end

    local should_flash_time = function (realtime_tick_tracker)
        local realtime_ticks = 0
        if realtime_tick_tracker != nil then
            realtime_ticks = realtime_tick_tracker
        end
        local flash_start = flr(5 * 60 * 30 / 24)
        local flash_duration_in_ticks = 10
        return (realtime_ticks % flash_start) < flash_duration_in_ticks
    end

    local get_timer_blink_state = function ()
        if self.timer_blink == nil then
            return nil
        end

        return self.timer_blink < self.timer_blink_period
    end

    local generate_timestamp = function (time_in_minutes)
        local hrs_part = flr(time_in_minutes / 60)
        local fixed_point_minutes_part = time_in_minutes % 60
        local minutes_part = flr(fixed_point_minutes_part)
        local fixed_point_seconds_part = (fixed_point_minutes_part & 0x0000.ffff) * 60
        local seconds_part = flr(fixed_point_seconds_part)
        return { Hours = hrs_part, Minutes = minutes_part, Seconds = seconds_part }
    end

    local update_timer = function (input)
        if input.btn_o and input.btn_o_change and self.real_time_ticks == nil then
            self.real_time_ticks = 0
            self.timer_blink = nil
        end

        if self.timer_blink != nil then
            self.timer_blink += 1
            if self.timer_blink > (self.timer_blink_period * 1.5) then
                self.timer_blink = 0
            end
        end

        if self.real_time_ticks != nil then
            self.real_time_ticks += 1
        end
    end

    local draw_timer = function()
        -- render the timer
        local blink_state = get_timer_blink_state()
        local hide_timer_for_blink = (blink_state != nil) and (not blink_state)
        if not hide_timer_for_blink then
            local should_flash = should_flash_time(self.real_time_ticks)
            local text_color = Colors.White
            local text_pos_x = 64
            local text_pos_y = 64
            if should_flash and (blink_state == nil) then
                text_color = Colors.Yellow
                -- add shake to timer
                text_pos_x += rnd_incrange(-1, 1)
                text_pos_y += rnd_incrange(-1, 1)
            end

            local time_elapsed_ratio = get_realtime_completion_ratio(self.real_time_ticks)
            local ingame_total_minutes = (24 * 60)
            local time_remaining_minutes = (1 - time_elapsed_ratio) * ingame_total_minutes
            local time_remaining_parts = generate_timestamp(time_remaining_minutes)

            local timer_text = format_int_base10(time_remaining_parts.Hours, 2) .. "H:" .. format_int_base10(time_remaining_parts.Minutes, 2) .. "M:" .. format_int_base10(time_remaining_parts.Seconds, 2) .. "S"

            -- render the timer text with a gray drop shadow
            print(timer_text, text_pos_x + 1, text_pos_y + 1, Colors.DarkGray)
            print(timer_text, text_pos_x, text_pos_y, text_color)
        end
    end

    return {
        update = update_timer,
        draw = draw_timer,
    }
end
