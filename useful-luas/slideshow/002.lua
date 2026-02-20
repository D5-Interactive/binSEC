-- Slide 2: What is CC:Tweaked?

clear(colors.black)
header("What is CC:Tweaked?", colors.white, colors.blue)

local y = 4
y = y + bullet(y, "Minecraft mod: programmable Lua computers, turtles, pocket PCs", colors.cyan) + 1
y = y + bullet(y, "Fork of ComputerCraft, actively maintained for modern MC", colors.cyan) + 1
y = y + bullet(y, "Runs real Lua 5.2 code inside the game world", colors.lime) + 1
y = y + bullet(y, "Advanced Computers get color monitors and full event API", colors.lime) + 1
y = y + bullet(y, "Turtles: mobile robots that mine, build, farm, and attack", colors.yellow) + 1
y = y + bullet(y, "Pocket Computers: portable, player-carried terminals", colors.yellow) + 1

y = y + 1
text(3, y, "Why cybersec?", colors.orange) y = y + 1
wrap(5, y, "CC:T gives you networking, filesystems, HTTP, peripherals, and scriptable hardware. Perfect sandbox for learning offensive and defensive security.", W - 8, colors.white)

footer("NeoForge 1.21.1 | CC:Tweaked", colors.gray)
