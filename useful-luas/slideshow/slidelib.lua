-- ============================================
-- slidelib.lua - Media rendering module
-- Provides: code blocks, bimg, 32vid playback
-- Usage: local slidelib = require("slidelib")
-- ============================================

local slidelib = {}

-- ============================================
-- CODE BLOCK RENDERER
-- ============================================

local LUA_KEYWORDS = {
    ["local"] = true, ["function"] = true, ["end"] = true,
    ["if"] = true, ["then"] = true, ["else"] = true, ["elseif"] = true,
    ["for"] = true, ["while"] = true, ["do"] = true, ["repeat"] = true, ["until"] = true,
    ["return"] = true, ["break"] = true, ["in"] = true,
    ["and"] = true, ["or"] = true, ["not"] = true,
    ["true"] = true, ["false"] = true, ["nil"] = true,
}

-- Render a single highlighted line on the monitor at row y
local function renderCodeLine(mon, y, lineText, gutterWidth, maxWidth)
    -- Line number gutter
    mon.setCursorPos(1, y)
    mon.setBackgroundColor(colors.gray)
    mon.setTextColor(colors.lightGray)
    local lineNum = y - 2 -- subtract header rows
    mon.write(string.format("%" .. gutterWidth .. "d ", lineNum))
    
    -- Code area background
    mon.setBackgroundColor(colors.black)
    
    local col = gutterWidth + 2
    local codeWidth = maxWidth - gutterWidth - 1
    local remaining = codeWidth
    
    -- Simple state machine for syntax coloring
    local i = 1
    local len = #lineText
    
    while i <= len and remaining > 0 do
        local ch = lineText:sub(i, i)
        
        -- Comment: -- to end of line
        if ch == "-" and lineText:sub(i, i + 1) == "--" then
            local rest = lineText:sub(i):sub(1, remaining)
            mon.setTextColor(colors.gray)
            mon.setCursorPos(col, y)
            mon.write(rest)
            remaining = remaining - #rest
            col = col + #rest
            break
        
        -- String: "..." or '...'
        elseif ch == '"' or ch == "'" then
            local closer = ch
            local j = i + 1
            while j <= len do
                if lineText:sub(j, j) == closer and lineText:sub(j - 1, j - 1) ~= "\\" then
                    j = j + 1
                    break
                end
                j = j + 1
            end
            local str = lineText:sub(i, j - 1):sub(1, remaining)
            mon.setTextColor(colors.lime)
            mon.setCursorPos(col, y)
            mon.write(str)
            remaining = remaining - #str
            col = col + #str
            i = j
        
        -- Word (identifier or keyword)
        elseif ch:match("[%a_]") then
            local j = i
            while j <= len and lineText:sub(j, j):match("[%w_]") do j = j + 1 end
            local word = lineText:sub(i, j - 1)
            local fragment = word:sub(1, remaining)
            if LUA_KEYWORDS[word] then
                mon.setTextColor(colors.yellow)
            else
                mon.setTextColor(colors.white)
            end
            mon.setCursorPos(col, y)
            mon.write(fragment)
            remaining = remaining - #fragment
            col = col + #fragment
            i = j
        
        -- Number
        elseif ch:match("%d") then
            local j = i
            while j <= len and lineText:sub(j, j):match("[%d%.x]") do j = j + 1 end
            local num = lineText:sub(i, j - 1):sub(1, remaining)
            mon.setTextColor(colors.orange)
            mon.setCursorPos(col, y)
            mon.write(num)
            remaining = remaining - #num
            col = col + #num
            i = j
        
        -- Punctuation / operators
        else
            mon.setTextColor(colors.lightGray)
            mon.setCursorPos(col, y)
            mon.write(ch)
            remaining = remaining - 1
            col = col + 1
            i = i + 1
        end
    end
    
    -- Fill remaining with background
    if remaining > 0 then
        mon.setCursorPos(col, y)
        mon.write(string.rep(" ", remaining))
    end
end

--- Render a syntax-highlighted code block on the monitor.
--- @param mon table Monitor peripheral
--- @param W number Monitor width
--- @param H number Monitor height
--- @param codeString string The code to display
--- @param title string|nil Optional header title (default "[ CODE ]")
function slidelib.renderCode(mon, W, H, codeString, codeTitle)
    codeTitle = codeTitle or "[ CODE ]"
    
    mon.setBackgroundColor(colors.black)
    mon.clear()
    
    -- Header bar
    mon.setBackgroundColor(colors.gray)
    mon.setTextColor(colors.white)
    mon.setCursorPos(1, 1)
    mon.write(string.rep(" ", W))
    local hx = math.floor((W - #codeTitle) / 2) + 1
    mon.setCursorPos(hx, 1)
    mon.write(codeTitle)
    
    -- Separator
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.gray)
    mon.setCursorPos(1, 2)
    mon.write(string.rep("-", W))
    
    -- Split code into lines
    local lines = {}
    for ln in (codeString .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(lines, ln)
    end
    
    -- Calculate gutter width
    local gutterWidth = math.max(3, #tostring(#lines))
    
    -- Render lines (starting at row 3)
    local maxRows = H - 2  -- header + separator
    for i = 1, math.min(#lines, maxRows) do
        renderCodeLine(mon, i + 2, lines[i], gutterWidth, W)
    end
    
    -- Fill empty rows below code
    for i = #lines + 1, maxRows do
        mon.setCursorPos(1, i + 2)
        mon.setBackgroundColor(colors.gray)
        mon.setTextColor(colors.lightGray)
        mon.write(string.rep(" ", gutterWidth + 1))
        mon.setBackgroundColor(colors.black)
        mon.write(string.rep(" ", W - gutterWidth - 1))
    end
end

-- ============================================
-- BIMG RENDERER
-- ============================================

--- Load a .bimg file and return parsed image data.
--- @param filePath string Path to the .bimg file
--- @return table|nil img Parsed image table, or nil on error
--- @return string|nil err Error message
function slidelib.loadBimg(filePath)
    local file, err = fs.open(filePath, "rb")
    if not file then return nil, "Cannot open: " .. tostring(err) end
    
    local raw = file.readAll()
    file.close()
    
    local img = textutils.unserialize(raw)
    if not img then return nil, "Failed to deserialize bimg" end
    
    local result = {
        frames = {},
        isAnimated = img.animation and true or false,
        fps = 1 / (img.secondsPerFrame or 0.05),
        secondsPerFrame = img.secondsPerFrame or 0.05,
    }
    
    for i, frame in ipairs(img) do
        result.frames[i] = frame
    end
    
    return result
end

--- Draw a single bimg frame on the monitor.
--- @param mon table Monitor peripheral
--- @param frame table A single bimg frame (array of {text, fg, bg} rows)
function slidelib.drawBimgFrame(mon, frame)
    for y, row in ipairs(frame) do
        mon.setCursorPos(1, y)
        mon.blit(table.unpack(row))
    end
    if frame.palette then
        for i = 0, #frame.palette do
            local c = frame.palette[i]
            if c then
                if type(c) == "table" then
                    mon.setPaletteColor(2 ^ i, table.unpack(c))
                else
                    mon.setPaletteColor(2 ^ i, c)
                end
            end
        end
    end
end

-- ============================================
-- 32VID RENDERER
-- ============================================

local bit32_band = bit32.band
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift
local math_frexp = math.frexp

local function log2(n)
    local _, r = math_frexp(n)
    return r - 1
end

local blitColors = {
    [0] = "0", "1", "2", "3", "4", "5", "6", "7",
    "8", "9", "a", "b", "c", "d", "e", "f"
}

--- Load and decode an entire 32vid file into memory.
--- Returns a table of decoded frames, palettes, audio chunks, and fps.
--- @param filePath string Path to the .32vid file
--- @return table|nil data Decoded video data, or nil on error
--- @return string|nil err Error message
function slidelib.load32vid(filePath)
    local file
    if filePath:match("^https?://") then
        file = http.get(filePath, nil, true)
    else
        file = fs.open(filePath, "rb")
    end
    if not file then return nil, "Cannot open: " .. filePath end
    
    -- Read header
    local magic = file.read(4)
    if magic ~= "32VD" then
        file.close()
        return nil, "Not a 32Vid file"
    end
    
    local hdr = file.read(8)
    local width, height, fps, nstreams, flags = ("<HHBBH"):unpack(hdr)
    
    if nstreams ~= 1 then
        file.close()
        return nil, "Separate stream files not supported"
    end
    
    if bit32_band(flags, 1) == 0 then
        file.close()
        return nil, "Only ANS compression supported"
    end
    
    local streamHdr = file.read(9)
    local _, nframes, ctype = ("<IIB"):unpack(streamHdr)
    
    if ctype ~= 0x0C then
        file.close()
        return nil, "Unsupported stream type"
    end
    
    -- ANS decoder state
    local decodingTable, X, readbits, isColor
    
    local function readDict(size)
        local retval = {}
        for i = 0, size - 1, 2 do
            local b = file.read()
            retval[i] = bit32_rshift(b, 4)
            retval[i + 1] = bit32_band(b, 15)
        end
        return retval
    end
    
    local function initANS(c)
        isColor = c
        local R = file.read()
        local L = 2 ^ R
        local Ls = readDict(c and 24 or 32)
        if R == 0 then
            decodingTable = file.read()
            X = nil
            return
        end
        local a = 0
        for i = 0, #Ls do
            Ls[i] = Ls[i] == 0 and 0 or 2 ^ (Ls[i] - 1)
            a = a + Ls[i]
        end
        decodingTable = { R = R }
        local x, step, nextT, symbol = 0, 0.625 * L + 3, {}, {}
        for i = 0, #Ls do
            nextT[i] = Ls[i]
            for _ = 1, Ls[i] do
                while symbol[x] do x = (x + 1) % L end
                symbol[x] = i
                x = (x + step) % L
            end
        end
        for x2 = 0, L - 1 do
            local s = symbol[x2]
            local t = { s = s, n = R - log2(nextT[s]) }
            t.X = bit32_lshift(nextT[s], t.n) - L
            decodingTable[x2] = t
            nextT[s] = 1 + nextT[s]
        end
        local partial, bits2, pos2 = 0, 0, 1
        readbits = function(n)
            if not n then n = bits2 % 8 end
            if n == 0 then return 0 end
            while bits2 < n do
                pos2 = pos2 + 1
                bits2 = bits2 + 8
                partial = bit32_lshift(partial, 8) + file.read()
            end
            local retval = bit32_band(bit32_rshift(partial, bits2 - n), 2 ^ n - 1)
            bits2 = bits2 - n
            return retval
        end
        X = readbits(R)
    end
    
    local function readANS(nsym)
        local retval = {}
        if X == nil then
            for i = 1, nsym do retval[i] = decodingTable end
            return retval
        end
        local i = 1
        local last = 0
        while i <= nsym do
            local t = decodingTable[X]
            if isColor and t.s >= 16 then
                local l = 2 ^ (t.s - 15)
                for n = 0, l - 1 do retval[i + n] = last end
                i = i + l
            else
                retval[i] = t.s
                last = t.s
                i = i + 1
            end
            X = t.X + readbits(t.n)
        end
        return retval
    end
    
    -- Decode all frames
    local result = {
        width = width,
        height = height,
        fps = fps,
        flags = flags,
        videoFrames = {},
        audioChunks = {},
    }
    
    local dfpwm = nil
    if bit32_band(flags, 12) ~= 0 then
        dfpwm = require("cc.audio.dfpwm")
    end
    
    for _ = 1, nframes do
        local frameHdr = file.read(5)
        local size, ftype = ("<IB"):unpack(frameHdr)
        
        if ftype == 0 then
            -- Video frame
            initANS(false)
            local screen = readANS(width * height)
            initANS(true)
            local bgData = readANS(width * height)
            local fgData = readANS(width * height)
            
            -- Build blit-ready rows
            local texta, fga, bga = {}, {}, {}
            for y = 0, height - 1 do
                local textRow, fgRow, bgRow = "", "", ""
                for x = 1, width do
                    textRow = textRow .. string.char(128 + screen[y * width + x])
                    fgRow = fgRow .. blitColors[fgData[y * width + x]]
                    bgRow = bgRow .. blitColors[bgData[y * width + x]]
                end
                texta[y + 1] = textRow
                fga[y + 1] = fgRow
                bga[y + 1] = bgRow
            end
            
            -- Read palette
            local pal = {}
            for i = 0, 15 do
                local r, g, b = file.read() / 255, file.read() / 255, file.read() / 255
                pal[i] = { r, g, b }
            end
            
            table.insert(result.videoFrames, {
                text = texta,
                fg = fga,
                bg = bga,
                palette = pal,
            })
        
        elseif ftype == 1 then
            -- Audio frame
            local audio = file.read(size)
            local decoded
            if bit32_band(flags, 12) == 0 then
                -- Raw PCM
                decoded = { audio:byte(1, -1) }
                for i = 1, #decoded do decoded[i] = decoded[i] - 128 end
            else
                -- DFPWM
                if dfpwm then
                    local decoder = dfpwm.make_decoder()
                    decoded = decoder(audio)
                else
                    decoded = {}
                end
            end
            table.insert(result.audioChunks, decoded)
        
        else
            -- Skip unknown frame types
            file.read(size)
        end
    end
    
    file.close()
    return result
end

--- Draw a single decoded 32vid frame on the monitor.
--- @param mon table Monitor peripheral
--- @param frame table Decoded frame with .text, .fg, .bg, .palette
function slidelib.draw32vidFrame(mon, frame)
    -- Set palette
    if frame.palette then
        for i = 0, 15 do
            if frame.palette[i] then
                mon.setPaletteColor(2 ^ i, frame.palette[i][1], frame.palette[i][2], frame.palette[i][3])
            end
        end
    end
    -- Blit rows
    for y = 1, #frame.text do
        mon.setCursorPos(1, y)
        mon.blit(frame.text[y], frame.fg[y], frame.bg[y])
    end
end

--- Feed one audio chunk to a speaker.
--- @param speaker table Speaker peripheral
--- @param chunk table Decoded audio samples
function slidelib.playAudioChunk(speaker, chunk)
    if speaker and chunk and #chunk > 0 then
        while not speaker.playAudio(chunk) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

--- Reset monitor palette to defaults.
--- @param mon table Monitor peripheral
function slidelib.resetPalette(mon)
    for i = 0, 15 do
        mon.setPaletteColor(2 ^ i, term.nativePaletteColor(2 ^ i))
    end
end

return slidelib
