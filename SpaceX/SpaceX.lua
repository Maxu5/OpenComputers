
-- Copyright © https://github.com/Maxu5/

local screen = require("Screen")

-------------------------------------------------------------------------------------

local starAmount, colors, braille =
	200,
	{
		[0] = 0x0,
		[1] = 0x0F0F0F,
		[2] = 0x1E1E1E,
		[3] = 0x2D2D2D,
		[4] = 0x3C3C3C,
		[5] = 0x4B4B4B,
		[6] = 0x5A5A5A,
		[7] = 0x696969,
		[8] = 0x787878,
		[9] = 0x878787,
		[10] = 0x969696,
		[11] = 0xA5A5A5,
		[12] = 0xB4B4B4,
		[13] = 0xC3C3C3,
		[14] = 0xD2D2D2,
		[15] = 0xE1E1E1,
		[16] = 0xF0F0F0,
	},
	{ "⠁", "⠈", "⠂", "⠐", "⠄", "⠠", "⡀", "⢀", "⠛", "⣤" }

-- Screen resolution in pixels
local screenWidth, screenHeight = screen.getResolution()
-- Obtaining screen buffer tables for changing data ASAP
local newFrameBackgrounds, newFrameForegrounds, newFrameSymbols = screen.getNewFrameTables()
local screenTablesSize = #newFrameBackgrounds

-- Faster access without tables indexing
local computerPullSignal, tableRemove, mathSin, mathCos, mathRandom, screenDrawRectangle, screenSet, screenUpdate, screenGetIndex =
	computer.pullSignal,
	table.remove,
	math.sin,
	math.cos,
	math.random,
	screen.drawRectangle,
	screen.set,
	screen.update,
	screen.getIndex

-- Other variables, nil by default
local stars, i, star, rotationAngle, targetX, targetY, startWay, x, y, xmod, ymod, prevX, prevY, signalType, screenIndex, color = {}

-- Clearing backgrounds table once
for i = 1, screenTablesSize do
	newFrameBackgrounds[i] = 0x0
end

-- Main loop
while true do
	-- Spawing stars
	while #stars < starAmount do
		rotationAngle = mathRandom(6265) / 1000
		
		targetX, targetY, startWay =
			mathCos(rotationAngle) * screenWidth * 0.75 + screenWidth / 2,
			mathSin(rotationAngle) * screenWidth * 0.375 + screenHeight / 2,
			mathRandom()

		stars[#stars + 1] = {
			targetX = targetX,
			targetY = targetY,
			startX = (targetX - screenWidth / 2) * startWay + screenWidth / 2,
			startY = (targetY - screenHeight / 2) * startWay + screenHeight / 2,
			way = 0.01,
			speed = mathRandom(25, 75) / 1000 + 1,
		}
	end

	-- Clearing foregrounds and symbols tables
	for i = 1, screenTablesSize do
		newFrameForegrounds[i], newFrameSymbols[i] = 0x0, " "
	end

	-- Drawing stars
	i = 1
	while i <= #stars do
		star = stars[i]

		x, y =
			star.startX + (star.targetX - star.startX) * star.way,
			star.startY + (star.targetY - star.startY) * star.way

		if x > screenWidth or x < 1 or y > screenHeight or y < 1 then
			tableRemove(stars, i)
		else
			-- Star type
			xmod = x * 2
			xmod = (xmod - xmod % 1) % 2

			ymod = y * 4
			ymod = (ymod - ymod % 1) % 4

			-- Star color
			color = star.way * 4.0156862745098 * #colors

			-- Star screen position
			-- screenIndex = screenGetIndex(x - x % 1, y - y % 1)
			screenIndex = screenWidth * (y - y % 1 - 1) + x - x % 1

			newFrameForegrounds[screenIndex] = colors[color - color % 1] or 0xFFFFFF

			if star.way < 0.3 then
				if xmod == 0 then
					if ymod == 0 then
						newFrameSymbols[screenIndex] = braille[1]
					elseif ymod == 1 then
						newFrameSymbols[screenIndex] = braille[3]
					elseif ymod == 2 then
						newFrameSymbols[screenIndex] = braille[5]
					else
						newFrameSymbols[screenIndex] = braille[7]
					end
				else
					if ymod == 0 then
						newFrameSymbols[screenIndex] = braille[2]
					elseif ymod == 1 then
						newFrameSymbols[screenIndex] = braille[4]
					elseif ymod == 2 then
						newFrameSymbols[screenIndex] = braille[6]
					else
						newFrameSymbols[screenIndex] = braille[8]
					end
				end
			else
				if ymod < 2 then
					newFrameSymbols[screenIndex] = braille[9]
				else
					newFrameSymbols[screenIndex] = braille[10]
				end
			end

			i, star.way =
				i + 1,
				star.way * star.speed
		end
	end

	-- Drawing changes on monitor
	screenUpdate()

	-- Waiting for some signals
	signalType = computerPullSignal(0)
	if signalType == "touch" or signalType == "key_down" then
		break
	end
end
