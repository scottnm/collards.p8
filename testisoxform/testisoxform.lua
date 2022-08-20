--
--
--
--
--
--
-- test cart for trying out iso xform
SQRT_HALF = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame

-- function draw_world_space_test(ofs)
--     p1 =
-- end
function print_world_space_test()
    local size = 11.3135
    p1 = vec(0, 0)
    p2 = vec(size, 0)
    p3 = vec(size, size)
    p4 = vec(0, size)

    local width = world_to_iso(p2).x - world_to_iso(p4).x
    local height = world_to_iso(p3).y - world_to_iso(p1).y

    print("WIDTH: "..width)
    print("HEIGHT: "..height)
end

function world_to_iso(wp)
    -- SRT / TRS
    local ip = vec_copy(wp)

    -- rotate
    ip = vec(SQRT_HALF * (ip.x - ip.y), SQRT_HALF * (ip.x + ip.y))

    -- scale
    ip.x *= 2

    -- translate to center
    ip.x += 64
    ip.y += 64

    return ip
end

function iso_to_world(ip)
    -- SRT / TRS
    local wp = vec_copy(ip)

    -- translate from center
    wp.x -= 64
    wp.y -= 64

    -- scale
    wp.x /= 2

    -- rotate
    wp = vec(SQRT_HALF * (wp.x - wp.y), SQRT_HALF * (wp.x + wp.y))

    return wp
end

function _init()
    g_player = {
        pos = vec(0,0)
    }
end

function draw_point(p, c)
    c = c or Colors.White
    rectfill(p.x, p.y, p.x+1, p.y+1, c)
end

function _draw()
    cls(Colors.Black)
    top_p =    world_to_iso(vec_scale(vec(-1, -1), 20))
    right_p =  world_to_iso(vec_scale(vec( 1, -1), 20))
    bottom_p = world_to_iso(vec_scale(vec( 1,  1), 20))
    left_p =   world_to_iso(vec_scale(vec(-1,  1), 20))

    line(0,0,127,0,Colors.White)
    line(0,127,127,127,Colors.White)
    line(0,0,0,127,Colors.White)
    line(127,0,127,127,Colors.White)

    draw_point(top_p, Colors.Orange)
    draw_point(right_p, Colors.LightGreen)
    draw_point(bottom_p, Colors.SkyBlue)
    draw_point(left_p, Colors.Pink)

    local player_screen_pos = world_to_iso(g_player.pos)
    draw_point(player_screen_pos, Colors.Red)
end

function _update()
    move_player(poll_input(), g_player)
end

function move_player(input, player)
    -- when traveling diagnonally, multiply by the factor sqrt(0.5) to avoid traveling further by going diagonally
    local sqrt_half = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame
    local dx = 0
    local dy = 0
    if input.btn_left then
        if input.btn_up then
            dx = -1
            dy = 0
        elseif input.btn_down then
            dx = 0
            dy = 1
        else
            dx = -1 * SQRT_HALF
            dy = 1 * SQRT_HALF
        end
    elseif input.btn_right then
        if input.btn_up then
            dx = 0
            dy = -1
        elseif input.btn_down then
            dx = 1
            dy = 0
        else
            dx = 1 * SQRT_HALF
            dy = -1 * SQRT_HALF
        end
    elseif input.btn_up then
        dx = -1 * SQRT_HALF
        dy = -1 * SQRT_HALF
    elseif input.btn_down then
        dx = 1 * SQRT_HALF
        dy = 1 * SQRT_HALF
    else
        return
    end

    local player_spd = 1.0 -- an arbitrary speed factor to hand tune movement speed to feel good
    dx *= player_spd
    dy *= player_spd

    -- copy the old position in case we need to roll back
    local old_player_pos = vec_copy(player.pos)

    -- test all potential movements and use the first one that doesn't put us on a fall tile
    local move_candidates = {}
    add(move_candidates, vec(dx, dy))
    if dx != 0 then
        add(move_candidates, vec(dx, 0))
    end
    if dy != 0 then
        add(move_candidates, vec(0, dy))
    end

    for move in all(move_candidates) do
        player.pos = vec_add(old_player_pos, move)
        local oob = false
        -- local oob = (
        --     player.pos.x >= 64 or
        --     player.pos.x < -64 or
        --     player.pos.y >= 64 or
        --     player.pos.y < -64)

        if not oob then
            return
        end
    end

    -- no movements worked, rollback
    player.pos = old_player_pos
end

