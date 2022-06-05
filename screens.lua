-- dispatch

GamePhase = {
    PreGame = 1,
    MainGame = 2,
    GameOver = 3,
}

function _init()
    _init_animations()
    set_phase(GamePhase.PreGame)
end

function _draw()
    if g_game_phase == GamePhase.PreGame then
        _draw_title_screen()
    elseif g_game_phase == GamePhase.MainGame then
        _draw_main_game()
    elseif g_game_phase == GamePhase.GameOver then
        _draw_game_over()
    end
end

function _update()
    input = poll_input()
    if g_game_phase == GamePhase.PreGame then
        _update_title_screen(input)
    elseif g_game_phase == GamePhase.MainGame then
        _update_main_game(input)
    elseif g_game_phase == GamePhase.GameOver then
        _update_game_over(input)
    end
end

function set_phase(p)
    if p == GamePhase.PreGame then
        _init_title_screen()
    elseif p == GamePhase.MainGame then
        _init_main_game()
    elseif p == GamePhase.GameOver then
        _init_game_over()
    end
    g_game_phase = p
end
