-- anim.lua - animation logic

--
-- N.B. lots of this code is adapted from scathe's anim
-- function on the pico8 bbs
-- https://www.lexaloffle.com/bbs/?tid=3115&autoplay=1#pp
-- Thanks scathe!
--

function create_anim_flow(start_frame, num_tiles, speed, tile_size, flip)
    return {
        start_frame = start_frame,
        num_tiles = num_tiles,
        speed = speed,
        tile_size = tile_size,
        flip = flip,
    }
end

function update_anim(obj, anim_flow)
    obj.anim_state = obj.anim_state or { a_ct = 0, a_st = 0, a_fr = 0 }
    local anim_state = obj.anim_state

    anim_state.a_ct += 1

    local move_to_next_frame = anim_state.a_ct % (30 / anim_flow.speed) == 0
    if move_to_next_frame then
        anim_state.a_st += 1
        if anim_state.a_st >= anim_flow.num_tiles then
            anim_state.a_st = 0
        end
    end

    anim_state.a_fr = anim_flow.start_frame + (anim_state.a_st * anim_flow.tile_size)
    anim_state.flip = anim_flow.flip
    anim_state.tile_size = anim_flow.tile_size
    anim_state.last_flow = anim_flow
end

function draw_anim(obj, sprite_pos)
    spr(obj.anim_state.a_fr, sprite_pos.x, sprite_pos.y, obj.anim_state.tile_size, obj.anim_state.tile_size, obj.anim_state.flip)
end
