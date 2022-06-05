-- pregame.lua -- logic for the titlescreen

function _update_title_screen(input)
    local any_btn = (
       input.btn_left or
       input.btn_right or
       input.btn_up or
       input.btn_down or
       input.btn_o or
       input.btn_x)

    g_game_timer_ui.update(g_maingame_tick_count)
    if any_btn then
        g_game_timer_ui.set_blinking(false)
        g_game_phase = GamePhase.MainGame
        music(0, 1000, 7)
    end
end

function _draw_title_screen()
    _draw_main_game() -- FIXME: tmp
end
