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

function _draw_title_screen()
    cls(Colors.Black)
    rectfill(0, 80, 128, 128, Colors.Brown)

    modify_player_palette()
    draw_anim(g_player, sprite_pos(g_player))
    pal()

    local scale = 15
    sspr_centered(g_title_letters.d, 10 + 0*scale,  10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.i, 10 + 1*scale,  10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.g, 10 + 2*scale,  10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.d, 10 + 3*scale,  10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.e, 10 + 4*scale,  10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.e, 10 + 5*scale, 10, 2, 2, 1, false, false)
    sspr_centered(g_title_letters.p, 10 + 6*scale, 10, 2, 2, 1, false, false)

end
