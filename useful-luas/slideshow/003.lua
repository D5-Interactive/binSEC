-- Slide 3: The CraftOS Shell

clear(colors.black)
header("The CraftOS Shell", colors.white, colors.green)

local y = 3
wrap(3, y, "CraftOS boots on every computer. The shell is your command-line interface.", W - 6, colors.lightGray)

y = y + 3
text(3, y, "Navigation:", colors.yellow) y=y+1
text(5, y, "ls / dir", colors.lime)          text(22, y, "List files", colors.white)        y=y+1
text(5, y, "cd <path>", colors.lime)          text(22, y, "Change directory", colors.white)  y=y+1
text(5, y, "pwd", colors.lime)                text(22, y, "Print working dir", colors.white) y=y+1

y = y + 1
text(3, y, "Editing & running:", colors.yellow) y=y+1
text(5, y, "edit <file>", colors.cyan)        text(22, y, "Built-in text editor", colors.white)  y=y+1
text(5, y, "lua", colors.cyan)                text(22, y, "Interactive REPL", colors.white)       y=y+1
text(5, y, "programs", colors.cyan)           text(22, y, "List all commands", colors.white)      y=y+1

y = y + 1
text(3, y, "Downloading:", colors.yellow) y=y+1
text(5, y, "wget <url> <name>", colors.orange)   text(25, y, "Download a file", colors.white)    y=y+1
text(5, y, "pastebin get <id>", colors.orange)    text(25, y, "Grab from pastebin", colors.white)

footer("Type 'help <topic>' for built-in docs", colors.gray)
