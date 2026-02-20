-- Slide 13: Lab - Wireless Turtle Control

clear(colors.black)
header("Lab: Wireless Turtle", colors.white, colors.red)

local y = 3
text(3, y, "OBJECTIVE:", colors.yellow) y=y+1
text(5, y, "Remote-control a mining turtle + sniff its comms.", colors.white) y=y+2

text(3, y, "COMPONENTS:", colors.yellow) y=y+1
bullet(y, "Mining Turtle with wireless modem", colors.white) y=y+1
bullet(y, "Controller computer (see next slide)", colors.white) y=y+1
bullet(y, "Sniffer running passively (slide 11)", colors.white) y=y+2

text(3, y, "TURTLE PROTOCOL:", colors.orange) y=y+1
bullet(y, 'Protocol: "turtlectl"', colors.cyan) y=y+1
bullet(y, "Commands: forward, back, left, right, up, down", colors.cyan) y=y+1
bullet(y, "          dig, place, inspect, refuel, status", colors.cyan) y=y+1
bullet(y, "Turtle replies with result + fuel + position", colors.cyan) y=y+2

text(3, y, "SECURITY ANGLE:", colors.red) y=y+1
text(5, y, "Turtle obeys ANY sender. No authentication!", colors.white) y=y+1
text(5, y, "An attacker can hijack the turtle's movements.", colors.white) y=y+2

text(3, y, "DEFENSE:", colors.lime) y=y+1
text(5, y, "Validate sender ID, use shared secret in payload.", colors.white)

media = {{
  type  = "code",
  title = "[ TURTLE AGENT ]",
  code  = [[
-- turtle_agent.lua  -  runs ON the turtle
local SIDE  = "right"
local PROTO = "turtlectl"

rednet.open(SIDE)
rednet.host(PROTO, "turtle1")
print("Turtle agent ready. ID=" .. os.getComputerID())

local cmds = {
  forward = turtle.forward,
  back    = turtle.back,
  left    = turtle.turnLeft,
  right   = turtle.turnRight,
  up      = turtle.up,
  down    = turtle.down,
  dig     = turtle.dig,
  digUp   = turtle.digUp,
  digDown = turtle.digDown,
  place   = turtle.place,
  inspect = turtle.inspect,
  refuel  = function()
    turtle.select(1)
    return turtle.refuel()
  end,
  status  = function()
    return true, {
      fuel = turtle.getFuelLevel(),
      id   = os.getComputerID(),
    }
  end,
}

while true do
  local sender, msg = rednet.receive(PROTO)
  local cmd = type(msg) == "table" and msg.cmd or msg

  local fn = cmds[cmd]
  if fn then
    local ok, detail = fn()
    rednet.send(sender, {
      ok     = ok,
      detail = detail,
      fuel   = turtle.getFuelLevel(),
    }, PROTO)
  else
    rednet.send(sender, {
      ok = false, detail = "unknown: " .. tostring(cmd)
    }, PROTO)
  end
end
]]
}}
