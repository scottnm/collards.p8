-- anim.lua - animation logic

--
-- N.B. lots of this code is adapted from scathe's anim
-- function on the pico8 bbs
-- https://www.lexaloffle.com/bbs/?tid=3115&autoplay=1#pp
-- Thanks scathe!
--

function create_anim_flow(frames, speed, tile_size, flip)
    return {
        frames = frames,
        num_tiles = count(frames),
        speed = speed,
        tile_size = tile_size,
        flip = flip,
    }
end

function new_anim_state()
    return { a_ct = 0, a_st = 0, a_fr = 0, loop = 0 }
end

function reset_anim(obj)
    obj.anim_state.a_ct = 0
    obj.anim_state.a_st = 0
    obj.anim_state.loop = 0
end

function update_anim(obj, anim_flow)
    obj.anim_state = obj.anim_state or new_anim_state()
    local anim_state = obj.anim_state

    anim_state.a_ct += 1

    local move_to_next_frame = anim_state.a_ct % (30 / anim_flow.speed) == 0
    if move_to_next_frame then
        anim_state.a_st += 1
        if anim_state.a_st >= anim_flow.num_tiles then
            anim_state.a_st = 0
            anim_state.loop += 1
        end
    elseif anim_state.a_st >= anim_flow.num_tiles then
        anim_state.a_st = 0
    end

    local frame = anim_flow.frames[anim_state.a_st + 1]

    anim_state.a_fr = frame
    anim_state.flip = anim_flow.flip
    anim_state.tile_size = anim_flow.tile_size
    anim_state.last_flow = anim_flow
end

function draw_anim(obj, sprite_pos)
    spr(obj.anim_state.a_fr, sprite_pos.x, sprite_pos.y, obj.anim_state.tile_size, obj.anim_state.tile_size, obj.anim_state.flip)
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
