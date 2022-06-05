-- title screen

function _init_title_screen()
    g_player = {
        pos = vec(64, 64),
        sprite_offset = vec(-8, -14),
    }
end

function _update_title_screen(input)
    update_anim(g_player, g_anims.WalkLeft)
    if input.any_change then
        set_phase(GamePhase.MainGame)
    end
end

function _draw_title_screen()
    cls(Colors.Black)
    draw_anim(g_player, sprite_pos(g_player))
end
