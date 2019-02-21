local component = require("component")
local event = require("event")
local gpu = component.gpu
local w, h = gpu.getResolution()
local depth = gpu.getDepth()
-------------------------------------------------------------------------------------
local starAmount = 100;
local braille = {"⠁", "⠈", "⠂", "⠐", "⠄", "⠠", "⡀", "⢀", "⠛", "⣤"}
-------------------------------------------------------------------------------------
local stars = {}
local i, rotationAngle, targetX, targetY, startWay, x, y, xmod, ymod, prevX, prevY, color
-------------------------------------------------------------------------------------
local function clearScreen()
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
end
-------------------------------------------------------------------------------------
clearScreen()
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
            prevX = -1,
            prevY = -1,
            way = 0.01,
            speed = math.random(25, 75) / 1000 + 1,
        })
    end
    i = 1
    while i <= #stars do
        x = (stars[i].targetX - stars[i].startX) * stars[i].way + stars[i].startX
        y = (stars[i].targetY - stars[i].startY) * stars[i].way + stars[i].startY
        xmod = math.floor(x * 2) % 2
        ymod = math.floor(y * 4) % 4
        x = math.floor(x)
        y = math.floor(y)
        if x > w or x <= 0 or y > h or y <= 0 then
            gpu.set(stars[i].prevX, stars[i].prevY, " ")
            table.remove(stars, i)
        else
            prevX = stars[i].prevX
            prevY = stars[i].prevY
            color = math.floor(stars[i].way * 1024)
            if depth == 4 then
                if color > 63 then
                    color = 255
                end
            else
                if color > 255 then
                    color = 255
                end
            end
            gpu.setForeground(math.floor(color + color * 0x100 + color * 0x10000), false)
            if prevX ~= x or prevY ~= y then
                gpu.set(prevX, prevY, " ")
            end
            stars[i].prevX = x
            stars[i].prevY = y
            stars[i].way = stars[i].way * stars[i].speed
            if gpu.get(x, y) == " " then
                if stars[i].way < 0.3 then
                    if xmod == 0 and ymod == 0 then gpu.set(x, y, braille[1])
                        elseif xmod == 1 and ymod == 0 then gpu.set(x, y, braille[2])
                        elseif xmod == 0 and ymod == 1 then gpu.set(x, y, braille[3])
                        elseif xmod == 1 and ymod == 1 then gpu.set(x, y, braille[4])
                        elseif xmod == 0 and ymod == 2 then gpu.set(x, y, braille[5])
                        elseif xmod == 1 and ymod == 2 then gpu.set(x, y, braille[6])
                        elseif xmod == 0 and ymod == 3 then gpu.set(x, y, braille[7])
                        elseif xmod == 1 and ymod == 3 then gpu.set(x, y, braille[8])
                    end
                else
                    if ymod < 2 then
                        gpu.set(x, y, braille[9])
                    else
                        gpu.set(x, y, braille[10])
                    end
                end
            end
            i = i + 1
        end
    end
    local eventType, _, _, _ = event.pull(0)
    if eventType == "touch" or eventType == "key_down" then
        clearScreen()
        break
    end
end
-------------------------------------------------------------------------------------