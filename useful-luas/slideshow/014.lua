-- Slide 14: Lab - Dashboard Controller

clear(colors.black)
header("Lab: Turtle Dashboard", colors.white, colors.red)

local y = 3
text(3, y, "OBJECTIVE:", colors.yellow) y=y+1
text(5, y, "Build a keyboard-driven controller for the turtle.", colors.white) y=y+2

text(3, y, "CONTROLS:", colors.yellow) y=y+1
text(5, y, "W/A/S/D", colors.lime)  text(15, y, "= forward / left / back / right", colors.white) y=y+1
text(5, y, "Space/Shift", colors.lime) text(15, y, "= up / down", colors.white)   y=y+1
text(5, y, "E", colors.lime)        text(15, y, "= dig forward", colors.white)    y=y+1
text(5, y, "R", colors.lime)        text(15, y, "= refuel from slot 1", colors.white)     y=y+1
text(5, y, "Q", colors.lime)        text(15, y, "= quit", colors.white) y=y+2

text(3, y, "FEATURES:", colors.orange) y=y+1
bullet(y, "Real-time fuel display + last reply", colors.white) y=y+1
bullet(y, "Round-trip latency measurement", colors.white) y=y+1
bullet(y, "Works over wireless modem (any distance)", colors.white) y=y+2

text(3, y, "SECURITY ANGLE:", colors.red) y=y+1
text(5, y, "Run the sniffer (slide 11) while controlling.", colors.white) y=y+1
text(5, y, "Watch every command + response in cleartext!", colors.white)

media = {{
  type  = "code",
  title = "[ TURTLE DASHBOARD ]",
  code  = [[
-- dashboard.lua  -  keyboard controller
local SIDE  = "back"
local PROTO = "turtlectl"

rednet.open(SIDE)
local target = rednet.lookup(PROTO, "turtle1")
if not target then error("Turtle not found") end

term.clear()
term.setCursorPos(1,1)
print("== Turtle Dashboard ==")
print("Target ID: " .. target)
print("W/A/S/D=move  Space/Shift=up/down")
print("E=dig  R=refuel  Q=quit")
print(string.rep("-", 40))

local keyMap = {
  [keys.w]      = "forward",
  [keys.s]      = "back",
  [keys.a]      = "left",
  [keys.d]      = "right",
  [keys.space]  = "up",
  [keys.leftShift] = "down",
  [keys.e]      = "dig",
  [keys.r]      = "refuel",
}

while true do
  local _, key = os.pullEvent("key")
  if key == keys.q then
    print("Bye!")
    rednet.close(SIDE)
    return
  end

  local cmd = keyMap[key]
  if cmd then
    local t0 = os.clock()
    rednet.send(target, {cmd = cmd}, PROTO)
    local _, reply = rednet.receive(PROTO, 2)
    local dt = os.clock() - t0

    if reply then
      term.setTextColor(reply.ok and colors.lime
                                  or colors.red)
      print(string.format(
        "[%s] ok=%s fuel=%s  (%.0fms)",
        cmd,
        tostring(reply.ok),
        tostring(reply.fuel or "?"),
        dt * 1000
      ))
    else
      term.setTextColor(colors.red)
      print("[" .. cmd .. "] TIMEOUT")
    end
    term.setTextColor(colors.white)
  end
end
]]
}}
