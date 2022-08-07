-- title screen

function _init_title_screen()
    g_player = {
        pos = vec(64, 104),
        sprite_offset = vec(-8, -14),
    }
    update_anim(g_player, g_anims.WalkLeft)

    g_main_grave = nil
    g_title_y = 31
    g_start_prompt_y = 60
    g_title_dismiss_spd = 0.75

    local intro_text = chain_text_with_pauses({
        "the family plot...", "they're taking it.", "paving it for a new distribution center.",
        "there's something buried there...", "granddaddy left it for you.", "it's with him\nunderground",
        "good luck.", "- granny \135",
    }, 5)

    g_intro_text = split_text(intro_text)
    g_text_roll_length = #(intro_text) * 2
    g_text_roll_count = g_text_roll_length

    letters = { d = 194, i = 196, g = 198, e = 200, p = 202 }
    g_title = { letters.d, letters.i, letters.g,
                letters.d, letters.e, letters.e, letters.p }

    g_phase_timer = nil
    g_csphases = {
        { name="wait" },
        { name="dismiss_title", length=75 },
        { name="text_roll", length=g_text_roll_count },
        { name="text_roll_hold", length=60 },
        { name="grave_entrance", length=70 },
        { name="wait_at_grave", length=60, stop_moving=true, player_anim=g_anims.IdleUpLeft },
        { name="dig_at_grave", length=36, stop_moving=true, player_anim=g_anims.DigLeft },
        { name="wait_at_stairs", length=60, stop_moving=true, player_anim=g_anims.IdleUpLeft },
        { name="blackout", length=30 },
    }
    g_subphase = 1

    g_props = {
        make_prop(-130, 0),
        make_prop(-10, 5),
        make_prop(-90, 5),
        make_prop(-30, 25),
        make_prop(-120, 30),
        make_prop(-50, 35),
    }
end

g_prop_base = 80
function make_prop(x,y)
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
    local phase = g_csphases[g_subphase]
    if phase == nil then return end

    update_anim(g_player, phase.player_anim or g_anims.WalkLeft)
    if not phase.stop_moving then
        foreach(g_props, move_prop)
        if g_main_grave != nil then
            move_prop(g_main_grave)
        end
    end

    if phase.name == "dismiss_title" then
        g_title_y -= g_title_dismiss_spd
        g_start_prompt_y -= (g_title_dismiss_spd * 2)
    elseif phase.name == "text_roll" then
        g_text_roll_count -= 1
    end

    phase_over = false
    if g_phase_timer != nil then
        g_phase_timer -= 1
        phase_over = g_phase_timer == 0
    else
        phase_over = input.btn_x_change or input.btn_o_change
    end

    if phase_over then
        g_subphase += 1
        next_phase = g_csphases[g_subphase]
        if next_phase != nil then
            g_phase_timer = nil
            if next_phase.length != nil then
                g_phase_timer = next_phase.length
            else
                g_phase_timer = nil
            end

            if next_phase.name == "grave_entrance" then
                g_main_grave = make_prop(-10, 8)
            elseif next_phase.name == "blackout" then
                sfx(Sfxs.DownStairs)
            end
        else
            set_phase(GamePhase.MainGame)
        end
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

    local phase = g_csphases[g_subphase]
    if phase == nil or phase.name == "blackout" then
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
        if phase.name == "wait_at_stairs" then
            spr(104, g_main_grave.x - 10, g_main_grave.y + 8, 4, 2, true)
            rectfill(g_main_grave.x - 12, g_main_grave.y + 8, g_main_grave.x + 20, g_main_grave.y + 12, Colors.Brown)
        end
    end

    for e in all(ysort) do e.on_iter() end -- run all draw procs

    print("press \151/\142 to start", 25, g_start_prompt_y, Colors.White)
    draw_title_text(Colors.Tan, 21, g_title_y)
    draw_title_text(Colors.Maroon, 22, g_title_y + 1)

    if phase.name == "text_roll" or phase.name == "text_roll_hold" then
        local rolled_text_ratio = (g_text_roll_length - g_text_roll_count) / g_text_roll_length
        draw_text_roll(g_intro_text, rolled_text_ratio, 10, 10, nil, 6)
    end
end