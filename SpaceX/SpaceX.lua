local event = require("Event")
local screen = require("Screen")

local w, h = screen.getResolution()
-------------------------------------------------------------------------------------
local starAmount = 100;
local braille = {"⠁", "⠈", "⠂", "⠐", "⠄", "⠠", "⡀", "⢀", "⠛", "⣤"}
-------------------------------------------------------------------------------------
local stars, computerPullSignal, tableInsert, tableRemove, mathSin, mathCos, mathFloor, mathCeil, mathRandom, screenClear, screenSet, screenGet, screenUpdate, i, star, rotationAngle, targetX, targetY, startWay, x, y, xmod, ymod, prevX, prevY, color, signalType, _, symbol =
    {},
    computer.pullSignal,
    table.insert,
    table.remove,
    math.sin,
    math.cos,
    math.floor,
    math.ceil,
    math.random,
    screen.clear,
    screen.set,
    screen.get,
    screen.update
-------------------------------------------------------------------------------------
while true do
    while #stars < starAmount do
        rotationAngle = mathRandom(6265) / 1000
        targetX = mathCeil(mathCos(rotationAngle) * w * 0.75 + w / 2)
        targetY = mathCeil(mathSin(rotationAngle) * w * 0.375 + h / 2)
        startWay = mathRandom()
        tableInsert(stars, {
            targetX = targetX,
            targetY = targetY,
            startX = mathCeil((targetX - w / 2) * startWay + w / 2),
            startY = mathCeil((targetY - h / 2) * startWay + h / 2),
            way = 0.01,
            speed = mathRandom(25, 75) / 1000 + 1,
        })
    end

    screenClear(0x0)

    i = 1
    while i <= #stars do
        star = stars[i]

        x = (star.targetX - star.startX) * star.way + star.startX
        y = (star.targetY - star.startY) * star.way + star.startY
        xmod = mathFloor(x * 2) % 2
        ymod = mathFloor(y * 4) % 4
        x = mathFloor(x)
        y = mathFloor(y)

        if x > w or x <= 0 or y > h or y <= 0 then
            tableRemove(stars, i)
        else
            color = mathFloor(star.way * 1024)
            if color > 255 then
                color = 255
            end
            color = color + color * 0x100 + color * 0x10000

            star.way = star.way * star.speed
            
            _, _, symbol = screenGet(x, y)
            if symbol == " " then
                if star.way < 0.3 then
                    if xmod == 0 and ymod == 0 then screenSet(x, y, 0x0, color, braille[1])
                        elseif xmod == 1 and ymod == 0 then screenSet(x, y, 0x0, color, braille[2])
                        elseif xmod == 0 and ymod == 1 then screenSet(x, y, 0x0, color, braille[3])
                        elseif xmod == 1 and ymod == 1 then screenSet(x, y, 0x0, color, braille[4])
                        elseif xmod == 0 and ymod == 2 then screenSet(x, y, 0x0, color, braille[5])
                        elseif xmod == 1 and ymod == 2 then screenSet(x, y, 0x0, color, braille[6])
                        elseif xmod == 0 and ymod == 3 then screenSet(x, y, 0x0, color, braille[7])
                        elseif xmod == 1 and ymod == 3 then screenSet(x, y, 0x0, color, braille[8])
                    end
                else
                    if ymod < 2 then
                        screenSet(x, y, 0x0, color, braille[9])
                    else
                        screenSet(x, y, 0x0, color, braille[10])
                    end
                end
            end

            i = i + 1
        end
    end

    screenUpdate()

    signalType = computerPullSignal(0)
    if signalType == "touch" or signalType == "key_down" then
        break
    end
end
