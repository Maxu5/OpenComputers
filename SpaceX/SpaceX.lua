local event = require("Event")
local screen = require("Screen")

local w, h = screen.getResolution()
-------------------------------------------------------------------------------------
local starAmount = 100;
local braille = {"⠁", "⠈", "⠂", "⠐", "⠄", "⠠", "⡀", "⢀", "⠛", "⣤"}
-------------------------------------------------------------------------------------
local stars, i, rotationAngle, targetX, targetY, startWay, x, y, xmod, ymod, prevX, prevY, color, signalType = {}
-------------------------------------------------------------------------------------
while true do
    while #stars < starAmount do
        rotationAngle = math.random(6265) / 1000
        targetX = math.ceil(math.cos(rotationAngle) * w * 0.75 + w / 2)
        targetY = math.ceil(math.sin(rotationAngle) * w * 0.375 + h / 2)
        startWay = math.random()
        table.insert(stars, {
            targetX = targetX,
            targetY = targetY,
            startX = math.ceil((targetX - w / 2) * startWay + w / 2),
            startY = math.ceil((targetY - h / 2) * startWay + h / 2),
            way = 0.01,
            speed = math.random(25, 75) / 1000 + 1,
        })
    end

    screen.clear(0x0)

    i = 1
    while i <= #stars do
        x = (stars[i].targetX - stars[i].startX) * stars[i].way + stars[i].startX
        y = (stars[i].targetY - stars[i].startY) * stars[i].way + stars[i].startY
        xmod = math.floor(x * 2) % 2
        ymod = math.floor(y * 4) % 4
        x = math.floor(x)
        y = math.floor(y)

        if x > w or x <= 0 or y > h or y <= 0 then
            table.remove(stars, i)
        else
            color = math.floor(stars[i].way * 1024)
            if color > 255 then
                color = 255
            end
            color = color + color * 0x100 + color * 0x10000

            stars[i].way = stars[i].way * stars[i].speed
            
            if select(3, screen.get(x, y)) == " " then
                if stars[i].way < 0.3 then
                    if xmod == 0 and ymod == 0 then screen.set(x, y, 0x0, color, braille[1])
                        elseif xmod == 1 and ymod == 0 then screen.set(x, y, 0x0, color, braille[2])
                        elseif xmod == 0 and ymod == 1 then screen.set(x, y, 0x0, color, braille[3])
                        elseif xmod == 1 and ymod == 1 then screen.set(x, y, 0x0, color, braille[4])
                        elseif xmod == 0 and ymod == 2 then screen.set(x, y, 0x0, color, braille[5])
                        elseif xmod == 1 and ymod == 2 then screen.set(x, y, 0x0, color, braille[6])
                        elseif xmod == 0 and ymod == 3 then screen.set(x, y, 0x0, color, braille[7])
                        elseif xmod == 1 and ymod == 3 then screen.set(x, y, 0x0, color, braille[8])
                    end
                else
                    if ymod < 2 then
                        screen.set(x, y, 0x0, color, braille[9])
                    else
                        screen.set(x, y, 0x0, color, braille[10])
                    end
                end
            end

            i = i + 1
        end
    end

    screen.update()

    signalType = computer.pullSignal(0)
    if signalType == "touch" or signalType == "key_down" then
        break
    end
end
