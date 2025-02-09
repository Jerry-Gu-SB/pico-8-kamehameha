pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- Ultra Instinct Theme (From "Dragon Ball Super") by Norihito Sumitomo
-- Notes taken from the MIDI transcription by Deadbeet
-- onlinesequencer.net/1993848

KAMEHAMEHA_STARTUP_FRAMES = 10
LASER_PUSHBACK = 15

MAP_X = 0
STAR_INTERVAL = 1
STAR_SWITCH = true
TWINKLE_X = 0

FIRE_INTERVAL = 1
FIRE_SPRITE_INDICES = {15,31,47,63}
FIRE_SPRITE_ARRAY = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function _init()
    objects = {}
    player = {
        x = 24,
        y = 24,
        dx = 0,
        dy = 0,
        frame = 0,
        update = update_player,
        draw = draw_player,
    }
    music(0)
end

function _update()
    update_map()
    update_player()
    update_objects()
    update_button_4()
end

function update_map()
    if MAP_X < -127 then MAP_X = 0 end
    MAP_X -= 1
    if TWINKLE_X < -127 then TWINKLE_X = 0 end
    TWINKLE_X -= .5
    
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
end

function update_objects()
    for i = #objects, 1, -1 do
        if not objects[i]:update() then
            del(objects, objects[i])
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

function update_button_4()
    if btnp(4) then
        new_kamehameha(player.x, player.y, 0, 0)
        sfx(4)
        player.frame = 1
    end
end

function _draw()
    cls()
    draw_map()
    draw_fire()
    draw_player()
    

    print("press 🅾️ to kamehamehaaaaaaaaaaaaaa", 2, 2, 7)
    
    for obj in all(objects) do
        obj:draw()
    end
end

function draw_fire()
    if FIRE_INTERVAL <= 1 then
        initialize_fire_interval()
        for i = 0, 15 do
            fire_sprite = flr(rnd(4)) + 1
            FIRE_SPRITE_ARRAY[i] = FIRE_SPRITE_INDICES[fire_sprite]
        end
    end
    for i = 0, 15 do
        spr(FIRE_SPRITE_ARRAY[i], 0, i * 8, 1, 1)
    end
    FIRE_INTERVAL -= 1
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

function initialize_star_interval()
    -- from: pico-8.fandom.com/wiki/Rnd
    STAR_INTERVAL = flr(rnd(21)) + 10
end

function initialize_fire_interval()
    FIRE_INTERVAL = flr(rnd(21)) + 10
end

__gfx__
8000000800000000000000000a0acaaaa00000000a0000000000000000000000c00a0a000a000000000aaaa0000aaa0a0000000a000077777777000099aa8000
08000080000000000000000000aaaacaaaa00000aaaaaa0000000000000000aaaaaaa0000a70000a0ccccccaccaacaa7aa000aaa00078888887770009aa80000
0080080000000000000000000acacaaaacaa00000acaaaa00000000000000acaccaaca0000a7a0a0caaccccccaac7cccc00077a000788777788777009a980000
00088000000000000000000000aaaacaaaaa0000aaaaaaaa000000000000aaac9c9aa0000000a00ccc66aacccc6cccc767caa0000788788887887770aa888000
00088000000000007777700000000aa777170006aacaacaaa00000000000cacaaa000a0600ccccc6aaaccc6ccaccaaac66666000078787777878777798898000
00800800000000007771700000006007777700660aaaaaaaa00cc0000000aaaaa00000660cccc66cccccaacc6ccccccccccccc007878878878878777aaa88000
08000080000000007777700000006607777700600c00a77170cc00000000777170000700ccccccaaaac7777777a77aaccaaaacc078787877878787779a998880
80000008000000007777700000000600070000000ccc77777cc000000000777770007700c6666cccccccc7ccaacaaaa7777ccccc787878778787877799aa9800
0000000070000000007000000000000007777700000c0070cc0000000000007000007000cccaa777caaac76ccc77cccccaaaaaaa78787877878787779a880000
00000000777700077777777700066000770000000a00007cc00000000000007777777066ccc6ccccccaa77776aaac6ccccc777cc787878778787877799a98000
000000000000777700000000000600070000660000007770000000000000007000007000cccc6cc6aaccccc6c7c7caaac77aacac78788788788787779aaa9800
000070000000070000000000000077700000066006607070000000000000007000000700cc7c7cccccccaaaaccc6cccc6cccccc007878777787877779aa99800
0000000007777000000000000007007000000066000077700c00000000000077700007000ccaacaac6ca6ccccaa7ccccccccac00078878888788777099aaa880
000000000000000000000000007000700000000000cc07770ccc00000000000077770000000a0ccacca6acccc776acacccacc00000788777788777009aa99988
00000000000000000000000000700700000000000ca07707000cccc0000000007007706607a700c0cccc6cca0ccc6ccca000a000000788888877700099a98880
0000000000000000000000000070070000000000000770077000000000000000070000060000000c0a000aa0aa000a00aaa0000a0000777777770000aaa8a800
00000000000550000006600000448880000000000044988080000000000000000000000000000000000000000000000000000000000000000000000099aaa980
000000000706607007077070044a9988880000000449a98898888000000000000000000000000000000000000000000000000000000000000000000099999800
0000000000066000007777004546aaa888000000454aaa88aaa988800000000000000000000000000000000000000000000000000000000000000000a9aaa800
00002000566776656776677645444a99998888004544aaaaa9aaaa980000000000000000000000000000000000000000000000000000000000000000aa89aa88
00000000566776656776677644544aaaaa9a998844544aa8a99a888000000000000000000000000000000000000000000000000000000000000000009aaaa880
00000000000660000077770045445a9988880000454459a9988880000000000000000000000000000000000000000000000000000000000000000000aaa99800
00000000070660700707707044644998800000004464499888800000000000000000000000000000000000000000000000000000000000000000000098899a80
00000000000550000006600004498880000000000449988000000000000000000000000000000000000000000000000000000000000000000000000099888a80
0000000000011000a011110a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaa8880
000000000a1aa1a0011aa11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099a99980
0000000001aaaa1011aaaa110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aaaaaa8
0000d0001aaaaaa11aaaaaa10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aa88880
000000001aaaaaa11aaaaaa100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099889988
0000000001aaaa1011aaaa110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aaaa980
000000000a1aa1a0011aa1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009aa98888
0000000000011000a011110a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa88000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000021000000000000000000000000000000220000002000001000200000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000010000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000021000000310000000000000000000000220000003200000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000002c00000000000000000000000000001000002000300000100000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000220000000000000000000000000000002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000010000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000200000000000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000031000000000000000000000000000000322c00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000003000100010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000002200000000000000000000000000000021000000000010000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000010003000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0031000000000000000000000000000000322c00000000000000000000000000000000200000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002100000000000000000000000000000022000000000000000000001000000030000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000038000000000000000000000000000000000000000000000000000000100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000384003640035400334002e4002d4002c4002c4002b4002a4002a400000000000030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a250212000050000500005390550000537055000053a0550000539055000053705500005350550000534055000053505500005000050000500005000050000500005000052e0050000500005000050000500005
002502120000000000000000d050000000d050000000d050000000d050000000e050000000e050000000e050000000e0500000000000000000000000000000000000000000000000000000000000000000000000
002502120000000000000001505000000150500000015050000001505000000150500000015050000001505000000150500000000000000000000000000000000000000000000000000000000000000000000000
8e05000000401014510245104451084510a4410d4410f4410f4413e4413a4313743134421314112e4112b4512945127451234511f4511b4511745113451054510845102451054510040100401004010040100401
__music__
02 01020344
00 44424344

