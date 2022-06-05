-- animation
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

function _init_animations()
    g_anims = {
        IdleDown = create_anim({34}, 10, 2, false),
        WalkDown = create_anim({32, 34, 36}, 10, 2, false),
        IdleUp = create_anim({40}, 10, 2, false),
        WalkUp = create_anim({38, 40, 42}, 10, 2, false),
        IdleRight = create_anim({66}, 10, 2, false),
        WalkRight = create_anim({64, 66, 68}, 10, 2, false),
        IdleLeft = create_anim({66}, 10, 2, true),
        WalkLeft = create_anim({64, 66, 68}, 10, 2, true),
        IdleUpRight = create_anim({8}, 10, 2, false),
        WalkUpRight = create_anim({6, 8, 10}, 10, 2, false),
        IdleDownRight = create_anim({2}, 10, 2, false),
        WalkDownRight = create_anim({0, 2, 4}, 10, 2, false),
        IdleUpLeft = create_anim({8}, 10, 2, true),
        WalkUpLeft = create_anim({6, 8, 10}, 10, 2, true),
        IdleDownLeft = create_anim({2}, 10, 2, true),
        WalkDownLeft = create_anim({0, 2, 4}, 10, 2, true),
        DigRight = create_anim({12, 12, 14}, 5, 2, false),
        DigLeft = create_anim({12, 12, 14}, 5, 2, true),
        DieLeft = create_anim({70, 70, 238}, 5, 2, true),
        DieRight = create_anim({70, 70, 238}, 5, 2, false),
        CollectItem = create_anim({46}, 1, 2, false),
        BombFlash = create_anim({74, 74, 74, 74, 74, 74, 74, 75, 74, 74, 75, 74, 74, 75, 74}, 15, 1, false),
    }
end

