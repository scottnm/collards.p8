-- tbj3.lua
--
-- a test cart for trying out
-- sprite importer features
--
-- all sprites sourced from
-- tbj3
--
-- https://drive.google.com/drive/folders/1by4zdvqlc4jmusk2fohaca6sry_0ar1h
--
--
function _init()
    player={}
    player.x=24
    player.y=24
    anim(player,1,5,10,2)
end

function _update()
    cls()

    if (btn(0)) then
        player.x-=1
        anim(player,33,5,10,2,true)
    elseif (btn(1)) then
        player.x+=1
        anim(player,33,5,10,2,false)
    elseif (btn(2)) then
        player.y-=1
        anim(player,97,5,10,2,false)
    elseif (btn(3)) then
        player.y+=1
        anim(player,1,5,10,2)
    else
        spr(player.a_fr, player.x, player.y, 2, 2, player.flip)
    end
end

-- anim function adapted from scathe on the pico8 bbs
-- https://www.lexaloffle.com/bbs/?tid=3115&autoplay=1#pp
--
--object, start frame,
--num frames, speed, flip
function anim(obj, start_frame, num_frames, speed, tile_sprite_size, flip)
    obj.a_ct = obj.a_ct or 0
    obj.a_st = obj.a_st or 0

    obj.a_ct += 1

    local move_to_next_frame = obj.a_ct % (30 / speed) == 0
    if move_to_next_frame then
        obj.a_st += 1
        if obj.a_st == num_frames then
            obj.a_st = 0
        end
    end

    obj.a_fr = start_frame + (obj.a_st * tile_sprite_size)
    obj.flip = flip
    spr(obj.a_fr, obj.x, obj.y, tile_sprite_size, tile_sprite_size, obj.flip)
end

