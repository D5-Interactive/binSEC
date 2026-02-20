-- Slide 7: Redstone API

clear(colors.black)
header("Redstone API", colors.white, colors.red)

local y = 3
wrap(3, y, "Every computer face can send/receive redstone. Great for physical security systems.", W - 6, colors.lightGray)

y = y + 3
text(3, y, "Digital (on/off):", colors.yellow) y=y+1
text(5, y, 'redstone.setOutput("back", true)', colors.lime)           y=y+1
text(5, y, 'local on = redstone.getInput("front")', colors.lime)      y=y+2

text(3, y, "Analog (0-15 strength):", colors.yellow) y=y+1
text(5, y, 'redstone.setAnalogOutput("left", 12)', colors.cyan)       y=y+1
text(5, y, 'local pwr = redstone.getAnalogInput("right")', colors.cyan) y=y+2

text(3, y, "Sides:", colors.yellow)
text(10, y, "top  bottom  left  right  front  back", colors.orange) y=y+2

text(3, y, "Bundled cable (Project:Red / etc):", colors.yellow) y=y+1
text(5, y, 'redstone.setBundledOutput("back", colors.red)', colors.magenta) y=y+2

text(3, y, "Security use-cases:", colors.lime) y=y+1
y = y + bullet(y, "Keycard doors: pulse redstone to unlock", colors.white, colors.white, 5) + 1
y = y + bullet(y, "Alarm tripwire: detect redstone change event", colors.white, colors.white, 5) + 1
y = y + bullet(y, "Remote lockdown: kill power across wired network", colors.white, colors.white, 5)

media = {
    {type="code", title="[ REDSTONE DOOR LOCK ]", code=[[
-- Simple password door lock
-- Place computer next to a door with redstone

local PASSWORD = "letmein"

while true do
    term.clear()
    term.setCursorPos(1, 1)
    print("=== SECURE DOOR ===")
    write("Password: ")
    local input = read("*")  -- masked input

    if input == PASSWORD then
        print("ACCESS GRANTED")
        redstone.setOutput("back", true)
        sleep(3)
        redstone.setOutput("back", false)
    else
        print("ACCESS DENIED")
        -- Log failed attempt
        local f = fs.open("auth.log", "a")
        f.writeLine(os.time() .. " FAILED")
        f.close()
        sleep(1)
    end
end
]]},
}
