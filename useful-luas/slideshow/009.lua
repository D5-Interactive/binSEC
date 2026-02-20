-- Slide 9: Network Architecture Visual

clear(colors.black)
header("Network Architecture", colors.white, colors.purple)

local y = 4

-- Internet cloud
center(y,   ".-~~~-.", colors.red)                               y=y+1
center(y,   "( INTERNET )", colors.red)                          y=y+1
center(y,   "'-.___..-'", colors.red)                            y=y+1
center(y,   "|", colors.gray)                                    y=y+1
center(y,   "v", colors.gray)                                    y=y+2

-- Gateway
fill(20, y, 58, y+2, " ", colors.black, colors.blue)
box(20, y, 58, y+2, colors.lightBlue)
center(y+1, "[ HTTP Gateway Computer ]", colors.white)           y=y+4

-- Backbone label
center(y, "=== WIRED MODEM BACKBONE (cables) ===", colors.yellow) y=y+2

-- Three branches
local col1, col2, col3 = 8, 36, 64

-- Branch: Computers
fill(col1, y, col1+22, y+4, " ", colors.black, colors.green)
box(col1, y, col1+22, y+4, colors.lime)
text(col1+2, y+1, "Advanced Computers", colors.lime)
text(col1+2, y+2, "  - Workstations", colors.white)
text(col1+2, y+3, "  - Servers", colors.white)

-- Branch: Turtles
fill(col2, y, col2+22, y+4, " ", colors.black, colors.orange)
box(col2, y, col2+22, y+4, colors.yellow)
text(col2+2, y+1, "Mining Turtles", colors.yellow)
text(col2+2, y+2, "  - Wireless modem", colors.white)
text(col2+2, y+3, "  - GPS swarm", colors.white)

-- Branch: Monitors / Peripherals
fill(col3, y, col3+22, y+4, " ", colors.black, colors.cyan)
box(col3, y, col3+22, y+4, colors.lightBlue)
text(col3+2, y+1, "Monitors & I/O", colors.lightBlue)
text(col3+2, y+2, "  - 7x5 displays", colors.white)
text(col3+2, y+3, "  - Speakers, etc.", colors.white)

y = y + 6
center(y, "All networked via wired/wireless modems", colors.gray)
center(y+1, "Channels 0-65535 available for comms", colors.gray)
