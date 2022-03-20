-- dbg.lua - dbg helpers

function dbg_display_frame_stats(pos)
    print("mem:  "..  stat(0), pos.x, pos.y + 00, Colors.White)
    print("cpu:  "..  stat(1), pos.x, pos.y + 10, Colors.White)
    print("fps(t): "..stat(8), pos.x, pos.y + 20, Colors.White)
    print("fps(a): "..stat(7), pos.x, pos.y + 30, Colors.White)
end

function dbg_display_colliders()
    circ(g_player.pos.x, g_player.pos.y, g_player.collider.radius, Colors.White)
    for cell in all(g_map.cells) do
        circ(cell.pos.x, cell.pos.y, cell.collider.radius, Colors.White)
    end
    for bomb in all(g_bombs) do
        for e in all(bomb.get_explosions()) do
            circ(e.pos.x, e.pos.y, e.collider.radius, Colors.White)
        end
    end
end

function dbg_display_anim_state(obj, pos, anims)
    local flip_string = nil
    if obj.anim_state.flip then
        flip_string = "true"
    else
        flip_string = "false"
    end

    local flow_string = ""
    for k,v in pairs(anims) do
        if v == obj.anim_state.last_flow then
            flow_string = k
            break
        end
    end

    print("a_ct: "..     obj.anim_state.a_ct, pos.x, pos.y + 00, Colors.White)
    print("a_st: "..     obj.anim_state.a_st, pos.x, pos.y + 10, Colors.White)
    print("a_fr: "..     obj.anim_state.a_fr, pos.x, pos.y + 20, Colors.White)
    print("flip: "..             flip_string, pos.x, pos.y + 30, Colors.White)
    print("ts:   "..obj.anim_state.tile_size, pos.x, pos.y + 40, Colors.White)
    print("lf:   "..             flow_string, pos.x, pos.y + 50, Colors.White)
end
