-- Slide 11: Lab - Packet Sniffer

clear(colors.black)
header("Lab: Packet Sniffer", colors.white, colors.red)

local y = 3
text(3, y, "OBJECTIVE:", colors.yellow) y=y+1
text(5, y, "Capture and log all modem traffic on a range of channels.", colors.white) y=y+2

text(3, y, "HOW IT WORKS:", colors.yellow) y=y+1
bullet(y, "Open ALL channels (0-65535) or a target range", colors.white)  y=y+1
bullet(y, 'Pull "modem_message" events in an infinite loop', colors.white) y=y+1
bullet(y, "Display sender, channel, reply-ch, distance, payload", colors.white) y=y+1
bullet(y, "Optionally write to a log file for analysis", colors.white) y=y+2

text(3, y, "KEY CONCEPTS:", colors.orange) y=y+1
bullet(y, "Promiscuous listening - hear everything on the wire", colors.cyan) y=y+1
bullet(y, "Anyone on same cable/freq can eavesdrop!", colors.cyan) y=y+1
bullet(y, "Distance field reveals sender location", colors.cyan) y=y+2

text(3, y, "SECURITY ANGLE:", colors.red) y=y+1
text(5, y, "CC:T modems have NO encryption by default.", colors.white) y=y+1
text(5, y, "All payloads are plaintext. Passwords, commands, data", colors.white) y=y+1
text(5, y, "can all be captured by a passive listener.", colors.white) y=y+2

text(3, y, "DEFENSE:", colors.lime) y=y+1
text(5, y, "Use shared-secret hashing or challenge-response auth.", colors.white)

media = {{
  type  = "code",
  title = "[ PACKET SNIFFER ]",
  code  = [[
-- sniffer.lua  -  CC:T packet sniffer
local SIDE    = "back"
local LOG     = "sniff.log"
local CH_LOW  = 0
local CH_HIGH = 128

local modem = peripheral.wrap(SIDE)
if not modem then error("No modem on " .. SIDE) end

-- Open channel range
for ch = CH_LOW, CH_HIGH do modem.open(ch) end
print("Listening on ch " .. CH_LOW .. "-" .. CH_HIGH .. " ...")

local logFile = fs.open(LOG, "w")
logFile.writeLine("== Sniffer started " .. os.date() .. " ==")

while true do
  local ev, side, ch, rch, msg, dist =
        os.pullEvent("modem_message")

  local ts   = textutils.formatTime(os.time(), true)
  local line = string.format(
    "[%s] ch=%d rch=%d dist=%.1f | %s",
    ts, ch, rch, dist or 0, tostring(msg)
  )

  -- Terminal output (color-coded)
  term.setTextColor(colors.gray)
  write("[" .. ts .. "] ")
  term.setTextColor(colors.yellow)
  write("ch=" .. ch .. " ")
  term.setTextColor(colors.cyan)
  write("rch=" .. rch .. " ")
  term.setTextColor(colors.lightGray)
  print(tostring(msg))

  -- File log
  logFile.writeLine(line)
  logFile.flush()
end
]]
}}
