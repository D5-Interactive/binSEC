-- Slide 8: Networking Deep-Dive

clear(colors.black)
header("Networking Deep-Dive", colors.white, colors.lightBlue)

local y = 3
text(3, y, "REDNET (high-level):", colors.yellow) y=y+1
text(5, y, 'rednet.open("back")', colors.lime)                          y=y+1
text(5, y, "rednet.send(targetID, msg, protocol)", colors.lime)          y=y+1
text(5, y, "rednet.broadcast(msg, protocol)", colors.lime)               y=y+1
text(5, y, "local id, msg = rednet.receive(proto, timeout)", colors.lime) y=y+2

text(3, y, "MODEM (raw packets):", colors.yellow) y=y+1
text(5, y, "modem.open(channel)", colors.cyan)                           y=y+1
text(5, y, "modem.transmit(ch, replyCh, data)", colors.cyan)             y=y+1
text(5, y, '-- listen: os.pullEvent("modem_message")', colors.gray)      y=y+1
text(5, y, "local ev,side,ch,rch,msg,dist =", colors.cyan)              y=y+1
text(7, y, 'os.pullEvent("modem_message")', colors.cyan)                 y=y+2

text(3, y, "HTTP:", colors.orange) y=y+1
text(5, y, "http.get(url)   http.post(url, body)", colors.orange)        y=y+2

text(3, y, "WEBSOCKETS:", colors.orange) y=y+1
text(5, y, "local ws = http.websocket(url)", colors.orange)              y=y+1
text(5, y, "ws.send(data)   local msg = ws.receive()", colors.orange)    y=y+2

text(3, y, "WGET:", colors.magenta)  text(10, y, "wget <url> <file>", colors.magenta)
text(30, y, "-- CLI downloader", colors.gray)
