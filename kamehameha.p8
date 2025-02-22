pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- Ultra Instinct Theme (From "Dragon Ball Super") by Norihito Sumitomo
-- Notes taken from the MIDI transcription by Deadbeet
-- onlinesequencer.net/1993848

-- meteor flag: 1
-- kamehameha flag: 2
-- shield flag: 3
-- player flag: 4

--to do: 
    -- laser logic
    -- shield hit sfx
    -- player hit sfx
    -- meteor getting lasered sfx
    -- game over sfx

    -- game start screen?
    -- maybe redo stars to be less bright

function _init()
    KAMEHAMEHA_STARTUP_FRAMES = 10
    LASER_PUSHBACK = 15

    MAP_X = 0
    STAR_INTERVAL = -1
    STAR_SWITCH = true
    TWINKLE_X = 0

    SHIELD_INTERVAL = -1
    SHIELD_SPRITE_INDICES = {15,31,47,63}
    SHIELD_SPRITE_ARRAY = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    METEOR_SPAWN_INTERVAL = -1

    SHIELD_HIT = false
    PLAYER_HIT = false

    EXPLOSION_X = 0
    EXPLOSION_Y = 0
    EXPLOSION_FRAME = 0

    objects = {}
    player = {
        x = 24,
        y = 24,
        dx = 0,
        dy = 0,
        frame = 0,
        update = update_player,
        draw = draw_player,
        health = 1,
    }

    music(0)
end

function _update()
    check_game_state()
    update_map()
    update_player()
    update_objects()
    update_button_4()
    spawn_meteor()
end

function check_game_state()
    if SHIELD_HIT or PLAYER_HIT then
        if btnp(5) then
            SHIELD_HIT = false
            PLAYER_HIT = false
            _init()
        end
    end
end

function update_map()
    if MAP_X < -127 then MAP_X = 0 end
    MAP_X -= .3
    if TWINKLE_X < -127 then TWINKLE_X = 0 end
    TWINKLE_X -= .1
    
    if STAR_INTERVAL <= 1 then
        initialize_star_interval()
        STAR_SWITCH = not STAR_SWITCH
    end
end

function update_player()
    if player.frame > 0 then player.frame += 1 end
    if player.frame > 20 then player.frame = 0 end

    if player.x < 0 then player.x = 0 end
    if player.x > 115 then player.x = 115 end
    if player.y < 0 then player.y = 0 end
    if player.y > 108 then player.y = 108 end

    if btn(⬅️) then player.dx -= 1 end
    if btn(➡️) then player.dx += 1 end
    if btn(⬆️) then player.dy -= 1 end
    if btn(⬇️) then player.dy += 1 end

    player.x += player.dx
    player.y += player.dy

    player.dx *= 0.7
    player.dy *= 0.7

    if player.x < 5 then
        PLAYER_HIT = true
        SHIELD_HIT = true
        for i = 0, 15 do
            new_game_end_explosion(3, i * 8, 0, 0)
        end
    end
    --- Prevents player from moving after death
    if PLAYER_HIT then
        player.x = 1000
        player.y = 1000
    end
end

--- Object management system from: https://www.lexaloffle.com/bbs/?tid=44686
function update_objects()
    for i = #objects, 1, -1 do
        if not objects[i]:update() then
            del(objects, objects[i])
        else
            objects[i].x += objects[i].dx
            objects[i].y += objects[i].dy
        end
    end
end

function update_kamehameha(k)
    k.frame += 1
    if k.frame == KAMEHAMEHA_STARTUP_FRAMES then
        k.x = player.x + 10
        k.y = player.y

        player.dx -= LASER_PUSHBACK
    end
    return k.frame < 50
end

function update_meteor(m)
    m.frame += 1

    if m.x == 0 and not SHIELD_HIT then
        new_game_end_explosion(m.x, m.y, 0, 0)
        for i = 0, 15 do
            new_game_end_explosion(3, i * 8, 0, 0)
        end
        --- make meteor "disappear" after explosion
        m.x = 1000
        m.y = 1000

        SHIELD_HIT = true
    end

    if (player.x + 3 <= m.x) and (m.x <= player.x + 13) and (player.y <= m.y) and (m.y <= player.y + 11) then
        new_game_end_explosion(player.x, player.y, 0, 0)
        PLAYER_HIT = true
    end

    return m.frame < 150
end

function update_game_end_explosion(e)
    e.frame += 1
    return e.frame < 35
end

function update_button_4()
    if btnp(4) then
        new_kamehameha(player.x, player.y, 0, 0)
        sfx(4)
        player.frame = 1
    end
end

function spawn_meteor()
    if METEOR_SPAWN_INTERVAL <= 1 then
        initialize_meteor_spawn_interval()
        new_meteor(128, flr(rnd(120)), -5, 0)
    end
    METEOR_SPAWN_INTERVAL -= 1
end

function _draw()
    cls()
    draw_map()
    draw_player()
    draw_objects()
    draw_shield()
    draw_ui()
end

function draw_map()
    map(32, 0, TWINKLE_X, 0, 16, 16)
    map(32, 0, TWINKLE_X + 128, 0, 16, 16)

    if STAR_SWITCH then
        map(0, 0, MAP_X, 0, 16, 16)
        map(0, 0, MAP_X + 128, 0, 16, 16)
    else
        map(16, 0, MAP_X, 0, 16, 16)
        map(16, 0, MAP_X + 128, 0, 16, 16)
    end
    STAR_INTERVAL -= 1
end

function draw_player()
    if PLAYER_HIT then
        return
    end
    
    if 1 < player.frame and player.frame <= 4 then
        spr(3, player.x, player.y, 2, 2)
    elseif 4 < player.frame and player.frame <= 8 then
        spr(5, player.x, player.y, 2, 2)
    elseif 8 < player.frame and player.frame <= 20 then
        spr(7, player.x, player.y, 2, 2)
    else
        spr(1, player.x, player.y, 2, 2)
    end
end

function draw_objects()
    for obj in all(objects) do
        obj:draw()
    end
end

function draw_shield()
    if SHIELD_HIT then
        return
    end

    if SHIELD_INTERVAL <= 1 then
        initialize_shield_interval()
        for i = 0, 15 do
            fire_sprite = flr(rnd(4)) + 1
            SHIELD_SPRITE_ARRAY[i] = SHIELD_SPRITE_INDICES[fire_sprite]
        end
    end

    for i = 0, 15 do
        spr(SHIELD_SPRITE_ARRAY[i], 0, i * 8, 1, 1)
    end

    SHIELD_INTERVAL -= 1
end

function draw_ui()
    print("press 🅾️ to kamehamehaaaaaaaaaaaaaa", 10, 2, 7)

    if SHIELD_HIT or PLAYER_HIT then
        print("game over", 40, 64, 7)
        print("press 🅾️ to try again", 32, 72, 7)
    end
end

--- OBJECTS
function draw_kamehameha(k)
    laser_gap = 8 -- can be a max of 8
    frame_gap = 1

    if k.frame > KAMEHAMEHA_STARTUP_FRAMES then
        spr(9, k.x, k.y, 2, 2)
    end

    for i = 1, 4 do
        if k.frame > (i + 1) * frame_gap + KAMEHAMEHA_STARTUP_FRAMES then
            spr(11, k.x + i * laser_gap, k.y, 1, 2)
        end
    end
    
    if k.frame > 5 * frame_gap  + KAMEHAMEHA_STARTUP_FRAMES then
        spr(12, k.x + 5 * laser_gap, k.y, 1, 2)
    end
end

function draw_meteor(m)
    if m.frame % 5 == 0 then
        m.draw_flag = not m.draw_flag
    end

    if m.frame > 0 and m.draw_flag then
        spr(35, m.x, m.y, 2, 1)
    elseif m.frame > 0 and not m.draw_flag then
        spr(37, m.x, m.y, 2, 1)
    end
end

function draw_game_end_explosion(e)
    if 1 < e.frame and e.frame <= 5 then
        spr(65, e.x, e.y, 2, 2)
    elseif 5 < e.frame and e.frame <= 10 then
        spr(67, e.x, e.y, 2, 2)
    elseif 10 < e.frame and e.frame <= 15 then
        spr(69, e.x, e.y, 2, 2)
    elseif 15 < e.frame and e.frame <= 20 then
        spr(73, e.x, e.y, 2, 2)
    elseif 20 < e.frame and e.frame <= 25 then            
        spr(75, e.x, e.y, 2, 2)
    elseif 25 < e.frame and e.frame <= 30 then
        spr(77, e.x, e.y, 2, 2)
    end
end

--- OBJECT INSTANTIATION
function new_meteor(start_x, start_y, dx, dy)
    local m = {
        x = start_x,
        y = start_y,
        dx = -1,
        dy = 0,
        frame = 0,
        update = update_meteor,
        draw = draw_meteor,
    }
    add(objects, m)
end

function new_kamehameha(start_x, start_y, dx, dy)
    local k = {
        x = start_x,
        y = start_y,
        dx = 0,
        dy = 0,
        frame = 0,
        update = update_kamehameha,
        draw = draw_kamehameha,
    }
    add(objects, k)
end  

function new_game_end_explosion(start_x, start_y, dx, dy)
    local e = {
        x = start_x,
        y = start_y,
        dx = dx,
        dy = dy,
        frame = 0,
        update = update_game_end_explosion,
        draw = draw_game_end_explosion,
    }
    add(objects, e)
end

--- RANDOM NUMBER GENERATION
function initialize_star_interval()
    -- from: pico-8.fandom.com/wiki/Rnd
    STAR_INTERVAL = flr(rnd(21)) + 10
end

function initialize_shield_interval()
    SHIELD_INTERVAL = flr(rnd(21)) + 10
end

function initialize_meteor_spawn_interval()
    METEOR_SPAWN_INTERVAL = flr(rnd(30)) + 20
end


__gfx__
8000000800000000000000000a0acaaaa00000000a0000000000000000000000c00a0a000a000000000aaaa0000aaa0a0000000a0000000000000000c7771100
08000080000000000000000000aaaacaaaa00000aaaaaa0000000000000000aaaaaaa0000a70000a0ccccccaccaacaa7aa000aaa0000000000000000c7ccc110
0080080000000000000000000acacaaaacaa00000acaaaa00000000000000acaccaaca0000a7a0a0caaccccccaac7cccc00077a00000000000000000c1ccc110
00088000000000000000000000aaaacaaaaa0000aaaaaaaa000000000000aaac9c9aa0000000a00ccc66aacccc6cccc767caa00000000000000000007cccc110
00088000000000007777700000000aa777170006aacaacaaa00000000000cacaaa000a0600ccccc6aaaccc6ccaccaaac666660000000000000000000c7ccc100
00800800000000007771700000006007777700660aaaaaaaa00cc0000000aaaaa00000660cccc66cccccaacc6ccccccccccccc000000000000000000ccccc100
08000080000000007777700000006607777700600c00a77170cc00000000777170000700ccccccaaaac7777777a77aaccaaaacc00000000000000000cccc1100
80000008000000007777700000000600070000000ccc77777cc000000000777770007700c6666cccccccc7ccaacaaaa7777ccccc0000000000000000ccccc100
0000000070000000007000000000000007777700000c0070cc0000000000007000007000cccaa777caaac76ccc77cccccaaaaaaa000000000000000071c7c100
00000000777700077777777700066000770000000a00007cc00000000000007777777066ccc6ccccccaa77776aaac6ccccc777cc000000000000000077c7c100
000000000000777700000000000600070000660000007770000000000000007000007000cccc6cc6aaccccc6c7c7caaac77aacac0000000000000000ccc7c110
000070000000070000000000000077700000066006607070000000000000007000000700cc7c7cccccccaaaaccc6cccc6cccccc00000000000000000ccc7cc10
0000000007777000000000000007007000000066000077700c00000000000077700007000ccaacaac6ca6ccccaa7ccccccccac000000000000000000ccc1cc10
000000000000000000000000007000700000000000cc07770ccc00000000000077770000000a0ccacca6acccc776acacccacc0000000000000000000ccc71c10
00000000000000000000000000700700000000000ca07707000cccc0000000007007706607a700c0cccc6cca0ccc6ccca000a0000000000000000000cc1c1710
0000000000000000000000000070070000000000000770077000000000000000070000060000000c0a000aa0aa000a00aaa0000a0000000000000000cccc1c11
000000000005500000066000004488800000000000449880800000000000000000000000000000000000000000888800888080000000000000000000ccc1c7c1
000000000706607007077070044a9988880000000449a98898888000000000000000000000000000000000000888a88888a88088000000000000000071c1cc71
0000000000066000007777004546aaa888000000454aaa88aaa988800000000000000000000080888880800008a98a889898988000000000000000001cc1ccc1
00002000566776656776677645444a99998888004544aaaaa9aaaa9800000088000800000008889a9998800088899aa9999988a80000000000000000ccc1ccc1
00000000566776656776677644544aaaaa9a998844544aa8a99a888000000898888800000088aa9aaa980800099aa9aaaa999a98000000000000000011c17cc1
00000000000660000077770045445a9988880000454459a9988880000000089a8999800008889aa9a99a9800098899aaaa9aaa80000000000000000077c11c10
00000000070660700707707044644998800000004464499888800000000088aa9aa98000000899aaaaaa880088999aaaaa9aa88000000000000000007c1ccc10
00000000000550000006600004498880000000000449988000000000000899aaaa98000000899aaaaaaaa000899a88aaaa9a89880000000000000000711ccc10
0000000000011000a011110a000000000000000000000000000000000008aaaaaaa800000089999a9a999888a9aa8aaaaaaa999800000000000000001c7c1c10
000000000a1aa1a0011aa11000000000000000000000000000000000000089aaaa9800000088aaaaaaaaa8000aa8aaa9aaaa99880000000000000000cc1ccc10
0000000001aaaa1011aaaa11000000000000000000000000000000000008a99aaa980000088889aa9aaa88000889aaaaaaa998800000000000000000c111c110
0000d0001aaaaaa11aaaaaa1000000000000000000000000000000000008889a9a88000008889aaaaaa98000089999aaa9998000000000000000000071ccc710
000000001aaaaaa11aaaaaa100000000000000000000000000000000000008899888000000099999a9a800000899889aaaaa988000000000000000001cc1c110
0000000001aaaa1011aaaa11000000000000000000000000000000000000088888000000000888898808000008898a98898880080000000000000000ccccc100
000000000a1aa1a0011aa110000000000000000000000000000000000000008000000000000000000000000008a88880888a80000000000000000000ccccc100
0000000000011000a011110a0000000000000000000000000000000000000000000000000000000000000000008800a09008000000000000000000001cccc110
0000000000000000000000000000000000000000000000770070000000000000aa0000000000c000000000000000000000000000000000000000000000000000
00000000000000000000000000007700070000000c007c0700700cc0cc777000a00c07000c00000000c0c0c00000000000000000000000000000000000000000
0000000000000000000000000007c00007c0000007c0780088888c0000cc7888888c7c0000000000c000000c0000000000000000000000000000000000000000
000000000000000cc00000000007c00087800000007c088c8a999c80c00898899880770a00c000888800c0c00000000700000000000000000000000000000000
00000000000cc770c000000000008cc88cc8000000c8888cc999cc800c88a99a880cc0aa00c00899a800000000000c070c000000000700007c00000000000000
0000000000cc00888877000000089a9999aa77000089c999aaacc8008899aa9aaa8800c0000088a9a98880000070000700c0070000000000c000000000000000
00000000000088999870c000000899a9aaa800000889aa9aaacc800089999aaa9a998c77000889aa99a988000000088899000700000000000000077c00000000
0000000000cc8aaaa80cc000000899aaa9988000089caa99aa9a8007088a9a999a9a880a0008aaaa9aaaa8000c00709aaa90c000000000000000000000000000
0000000000c8a9a9980c00000cc89aaaaa99800088c7caaaaaaaacc0a0aa9a99aaa9880a000899aaaaaaa80000000089899000000c770000a000000000000000
000000000008a88988000000007caa9a9aacc0008877ccaaaaaacc80cc899aa9aa9980c000089aaa99a99800000000009a000770000000000000000000000000
000000000770888c8077000000089a99998ac000088aaaaa9aca9a8007899a999aaa88c00008889899a98800000000000000c0000000000000007c0000000000
000000000000000cc0000000000899988887770000899aaaaa779a80778aaa9aaaaa99880000088888aa8000000c0700707000000000007000000cc000000000
00000000000c007000000000000888cc00000000008888aa99c87800c08aa8a99aaa988000000000008000000000070c00770000000c7c000000000000000000
00000000000c007700000000000077c0000000000cc00c889988888000c888888998880000c0cc000000cc000000000000000000000000000000000000000000
00000000000000000000000000007000000700000700cc0088808cc00cc0c7cc88c80c7a00c0000000000cc00000000000000000000000000007000000000000
0000000000000000000000000000000000000000c0000000000000000c0000a000c770c00c00000000000000000000000000000000000000000cc00000000000
__gff__
0008080808080808080202020200000400080808080808080802020202000004000000010001000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000021000000000000000000000000000000220000002000001000200000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000010000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000021000000310000000000000000000000220000003200000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001000002000300000100000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000220000000000000000000000000000002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000010000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000200000000000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000031000000000000000000000000000000320000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000003000100010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000002200000000000000000000000000000021000000000010000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000010003000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0031000000000000000000000000000000320000000000000000000000000000000000200000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002100000000000000000000000000000022000000000000000000001000000030000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000384003640035400334002e4002d4002c4002c4002b4002a4002a400000000000030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a250212000050000500005390550000537055000053a0550000539055000053705500005350550000534055000053505500005000050000500005000050000500005000052e0050000500005000050000500005
002502120000000000000000d050000000d050000000d050000000d050000000e050000000e050000000e050000000e0500000000000000000000000000000000000000000000000000000000000000000000000
002502120000000000000001505000000150500000015050000001505000000150500000015050000001505000000150500000000000000000000000000000000000000000000000000000000000000000000000
8e05000000401014510245104451084510a4410d4410f4410f4413e4413a4313743134421314112e4112b4512945127451234511f4511b4511745113451054510845102451054510040100401004010040100401
__music__
02 01020344
00 44424344

