-- Slide 5: Filesystem API

clear(colors.black)
header("Filesystem API", colors.white, colors.cyan)

local y = 3
wrap(3, y, "CC:T sandboxes each computer's filesystem. Use the fs API:", W - 6, colors.lightGray)

y = y + 3
text(3, y, "Reading:", colors.yellow) y=y+1
text(5, y, 'local f = fs.open("data.txt", "r")', colors.lime)   y=y+1
text(5, y, "local data = f.readAll()", colors.lime)               y=y+1
text(5, y, "f.close()", colors.lime)                              y=y+2

text(3, y, "Writing:", colors.yellow) y=y+1
text(5, y, 'local f = fs.open("log.txt", "w")', colors.cyan)    y=y+1
text(5, y, 'f.write("breach at " .. os.time())', colors.cyan)    y=y+1
text(5, y, "f.close()", colors.cyan)                              y=y+2

text(3, y, "Appending:", colors.yellow) text(14, y, '("a" mode = add to end)', colors.gray) y=y+1
text(5, y, 'local f = fs.open("log.txt", "a")', colors.orange)   y=y+2

text(3, y, "Useful helpers:", colors.yellow) y=y+1
text(5, y, "fs.exists()  fs.isDir()  fs.list()", colors.orange)  y=y+1
text(5, y, "fs.makeDir()  fs.delete()  fs.copy()", colors.orange) y=y+1
text(5, y, "fs.move()    fs.getSize()  fs.getName()", colors.orange)

media = {
    {type="code", title="[ FS EXAMPLE ]", code=[[
-- Write a log file
local f = fs.open("security.log", "a")
f.writeLine("[" .. os.time() .. "] System booted")
f.writeLine("[" .. os.time() .. "] Modem opened")
f.close()

-- Read it back
local f = fs.open("security.log", "r")
local contents = f.readAll()
f.close()
print(contents)

-- List all files in root
local files = fs.list("/")
for _, name in ipairs(files) do
    local size = fs.getSize(name)
    local kind = fs.isDir(name) and "DIR" or "FILE"
    print(kind .. "  " .. name .. "  " .. size .. "B")
end
]]},
}
