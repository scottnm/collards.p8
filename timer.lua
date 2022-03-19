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
