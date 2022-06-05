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

    g_title = {
        g_title_letters.d,
        g_title_letters.i,
        g_title_letters.g,
        g_title_letters.d,
        g_title_letters.e,
        g_title_letters.e,
        g_title_letters.p,
    }

    g_letter_motion = 0
end

function _update_title_screen(input)
    update_anim(g_player, g_anims.WalkLeft)
    if input.any_change then
        set_phase(GamePhase.MainGame)
    end
    g_letter_motion += 1
end

function modify_player_palette()
    for i=1,15 do pal(i, Colors.Black) end
end

function draw_title_text(color, x, y)
    pal(Colors.Maroon, color)
    local scale = 15
    for i=0,(count(g_title)-1) do
        local letter_motion = g_letter_motion + i*4
        local bob = sin(letter_motion%30/60) * 3
        printh(letter_motion.." "..bob)
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
end
