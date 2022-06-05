-- title screen

function _init_title_screen()
    g_player = {
        pos = vec(64, 104),
        sprite_offset = vec(-8, -14),
    }

    g_title_letters = {
        d = 194,
        i = 196,
        g = 198,
        e = 200,
        p = 202 }
end

function _update_title_screen(input)
    update_anim(g_player, g_anims.WalkLeft)
    if input.any_change then
        set_phase(GamePhase.MainGame)
    end
end

function modify_player_palette()
    for i=1,15 do pal(i, Colors.Black) end
end

function draw_title_text(color, x_ofs, y_ofs)
    pal(Colors.Maroon, color)
    local scale = 15
    sspr_centered(g_title_letters.d, x_ofs + 0*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.i, x_ofs + 1*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.g, x_ofs + 2*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.d, x_ofs + 3*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.e, x_ofs + 4*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.e, x_ofs + 5*scale, y_ofs, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.p, x_ofs + 6*scale, y_ofs, 2, 2, 1, false, false)
end

function _draw_title_screen()
    cls(Colors.Black)
    rectfill(0, 80, 128, 128, Colors.Brown)

    modify_player_palette()
    draw_anim(g_player, sprite_pos(g_player))
    pal()

    draw_title_text(Colors.Tan, 9, 9)
    draw_title_text(Colors.Maroon, 10, 10)
end
