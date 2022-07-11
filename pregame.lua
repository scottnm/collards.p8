-- title screen

function _init_title_screen()
    g_player = {
        pos = vec(64, 104),
        sprite_offset = vec(-8, -14),
    }
    update_anim(g_player, g_anims.WalkLeft)

    g_main_grave = nil

    g_letters = { d = 194, i = 196, g = 198, e = 200, p = 202 }

    g_title = { g_letters.d, g_letters.i, g_letters.g,
                g_letters.d, g_letters.e, g_letters.e, g_letters.p }

    g_subphase = "wait"

    g_props = {
        make_prop(-130, 0),
        make_prop(-10, 5),
        make_prop(-90, 5),
        make_prop(-30, 25),
        make_prop(-120, 30),
        make_prop(-50, 35),
    }
end

function make_prop(x,y)
    g_prop_base = 80
    return vec(x, y+g_prop_base)
end

function draw_prop(p)
    sspr_centered(164, p.x, p.y, 2, 2, prop_parallax(p))
end

function draw_main_grave(g)
    sspr_centered(206, g.x, g.y, 2, 4, prop_parallax(g) * 1.5)
end

function move_prop(p)
    p.x += 1.5 * prop_parallax(p)
    if p.x > 140 then p.x = -10 end
end

function prop_parallax(p)
    t = ((p.y - g_prop_base) / 35)
    return t * .5 + .5
end

function add_sorted(tbl, v, sort_val, on_iter)
    entry = { sort_val=sort_val, v=v, on_iter=on_iter }
    for i=1,#tbl do
        if tbl[i].sort_val > sort_val then
            add(tbl, entry, i)
            return
        end
    end
    add(tbl, entry)
end

function _update_title_screen(input)
    if g_subphase == "wait" then
        update_anim(g_player, g_anims.WalkLeft)
        if input.btn_x_change or input.btn_o_change then
            g_subphase = "dismiss"
            g_main_grave = make_prop(-10, 8)
            g_dismiss_count = 75
        end
        foreach(g_props, move_prop)
    elseif g_subphase == "dismiss" then
        update_anim(g_player, g_anims.WalkLeft)
        move_prop(g_main_grave)
        foreach(g_props, move_prop)
        g_dismiss_count -= 1
        if g_dismiss_count == 0 then
            g_subphase = "wait2"
            g_wait2_count = 60
        end
    elseif g_subphase == "wait2" then
        update_anim(g_player, g_anims.IdleUpLeft)
        g_wait2_count -= 1
        if g_wait2_count == 0 then
            g_subphase = "dig"
            g_dig_count = 36
        end
    elseif g_subphase == "dig" then
        update_anim(g_player, g_anims.DigLeft)
        g_dig_count -= 1
        if g_dig_count == 0 then
            g_subphase = "wait3"
            g_wait3_count = 90
        end
    elseif g_subphase == "wait3" then
        update_anim(g_player, g_anims.IdleUpLeft)
        g_wait3_count -= 1
        if g_wait3_count == 0 then
            sfx(Sfxs.DownStairs)
            g_subphase = "textroll"
            g_textroll_count = 90
        end
    elseif g_subphase == "textroll" then
        g_textroll_count -= 1
        if g_textroll_count == 0 then
            g_subphase = "done"
        end
    elseif g_subphase == "done" then
        set_phase(GamePhase.MainGame)
    end
end

function modify_player_palette()
    for i=1,15 do pal(i, Colors.Black) end
end

function draw_title_text(color, x, y)
    pal(Colors.Maroon, color)
    local scale = 15
    for i=0,(count(g_title)-1) do
        local t = flr(time()*30) + i*4
        local bob = sin(t%30/60) * 3
        sspr_centered(g_title[i+1], x + i*scale, y + bob, 2, 2, 1, false, false)
    end
end

function draw_player()
    modify_player_palette()
    draw_anim(g_player, sprite_pos(g_player))
    pal()
end

function _draw_title_screen()
    cls(Colors.Black)

    if g_subphase == "fade" or g_subphase == "done" then
        return
    end

    rectfill(0, 80, 128, 128, Colors.Brown)

    ysort = {}
    add_sorted(ysort, g_player, g_player.pos.y, draw_player)
    for p in all(g_props) do
        add_sorted(ysort, p, p.y, function() draw_prop(p) end)
    end
    if g_main_grave != nil then
        add_sorted(ysort, g_main_grave, g_main_grave.y, function() draw_main_grave(g_main_grave) end)
    end

    for e in all(ysort) do e.on_iter() end -- run all draw procs

    draw_title_text(Colors.Tan, 21, 31)
    draw_title_text(Colors.Maroon, 22, 32)

   print("press \151/\142 to start", 25, 60, Colors.White)
   print(g_subphase, Colors.White)
end

-- NOTE TO SELF: BROKEN NOTES
-- * when dying, some grave sprite shows as part of the flash. oops
