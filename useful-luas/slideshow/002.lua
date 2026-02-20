-- Slide 2: Features Demo
-- Demonstrates colored text and formatting

monitor.setBackgroundColor(colors.black)
monitor.clear()

-- Header with accent bar
monitor.setBackgroundColor(colors.purple)
monitor.setCursorPos(1, 1)
monitor.write(string.rep(" ", WIDTH))
monitor.setCursorPos(3, 1)
monitor.setTextColor(colors.white)
monitor.write("FEATURES")
monitor.setBackgroundColor(colors.black)

-- Color palette demo
monitor.setCursorPos(2, 4)
monitor.setTextColor(colors.yellow)
monitor.write("* ")
monitor.setTextColor(colors.white)
monitor.write("Colored Text Support")

monitor.setCursorPos(2, 6)
monitor.setTextColor(colors.lime)
monitor.write("* ")
monitor.setTextColor(colors.white)
monitor.write("16 Available Colors")

monitor.setCursorPos(2, 8)
monitor.setTextColor(colors.cyan)
monitor.write("* ")
monitor.setTextColor(colors.white)
monitor.write("Background Colors")

monitor.setCursorPos(2, 10)
monitor.setTextColor(colors.orange)
monitor.write("* ")
monitor.setTextColor(colors.white)
monitor.write("0.5 Text Scale = More Space")

-- Color swatches
monitor.setCursorPos(2, 13)
monitor.setTextColor(colors.lightGray)
monitor.write("Color palette:")

local palette = {colors.red, colors.orange, colors.yellow, colors.lime, 
                 colors.green, colors.cyan, colors.lightBlue, colors.blue, 
                 colors.purple, colors.magenta, colors.pink}
monitor.setCursorPos(2, 15)
for i, c in ipairs(palette) do
    monitor.setBackgroundColor(c)
    monitor.write("  ")
end
monitor.setBackgroundColor(colors.black)
