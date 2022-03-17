-- main.lua - main game logic

g_input = nil
-- pos_x = nil
-- pos_y = nil
-- total_frames = 45
-- frame_cnt = nil

function _init()
    reset()
end

function reset()
    -- pos_x = 0
    -- pos_y = 0
    -- frame_cnt = 0
    local bounces = {
            { portion = 60, height = 10 },
            { portion = 33, height = 5 },
            { portion =  7, height = 1 },
        }
    g_bounce_tracker = create_bounces(45, bounces)
end

function _update()
    -- -- get input
    g_input = poll_input(g_input)

    if g_input.btn_o and g_input.btn_o_change then
        reset()
    end

    g_bounce_tracker.update()
    -- if frame_cnt > total_frames then
    --     return
    -- end

    -- local t = frame_cnt / total_frames

    -- local y_ofs = 0
    -- if     t < 0.60 then
    --     local t0 = min(t / 0.60, 1)
    --     y_ofs = 10 - 10 * quad(2 * (t0 - 0.5))
    -- elseif t < 0.93 then
    --     local t0 = min((t - 0.6) / 0.33, 1)
    --     y_ofs = 5 - 5 * quad(2 * (t0 - 0.5))
    -- else
    --     local t0 = min((t - 0.93) / 0.07, 1)
    --     y_ofs = 1 - 1 * quad(2 * (t0 - 0.5))
    -- end

    -- pos_y = y_ofs
    -- frame_cnt += 1
end

function _draw()
    cls(0)
    local y = g_bounce_tracker.get_bounce_value()
    rectfill(0, y, 4, y + 4, 4)

    print("        y:"..y, 0, 110, 4)
    print("frame_cnt:"..g_bounce_tracker.get_frame_cnt(), 0, 120, 4)
end

function sqr(x) return x * x end
function quad(x) return x * x * x * x end

