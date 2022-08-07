-- dbg helpers

-- e.g. dbg_display_frame_stats({ x = 80, y = 80 })
function dbg_display_frame_stats(pos)
    print("mem:  "..  stat(0), pos.x, pos.y + 00, Colors.White)
    print("cpu:  "..  stat(1), pos.x, pos.y + 10, Colors.White)
    print("fps(t): "..stat(8), pos.x, pos.y + 20, Colors.White)
    print("fps(a): "..stat(7), pos.x, pos.y + 30, Colors.White)
end

-- e.g. dbg_display_colliders(g_player, g_map, g_bombs)
function dbg_display_colliders(player, map, bombs)
    circ(player.pos.x, player.pos.y, player.collider.radius, Colors.White)
    for cell in all(map.cells) do
        circ(cell.pos.x, cell.pos.y, cell.collider.radius, Colors.White)
    end
    for bomb in all(bombs) do
        for e in all(bomb.get_explosions()) do
            circ(e.pos.x, e.pos.y, e.collider.radius, Colors.White)
        end
    end
end

-- e.g. dbg_display_anim_state(g_player, { x = 0, y = 60 }, g_anims)
function dbg_display_anim_state(obj, pos, anims)
    local anim_state = obj.anim_state
    local flip = ""
    if anim_state.flip then
        flip = "true"
    else
        flip = "false"
    end

    local anim_name = ""
    for k,v in pairs(anims) do
        if v == anim_state.last_anim then
            anim_name = k
            break
        end
    end

    print("a_ct: "..     anim_state.a_ct, pos.x, pos.y + 00, Colors.White)
    print("a_st: "..     anim_state.a_st, pos.x, pos.y + 10, Colors.White)
    print("a_fr: "..     anim_state.a_fr, pos.x, pos.y + 20, Colors.White)
    print("flip: "..                flip, pos.x, pos.y + 30, Colors.White)
    print("ts:   "..anim_state.tile_size, pos.x, pos.y + 40, Colors.White)
    print("last: "..           anim_name, pos.x, pos.y + 50, Colors.White)
end

-- e.g.
--   dbg_set_tiles_visible(maps, nil)
--   dbg_set_tiles_visible(maps, { TileType.PageItem, TileType.FloorExit })
function dbg_set_tiles_visible(maps, tile_types)
    for map in all(maps) do
        for cell in all(map.cells) do
            local tile = cell.tile
            if tile_types == nil then
                tile.visible = true
            else
                for tt in all(tile_type) do
                    if tile.type == tt then
                        tile.visible = true
                        break
                    end
                end
            end
        end
    end
end
