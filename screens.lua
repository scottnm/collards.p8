-- screens.lua - dispatch update and draw calls for each screen

GamePhase = {
    PreGame = 1,
    MainGame = 2,
    GameOver = 3,
}

draw_funcs = {
    [GamePhase.PreGame] = _draw_title_screen,
    [GamePhase.MainGame] = _draw_main_game,
    [GamePhase.GameOver] = _draw_game_over,
}

update_funcs = {
    [GamePhase.PreGame] = _update_title_screen,
    [GamePhase.MainGame] = _update_main_game,
    [GamePhase.GameOver] = _update_game_over,
}

function _draw()
    draw_funcs[g_game_phase]()
end

function _update()
    input = poll_input()
    update_funcs[g_game_phase](input)
end

