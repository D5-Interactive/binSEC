-- Slide 10: Lab - Port Scanner

clear(colors.black)
header("Lab: Port Scanner", colors.white, colors.red)

local y = 3
text(3, y, "OBJECTIVE:", colors.yellow) y=y+1
text(5, y, "Scan modem channels to find active services.", colors.white) y=y+2

text(3, y, "HOW IT WORKS:", colors.yellow) y=y+1
bullet(y, "Open a modem on a side (e.g. 'back')", colors.white) y=y+1
bullet(y, "Loop through channels 1..128 (or custom range)", colors.white) y=y+1
bullet(y, "Transmit a 'ping' on each channel", colors.white) y=y+1
bullet(y, "Wait briefly for a reply  (os.startTimer)", colors.white) y=y+1
bullet(y, "Log which channels respond", colors.white) y=y+2

text(3, y, "KEY CONCEPTS:", colors.orange) y=y+1
bullet(y, "modem.open(ch) / modem.close(ch)", colors.cyan) y=y+1
bullet(y, "modem.transmit(ch, replyCh, payload)", colors.cyan) y=y+1
bullet(y, 'os.pullEvent("modem_message") vs timer', colors.cyan) y=y+1
bullet(y, "Channel = port  |  Reply channel = source port", colors.cyan) y=y+2

text(3, y, "SECURITY ANGLE:", colors.red) y=y+1
text(5, y, "Port scanning reveals exposed services.", colors.white) y=y+1
text(5, y, "Defenders: close unused channels!", colors.white)

media = {{
  type  = "code",
  title = "[ PORT SCANNER ]",
  code  = [[
-- scanner.lua  -  CC:T channel scanner
local SIDE  = "back"
local START = 1
local STOP  = 128
local TIMEOUT = 0.3          -- seconds per channel

local modem = peripheral.wrap(SIDE)
if not modem then error("No modem on " .. SIDE) end

print("Scanning channels " .. START .. "-" .. STOP .. " ...")

local open = {}

for ch = START, STOP do
  modem.open(ch)
  modem.transmit(ch, os.getComputerID(), "ping")

  local timer = os.startTimer(TIMEOUT)
  while true do
    local ev, p1, p2, p3, p4 = os.pullEvent()
    if ev == "modem_message" and p2 == ch then
      table.insert(open, {ch = ch, msg = p4})
      print("  [+] Channel " .. ch .. " responded: " .. tostring(p4))
      break
    elseif ev == "timer" and p1 == timer then
      break                    -- timeout, move on
    end
  end
  modem.close(ch)
end

print()
print("Scan complete. " .. #open .. " open channel(s).")
for _, entry in ipairs(open) do
  print("  ch " .. entry.ch .. " -> " .. tostring(entry.msg))
end
]]
}}
