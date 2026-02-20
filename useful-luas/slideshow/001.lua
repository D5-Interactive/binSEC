-- Slide 1: Welcome / Agenda

clear(colors.blue)

title(2, "BINSEC WORKSHOP #1", colors.white, colors.cyan)
center(4, "~ Cybersecurity Basics with Lua in CC:T ~", colors.yellow)
hline(3, 6, W - 4, "-", colors.lightBlue)

local y = 8
text(3, y, " 1.", colors.cyan)  text(7, y, "What is CC:Tweaked?", colors.white)              y=y+1
text(3, y, " 2.", colors.cyan)  text(7, y, "The CraftOS Shell", colors.white)                 y=y+1
text(3, y, " 3.", colors.cyan)  text(7, y, "Lua Syntax Crash Course", colors.white)           y=y+1
text(3, y, " 4.", colors.cyan)  text(7, y, "Filesystem API", colors.white)                    y=y+1
text(3, y, " 5.", colors.cyan)  text(7, y, "Peripherals & Mods", colors.white)                y=y+1
text(3, y, " 6.", colors.cyan)  text(7, y, "Redstone API", colors.white)                      y=y+1
text(3, y, " 7.", colors.cyan)  text(7, y, "Networking Deep-Dive", colors.white)               y=y+1
text(3, y, " 8.", colors.cyan)  text(7, y, "Network Architecture", colors.white)               y=y+1
text(3, y, " 9.", colors.cyan)  text(7, y, "Lab: Basic Security Tool", colors.yellow)          y=y+1
text(3, y, "10.", colors.cyan)  text(7, y, "Lab: Packet Sniffer", colors.yellow)               y=y+1
text(3, y, "11.", colors.cyan)  text(7, y, "Lab: Password Cracker", colors.yellow)             y=y+1
text(3, y, "12.", colors.cyan)  text(7, y, "Lab: Wireless Turtle + Dashboard", colors.yellow)

footer("UTSA Cyber Jedis  |  NeoForge 1.21.1", colors.lightGray)
