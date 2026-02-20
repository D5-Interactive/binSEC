-- Slide 6: Peripherals & Mods

clear(colors.black)
header("Peripherals & Mods", colors.white, colors.magenta)

local y = 3
text(3, y, "Wrapping peripherals:", colors.yellow) y=y+1
text(5, y, 'local m = peripheral.wrap("back")', colors.lime) y=y+1
text(5, y, "local all = peripheral.getNames()", colors.lime)  y=y+2

text(3, y, "CC:Tweaked built-in:", colors.cyan) y=y+1
y = y + bullet(y, "monitor  - External color display", colors.white, colors.white, 5) + 1
y = y + bullet(y, "modem    - Wired & wireless networking", colors.white, colors.white, 5) + 1
y = y + bullet(y, "speaker  - Play sounds and DFPWM audio", colors.white, colors.white, 5) + 1
y = y + bullet(y, "printer  - Print pages to paper", colors.white, colors.white, 5)

y = y + 1
text(3, y, "CC:C Bridge (Create compat):", colors.orange) y=y+1
y = y + bullet(y, "Stress gauge, speedometer, display link, sequenced gearshift", colors.white, colors.white, 5) + 1

text(3, y, "Tom's Peripherals:", colors.red) y=y+1
y = y + bullet(y, "Redstone integrator, inventory manager, inventory connector", colors.white, colors.white, 5) + 1

text(3, y, "Advanced Peripherals:", colors.lime) y=y+1
y = y + bullet(y, "Chat box, ME/RS bridge, GPS, energy detector, geo scanner,", colors.white, colors.white, 5)
text(7, y, "environment detector, NBT storage, colony integrator", colors.white)

media = {
  { type = "bimg", file = "media/farmingturtle-cct.bimg", title = "Farming Turtle" },
  { type = "bimg", file = "media/miningturtle-cct.bimg",  title = "Mining Turtle" },
  { type = "32vid", file = "media/tiewin-gif.32v",        title = "TIE Win" },
}
