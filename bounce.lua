-- bounce.lua - animate bounces

function create_bounces(total_frames, bounces)
    local bounce_portion_sum = 0
    for bounce in all(bounces) do
        bounce_portion_sum += bounce.portion
    end
    assert(bounce_portion_sum == 100)

    local self = {
        total_frames = total_frames,
        frame_cnt = 0,
        bounces
    }

    local pow4 = function(x)
        return x * x * x * x
    end

    local update = function()
        if self.frame_cnt > self.total_frames then
            return
        end

        local t = (self.frame_cnt * 100) / self.total_frames

        local completed_portions = 0
        for bounce in all(bounces) do
            if t < (completed_portions + bounce.portion) then
                local t0 = min((t - completed_portions) / bounce.portion, 1)
                self.v = bounce.height - bounce.height * pow4(2 * (t0 - 0.5))
                break
            else
                completed_portions += bounce.portion
            end
        end

        self.frame_cnt += 1
    end

    local get_bounce_value = function()
        return self.v
    end

    local get_frame_cnt = function()
        return self.frame_cnt
    end

    return {
        update = update,
        get_bounce_value = get_bounce_value,
        get_frame_cnt = get_frame_cnt,
    }
end
