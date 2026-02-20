-- Slide 4: Lua Syntax Crash Course

clear(colors.black)
header("Lua Syntax Crash Course", colors.white, colors.orange)

local y = 3
text(3, y, "Variables:", colors.yellow) y=y+1
text(5, y, "local x = 42", colors.lime)            text(30, y, "-- always use local", colors.gray)    y=y+1
text(5, y, 'local name = "Hacker"', colors.lime)    text(30, y, "-- strings in quotes", colors.gray)   y=y+2

text(3, y, "Conditionals:", colors.yellow) y=y+1
text(5, y, "if x > 10 then ... elseif ... else ... end", colors.cyan)  y=y+2

text(3, y, "Loops:", colors.yellow) y=y+1
text(5, y, "for i = 1, 10 do ... end", colors.magenta)                 y=y+1
text(5, y, "while condition do ... end", colors.magenta)                y=y+1
text(5, y, "for k,v in pairs(tbl) do ... end", colors.magenta)         y=y+2

text(3, y, "Functions:", colors.yellow) y=y+1
text(5, y, "local function attack(target)", colors.cyan)                y=y+1
text(7, y, 'print("Scanning " .. target)', colors.cyan)                y=y+1
text(5, y, "end", colors.cyan)                                          y=y+2

text(3, y, "Tables:", colors.yellow)  text(11, y, "(arrays + dicts = 1 structure)", colors.gray) y=y+1
text(5, y, "{1, 2, 3}", colors.lightBlue)                text(22, y, "-- array", colors.gray)   y=y+1
text(5, y, '{ip="10.0.0.1", port=80}', colors.lightBlue) text(32, y, "-- dict", colors.gray)

-- Declare code media sub-slide with an extended example
media = {
    {type="code", title="[ LUA EXAMPLE ]", code=[[
-- variables
local target = "server-01"
local port = 80
local attempts = 0

-- function
local function scan(host, p)
    print("Scanning " .. host .. ":" .. p)
    attempts = attempts + 1
    return true  -- simulated
end

-- loop + conditional
for i = 1, 5 do
    local open = scan(target, port + i)
    if open then
        print("Port " .. (port+i) .. " OPEN")
    else
        print("Port " .. (port+i) .. " closed")
    end
end

-- table
local results = {
    host = target,
    openPorts = {81, 83, 85},
    timestamp = os.time(),
}
print("Scan complete: " .. #results.openPorts .. " open")
]]},
}
