-- test cart for trying out iso xform
SQRT_HALF = 0.70710678118 -- sqrt(0.5); hardcode to avoid doing an expensive squareroot every frame

function world_to_iso(wp)
    -- SRT / TRS
    local ip = vec_copy(wp)

    -- translate to center
    ip.x += 64
    ip.y += 64

    -- rotate
    ip = vec(SQRT_HALF * (ip.x - ip.y), SQRT_HALF * (ip.x + ip.y))

    -- scale
    ip.x *= 2
end

function _init()
    g_player = {
        pos = vec(0,0)
    }
end

function _draw()
    -- local draw_pos = world_to_iso(g_player.pos)
    cls(Colors.Black)
    local draw_pos = vec(64,64)
    rectfill(draw_pos.x, draw_pos.y, draw_pos.x+10, draw_pos.y+10, Colors.Red)
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
            dx = -2 * sqrt_half
            dy = -1 * sqrt_half
        elseif input.btn_down then
            dx = -2 * sqrt_half
            dy = sqrt_half
        else
            dx = -2
            dy = 0
        end
    elseif input.btn_right then
        if input.btn_up then
            dx = 2 * sqrt_half
            dy = -1 * sqrt_half
        elseif input.btn_down then
            dx = 2 * sqrt_half
            dy = sqrt_half
        else
            dx = 2
            dy = 0
        end
    elseif input.btn_up then
        dx = 0
        dy = -1
    elseif input.btn_down then
        dx = 0
        dy = 1
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
        local oob = (
            player.pos.x >= 64 or
            player.pos.x < 0 or
            player.pos.y >= 128 or
            player.pos.y < 0)

        if not oob then
            return
        end
    end

    -- no movements worked, rollback
    player.pos = old_player_pos
end

