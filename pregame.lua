-- title screen

function _update_title_screen(input)
    if input.any_change then
        g_game_timer_ui.set_blinking(false)
        g_game_phase = GamePhase.MainGame
        music(0, 1000, 7)
    end
end

function _draw_title_screen()
    _draw_main_game() -- FIXME: tmp
end
