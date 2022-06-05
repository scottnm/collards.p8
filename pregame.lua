-- title screen

function _init_title_screen()
    --noop
end

function _update_title_screen(input)
    --update_anim(g_player
    if input.any_change then
        set_phase(GamePhase.MainGame)
    end
end

function _draw_title_screen()
    -- _draw_main_game() -- FIXME: tmp
    cls(Colors.Black)
end
