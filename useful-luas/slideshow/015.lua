-- Slide 15: The End

clear(colors.black)

local W, H = mon.getSize()
local midY = math.floor(H / 2)

-- Decorative top border
local border = string.rep("\x8c", W - 4)
text(3, midY - 8, border, colors.purple)
text(3, midY + 8, border, colors.purple)

-- Title
center(midY - 5, "WORKSHOP COMPLETE!", colors.lime)
center(midY - 3, "BINSEC Workshop #1", colors.yellow)
center(midY - 2, "Cybersecurity Basics with Lua in CC:T", colors.lightBlue)

-- Divider
hline(midY, 10, W - 10, colors.gray)

-- Recap
center(midY + 2, "What you learned:", colors.white)
center(midY + 3, "CraftOS  |  Lua  |  FS  |  Peripherals  |  Redstone", colors.cyan)
center(midY + 4, "Networking  |  Scanning  |  Sniffing  |  Brute-Force", colors.cyan)
center(midY + 5, "Remote Control  |  Defense Strategies", colors.cyan)

-- Footer
center(midY + 7, "Thanks for attending!", colors.orange)

-- Sparkle animation corners
for _, pos in ipairs({{2,2},{W-1,2},{2,H-1},{W-1,H-1}}) do
  text(pos[1], pos[2], "*", colors.yellow)
end
