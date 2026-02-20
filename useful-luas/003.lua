-- Slide 3: Final Slide
-- Thank you / end slide

monitor.setBackgroundColor(colors.gray)
monitor.clear()

-- Centered "THE END" with decorative border
local centerX = math.floor(WIDTH / 2)
local centerY = math.floor(HEIGHT / 2)

-- Top border
monitor.setTextColor(colors.lime)
monitor.setCursorPos(centerX - 8, centerY - 3)
monitor.write(string.rep("=", 17))

-- Title
monitor.setBackgroundColor(colors.green)
monitor.setTextColor(colors.white)
monitor.setCursorPos(centerX - 6, centerY - 1)
monitor.write("             ")
monitor.setCursorPos(centerX - 6, centerY)
monitor.write("  THE END!   ")
monitor.setCursorPos(centerX - 6, centerY + 1)
monitor.write("             ")

-- Bottom border
monitor.setBackgroundColor(colors.gray)
monitor.setTextColor(colors.lime)
monitor.setCursorPos(centerX - 8, centerY + 3)
monitor.write(string.rep("=", 17))

-- Footer
monitor.setCursorPos(2, HEIGHT - 2)
monitor.setTextColor(colors.yellow)
monitor.write("Thanks for watching!")

monitor.setCursorPos(2, HEIGHT - 1)
monitor.setTextColor(colors.lightGray)
monitor.write("Click left to restart")
