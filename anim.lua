-- anim.lua - animation logic
-- Based on scathe's anim function (thanks!) https://www.lexaloffle.com/bbs/?tid=3115&autoplay=1#pp

function create_anim(frames, speed, tile_size, flip)
    return {
        frames = frames,
        num_tiles = count(frames),
        speed = speed,
        tile_size = tile_size,
        flip = flip,
    }
end

function reset_anim(obj)
    obj.anim_state.a_ct = 0
    obj.anim_state.a_st = 0
    obj.anim_state.loop = 0
end

function update_anim(obj, anim)
    obj.anim_state = obj.anim_state or { a_ct = 0, a_st = 0, a_fr = 0, loop = 0 }
    local anim_state = obj.anim_state

    anim_state.a_ct += 1

    local move_to_next_frame = anim_state.a_ct % (30 / anim.speed) == 0
    if move_to_next_frame then
        anim_state.a_st += 1
        if anim_state.a_st >= anim.num_tiles then
            anim_state.a_st = 0
            anim_state.loop += 1
        end
    elseif anim_state.a_st >= anim.num_tiles then
        anim_state.a_st = 0
    end

    local frame = anim.frames[anim_state.a_st + 1]

    anim_state.a_fr = frame
    anim_state.flip = anim.flip
    anim_state.tile_size = anim.tile_size
    anim_state.last_anim = anim
end

function draw_anim(obj, spr_pos)
    local anim_state = obj.anim_state
    spr(anim_state.a_fr, spr_pos.x, spr_pos.y, anim_state.tile_size, anim_state.tile_size, anim_state.flip)
end
