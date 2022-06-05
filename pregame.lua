-- title screen

function _init_title_screen()
    g_player = {
        pos = vec(64, 104),
        sprite_offset = vec(-8, -14),
    }

    g_letters = { d = 194, i = 196, g = 198, e = 200, p = 202 }

    g_title = { g_letters.d, g_letters.i, g_letters.g,
                g_letters.d, g_letters.e, g_letters.e, g_letters.p }

end

function _update_title_screen(input)
    update_anim(g_player, g_anims.WalkLeft)
    if input.btn_x_change or input.btn_o_change then
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

function _draw_title_screen()
    cls(Colors.Black)
    rectfill(0, 80, 128, 128, Colors.Brown)

    modify_player_palette()
    draw_anim(g_player, sprite_pos(g_player))
    pal()

    draw_title_text(Colors.Tan, 21, 31)
    draw_title_text(Colors.Maroon, 22, 32)

   print("press \151/\142 to start", 25, 60, Colors.White)
end