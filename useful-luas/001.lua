-- Slide 1: Title Slide
-- At 0.5 scale, a 7x5 monitor is approximately 98x50 characters

monitor.setBackgroundColor(colors.blue)
monitor.clear()

-- Title
monitor.setCursorPos(2, 3)
monitor.setBackgroundColor(colors.lightBlue)
monitor.setTextColor(colors.white)
monitor.write("  SLIDESHOW DEMO  ")

-- Subtitle
monitor.setBackgroundColor(colors.blue)
monitor.setCursorPos(2, 6)
monitor.setTextColor(colors.yellow)
monitor.write("CC: Tweaked Presentation")

-- Divider line
monitor.setCursorPos(2, 8)
monitor.setTextColor(colors.cyan)
monitor.write(string.rep("-", 26))

-- Instructions
monitor.setCursorPos(2, 11)
monitor.setTextColor(colors.white)
monitor.write("Click ")
monitor.setTextColor(colors.lime)
monitor.write("RIGHT")
monitor.setTextColor(colors.white)
monitor.write(" side to advance")

monitor.setCursorPos(2, 13)
monitor.setTextColor(colors.white)
monitor.write("Click ")
monitor.setTextColor(colors.orange)
monitor.write("LEFT")
monitor.setTextColor(colors.white)
monitor.write(" side to go back")

-- Footer accent
monitor.setCursorPos(2, HEIGHT - 2)
monitor.setTextColor(colors.lightGray)
monitor.write("NeoForge 1.21.1")
