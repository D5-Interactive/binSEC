
local CONFIG = {
    monitorSide = "back",
    textScale = 0.5,
    slideDir = "",
    mediaDir = "media/",
    defaultBg = colors.black,
    defaultFg = colors.white,
    counterColor = colors.gray,
}


local monitor, WIDTH, HEIGHT
local currentSlide = 1
local currentSub = 0          -- 0 = info slide, 1+ = media sub-slide index
local slides = {}              -- ordered list of slide filenames
local mediaCache = {}          -- [slideIndex] = normalized media list or nil
local mediaDataCache = {}      -- [filePath] = loaded bimg/32vid data
local stopPlayback = false     -- signal to kill media animation

-- Load slidelib module (must be in same directory)
local slidelib


local function initMonitor()
    monitor = peripheral.wrap(CONFIG.monitorSide)
    if not monitor then
        error("No monitor found on " .. CONFIG.monitorSide)
    end
    monitor.setTextScale(CONFIG.textScale)
    WIDTH, HEIGHT = monitor.getSize()
    return monitor
end



local Draw = {}

function Draw.clear(bgColor)
    monitor.setBackgroundColor(bgColor or CONFIG.defaultBg)
    monitor.clear()
end

function Draw.setColors(fg, bg)
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
end

function Draw.fg(color) monitor.setTextColor(color) end
function Draw.bg(color) monitor.setBackgroundColor(color) end

function Draw.pos(x, y)
    local px, py
    if type(x) == "number" then px = x
    elseif x == "center" then px = math.floor(WIDTH / 2)
    elseif x == "left" then px = 1
    elseif x == "right" then px = WIDTH
    elseif type(x) == "string" and x:match("%%$") then
        px = math.floor(WIDTH * tonumber(x:match("(%d+)")) / 100)
    else px = 1 end

    if type(y) == "number" then py = y
    elseif y == "center" then py = math.floor(HEIGHT / 2)
    elseif y == "top" then py = 1
    elseif y == "bottom" then py = HEIGHT
    elseif type(y) == "string" and y:match("%%$") then
        py = math.floor(HEIGHT * tonumber(y:match("(%d+)")) / 100)
    else py = 1 end

    monitor.setCursorPos(px, py)
    return px, py
end

function Draw.text(x, y, txt, fg, bg)
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    Draw.pos(x, y)
    monitor.write(tostring(txt))
end

function Draw.center(y, txt, fg, bg)
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    local x = math.floor((WIDTH - #txt) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(txt)
end

function Draw.wrap(x, y, txt, maxWidth, fg, bg)
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    maxWidth = maxWidth or (WIDTH - x + 1)
    local lines = 0
    local words = {}
    for word in txt:gmatch("%S+") do table.insert(words, word) end

    local currentLine = ""
    local currentY = y

    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        if #testLine > maxWidth then
            if currentLine ~= "" then
                monitor.setCursorPos(x, currentY)
                monitor.write(currentLine)
                currentY = currentY + 1
                lines = lines + 1
            end
            currentLine = word
        else
            currentLine = testLine
        end
    end
    if currentLine ~= "" then
        monitor.setCursorPos(x, currentY)
        monitor.write(currentLine)
        lines = lines + 1
    end
    return lines
end

function Draw.line(y, char, fg, bg)
    char = char or "-"
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    monitor.setCursorPos(1, y)
    monitor.write(string.rep(char, WIDTH))
end

function Draw.hline(x, y, length, char, fg, bg)
    char = char or "-"
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    monitor.setCursorPos(x, y)
    monitor.write(string.rep(char, length))
end

function Draw.fill(x, y, w, h, char, fg, bg)
    char = char or " "
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    for row = y, y + h - 1 do
        monitor.setCursorPos(x, row)
        monitor.write(string.rep(char, w))
    end
end

function Draw.box(x, y, w, h, fg, bg)
    if fg then monitor.setTextColor(fg) end
    if bg then monitor.setBackgroundColor(bg) end
    monitor.setCursorPos(x, y)
    monitor.write("+" .. string.rep("-", w - 2) .. "+")
    monitor.setCursorPos(x, y + h - 1)
    monitor.write("+" .. string.rep("-", w - 2) .. "+")
    for row = y + 1, y + h - 2 do
        monitor.setCursorPos(x, row)
        monitor.write("|")
        monitor.setCursorPos(x + w - 1, row)
        monitor.write("|")
    end
end

function Draw.button(x, y, txt, padding, fg, bg)
    padding = padding or 1
    local w = #txt + (padding * 2)
    if bg then monitor.setBackgroundColor(bg) end
    if fg then monitor.setTextColor(fg) end
    Draw.fill(x, y, w, 3, " ")
    monitor.setCursorPos(x + padding, y + 1)
    monitor.write(txt)
end

function Draw.header(txt, fg, bg)
    bg = bg or colors.purple
    fg = fg or colors.white
    monitor.setBackgroundColor(bg)
    monitor.setTextColor(fg)
    monitor.setCursorPos(1, 1)
    monitor.write(string.rep(" ", WIDTH))
    Draw.center(1, txt, fg, bg)
end

function Draw.title(y, txt, fg, underlineColor)
    Draw.center(y, txt, fg or colors.white)
    if underlineColor then
        local x = math.floor((WIDTH - #txt) / 2) + 1
        Draw.hline(x, y + 1, #txt, "=", underlineColor)
    end
end

function Draw.bullet(y, txt, bulletColor, textColor, indent)
    indent = indent or 2
    bulletColor = bulletColor or colors.yellow
    textColor = textColor or colors.white
    monitor.setCursorPos(indent, y)
    monitor.setTextColor(bulletColor)
    monitor.write("* ")
    monitor.setTextColor(textColor)
    return Draw.wrap(indent + 2, y, txt, WIDTH - indent - 3)
end

function Draw.numbered(y, num, txt, numColor, textColor, indent)
    indent = indent or 2
    numColor = numColor or colors.yellow
    textColor = textColor or colors.white
    local prefix = tostring(num) .. ": "
    monitor.setCursorPos(indent, y)
    monitor.setTextColor(numColor)
    monitor.write(prefix)
    monitor.setTextColor(textColor)
    return Draw.wrap(indent + #prefix, y, txt, WIDTH - indent - #prefix - 1)
end

function Draw.palette(x, y, cellWidth)
    cellWidth = cellWidth or 2
    local pal = {
        colors.red, colors.orange, colors.yellow, colors.lime,
        colors.green, colors.cyan, colors.lightBlue, colors.blue,
        colors.purple, colors.magenta, colors.pink
    }
    for i, c in ipairs(pal) do
        monitor.setBackgroundColor(c)
        monitor.setCursorPos(x + (i - 1) * cellWidth, y)
        monitor.write(string.rep(" ", cellWidth))
    end
    monitor.setBackgroundColor(CONFIG.defaultBg)
end

function Draw.footer(txt, fg)
    Draw.center(HEIGHT - 1, txt, fg or colors.lightGray)
end

-- ============================================
-- SLIDE LOADING
-- ============================================

local function getSlideDir()
    local path = shell.getRunningProgram()
    return path:match("(.*/)" ) or ""
end

local function loadSlides()
    slides = {}
    mediaCache = {}
    CONFIG.slideDir = getSlideDir()

    if not fs.exists(CONFIG.slideDir) then CONFIG.slideDir = "" end

    local searchDir = CONFIG.slideDir ~= "" and CONFIG.slideDir or "/"
    if not fs.isDir(searchDir) then searchDir = "/" end

    local files = fs.list(searchDir)
    local slideNums = {}

    for _, f in ipairs(files) do
        local num = f:match("^(%d+)%.lua$")
        if num then table.insert(slideNums, tonumber(num)) end
    end

    table.sort(slideNums)

    for _, num in ipairs(slideNums) do
        table.insert(slides, string.format("%03d.lua", num))
    end

    if #slides == 0 then
        error("No slide files (001.lua, 002.lua, etc.) found in: " .. searchDir)
    end

    return #slides
end



local function createSlideEnv()
    return setmetatable({
        Draw = Draw,
        clear = Draw.clear,
        text = Draw.text,
        center = Draw.center,
        wrap = Draw.wrap,
        line = Draw.line,
        hline = Draw.hline,
        fill = Draw.fill,
        box = Draw.box,
        button = Draw.button,
        header = Draw.header,
        title = Draw.title,
        bullet = Draw.bullet,
        numbered = Draw.numbered,
        palette = Draw.palette,
        footer = Draw.footer,
        fg = Draw.fg,
        bg = Draw.bg,
        pos = Draw.pos,
        monitor = monitor,
        W = WIDTH,
        H = HEIGHT,
        WIDTH = WIDTH,
        HEIGHT = HEIGHT,
        colors = colors,
        colours = colours,
        c = colors,
        sleep = sleep,
        rep = string.rep,
        media = nil,  -- slides set this to declare media
    }, {__index = _G})
end



local function normalizeMedia(raw)
    if raw == nil then return {} end
    if raw.type then return { raw } end
    if #raw > 0 then return raw end
    return {}
end

local function getMediaForSlide(slideIndex)
    if mediaCache[slideIndex] ~= nil then
        return mediaCache[slideIndex]
    end

    local slideFile = CONFIG.slideDir .. slides[slideIndex]
    local file = fs.open(slideFile, "r")
    if not file then
        mediaCache[slideIndex] = {}
        return {}
    end

    local content = file.readAll()
    file.close()

    local env = createSlideEnv()
    local func = load(content, slideFile, "t", env)
    if func then pcall(func) end

    local result = normalizeMedia(env.media)
    mediaCache[slideIndex] = result
    return result
end



local function renderInfoSlide()
    monitor.setBackgroundColor(CONFIG.defaultBg)
    monitor.setTextColor(CONFIG.defaultFg)
    monitor.clear()

    local slideFile = CONFIG.slideDir .. slides[currentSlide]

    local file = fs.open(slideFile, "r")
    if not file then
        Draw.center(math.floor(HEIGHT / 2), "Error: " .. slides[currentSlide], colors.red)
        return
    end

    local content = file.readAll()
    file.close()

    local env = createSlideEnv()
    local func, loadErr = load(content, slideFile, "t", env)

    if not func then
        Draw.clear(colors.black)
        Draw.text(2, 2, "Syntax Error:", colors.red)
        Draw.wrap(2, 4, tostring(loadErr), WIDTH - 4, colors.orange)
        return
    end

    local success, runErr = pcall(func)

    if not success then
        Draw.clear(colors.black)
        Draw.text(2, 2, "Runtime Error:", colors.red)
        Draw.wrap(2, 4, tostring(runErr), WIDTH - 4, colors.orange)
    end

    -- Cache media from this execution
    mediaCache[currentSlide] = normalizeMedia(env.media)
end

local function renderMediaSlide(mediaDef)
    slidelib.resetPalette(monitor)
    monitor.setBackgroundColor(CONFIG.defaultBg)
    monitor.setTextColor(CONFIG.defaultFg)
    monitor.clear()

    local mtype = mediaDef.type

    if mtype == "code" then
        slidelib.renderCode(monitor, WIDTH, HEIGHT, mediaDef.code, mediaDef.title)
        return "static"

    elseif mtype == "bimg" then
        local filePath = CONFIG.slideDir .. (mediaDef.file or "")

        if not mediaDataCache[filePath] then
            local data, err = slidelib.loadBimg(filePath)
            if not data then
                Draw.text(2, 2, "BIMG Error:", colors.red)
                Draw.wrap(2, 4, tostring(err), WIDTH - 4, colors.orange)
                return "static"
            end
            mediaDataCache[filePath] = data
        end
        local data = mediaDataCache[filePath]

        if data.isAnimated and #data.frames > 1 then
            return "bimg_anim", data
        else
            if data.frames[1] then
                slidelib.drawBimgFrame(monitor, data.frames[1])
            end
            return "static"
        end

    elseif mtype == "32vid" then
        local filePath = CONFIG.slideDir .. (mediaDef.file or "")

        if not mediaDataCache[filePath] then
            local data, err = slidelib.load32vid(filePath)
            if not data then
                Draw.text(2, 2, "32vid Error:", colors.red)
                Draw.wrap(2, 4, tostring(err), WIDTH - 4, colors.orange)
                return "static"
            end
            mediaDataCache[filePath] = data
        end
        local data = mediaDataCache[filePath]
        return "32vid_anim", data

    else
        Draw.text(2, 2, "Unknown media: " .. tostring(mtype), colors.red)
        return "static"
    end
end



local function drawCounter()
    local mediaList = getMediaForSlide(currentSlide)
    local counterText

    if currentSub == 0 then
        counterText = string.format("%d/%d", currentSlide, #slides)
    else
        counterText = string.format("%d/%d [%d/%d]", currentSlide, #slides, currentSub, #mediaList)
    end

    monitor.setBackgroundColor(CONFIG.defaultBg)
    monitor.setTextColor(CONFIG.counterColor)
    monitor.setCursorPos(WIDTH - #counterText, HEIGHT)
    monitor.write(counterText)
end



local function animateBimg(data, loop)
    while true do
        for _, frame in ipairs(data.frames) do
            if stopPlayback then return end
            slidelib.drawBimgFrame(monitor, frame)
            drawCounter()
            sleep(frame.duration or data.secondsPerFrame or 0.05)
        end
        if not loop then return end
    end
end

local function animate32vid(data, loop)
    local speaker = peripheral.find("speaker")
    local frameTime = 1 / (data.fps or 20)
    while true do
        for i, frame in ipairs(data.videoFrames) do
            if stopPlayback then return end
            slidelib.draw32vidFrame(monitor, frame)
            drawCounter()
            if data.audioChunks[i] and speaker then
                slidelib.playAudioChunk(speaker, data.audioChunks[i])
            end
            sleep(frameTime)
        end
        if not loop then return end
    end
end



local function getMediaCount(slideIdx)
    return #getMediaForSlide(slideIdx)
end

local function goNext()
    local mc = getMediaCount(currentSlide)
    if currentSub < mc then
        currentSub = currentSub + 1
    else
        currentSlide = currentSlide + 1
        if currentSlide > #slides then currentSlide = 1 end
        currentSub = 0
    end
end

local function goPrev()
    if currentSub > 0 then
        currentSub = currentSub - 1
    else
        currentSlide = currentSlide - 1
        if currentSlide < 1 then currentSlide = #slides end
        currentSub = getMediaCount(currentSlide)
    end
end



local function handleTouch(x)
    local leftZone = math.floor(WIDTH / 3)
    local rightZone = WIDTH - leftZone
    if x <= leftZone then
        return "prev"
    elseif x > rightZone then
        return "next"
    end
    return nil
end



local function renderCurrent()
    stopPlayback = true
    sleep(0)
    stopPlayback = false
    slidelib.resetPalette(monitor)

    if currentSub == 0 then
        -- Info slide
        renderInfoSlide()
        drawCounter()
        while true do
            local _, _, x = os.pullEvent("monitor_touch")
            local action = handleTouch(x)
            if action == "prev" then goPrev() return
            elseif action == "next" then goNext() return end
        end
    else
        -- Media sub-slide
        local mediaList = getMediaForSlide(currentSlide)
        local mediaDef = mediaList[currentSub]
        if not mediaDef then goNext() return end

        local kind, data = renderMediaSlide(mediaDef)
        drawCounter()

        if kind == "static" then
            while true do
                local _, _, x = os.pullEvent("monitor_touch")
                local action = handleTouch(x)
                if action == "prev" then goPrev() return
                elseif action == "next" then goNext() return end
            end
        else
            local loop = mediaDef.loop ~= false
            parallel.waitForAny(
                function()
                    if kind == "bimg_anim" then
                        animateBimg(data, loop)
                    elseif kind == "32vid_anim" then
                        animate32vid(data, loop)
                    end
                    while true do os.pullEvent("monitor_touch") end
                end,
                function()
                    while true do
                        local _, _, x = os.pullEvent("monitor_touch")
                        local action = handleTouch(x)
                        if action == "prev" then
                            stopPlayback = true
                            goPrev()
                            return
                        elseif action == "next" then
                            stopPlayback = true
                            goNext()
                            return
                        end
                    end
                end
            )
        end
    end
end



local function main()
    print("Initializing slideshow...")
    initMonitor()
    print("Monitor: " .. WIDTH .. "x" .. HEIGHT)

    -- Load slidelib from same directory
    CONFIG.slideDir = getSlideDir()
    local oldPath = package.path
    package.path = (CONFIG.slideDir ~= "" and (CONFIG.slideDir .. "?.lua;") or "") .. package.path

    local ok, lib = pcall(require, "slidelib")
    if not ok then
        local f = fs.open((CONFIG.slideDir or "") .. "slidelib.lua", "r")
        if f then
            local src = f.readAll()
            f.close()
            lib = load(src, "slidelib", "t", _ENV)()
        else
            error("Cannot load slidelib.lua: " .. tostring(lib))
        end
    end
    slidelib = lib
    package.path = oldPath
    print("slidelib loaded")

    -- Create media dir if needed
    local mediaPath = CONFIG.slideDir .. CONFIG.mediaDir
    if not fs.exists(mediaPath) then fs.makeDir(mediaPath) end

    local count = loadSlides()
    print("Loaded " .. count .. " slides")
    print("Click right = next, left = prev")
    print("Media sub-slides auto-insert after info slides")

    while true do
        renderCurrent()
    end
end

main()

