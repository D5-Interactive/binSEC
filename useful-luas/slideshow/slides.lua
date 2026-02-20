-- Slideshow Program for CC: Tweaked
-- Place slide files in the same directory as numbers: 001.lua, 002.lua, etc.

-- Configuration
local MONITOR_SIDE = "back"
local SLIDE_DIR = shell.getRunningProgram():match("(.*/)")  or ""

-- Find and setup monitor
local monitor = peripheral.wrap(MONITOR_SIDE)
if not monitor then
    error("No monitor found at " .. MONITOR_SIDE)
end

-- Set text scale to 0.5 for higher pixel density
monitor.setTextScale(0.5)

-- Get actual monitor dimensions after scaling
local WIDTH, HEIGHT = monitor.getSize()

-- State
local currentSlide = 1
local slides = {}

-- Load all slide files (sorted by number)
local function loadSlides()
    slides = {}
    
    if not fs.exists(SLIDE_DIR) or not fs.isDir(SLIDE_DIR) then
        error("Slide directory not found: " .. SLIDE_DIR)
    end
    
    local files = fs.list(SLIDE_DIR)
    local slideNums = {}
    
    for _, file in ipairs(files) do
        if file:match("^%d+%.lua$") then
            local num = tonumber(file:match("^(%d+)"))
            table.insert(slideNums, num)
        end
    end
    
    -- Sort numerically
    table.sort(slideNums)
    
    -- Build ordered slides list
    for _, num in ipairs(slideNums) do
        table.insert(slides, string.format("%03d.lua", num))
    end
    
    if #slides == 0 then
        error("No slide files found in " .. SLIDE_DIR)
    end
end

-- Render current slide
local function renderSlide()
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.clear()
    
    local slideFile = SLIDE_DIR .. slides[currentSlide]
    
    -- Create environment for slide execution
    local env = setmetatable({
        monitor = monitor,
        colors = colors,
        colours = colours,
        WIDTH = WIDTH,
        HEIGHT = HEIGHT,
        sleep = sleep,
        print = function(text)
            local x, y = monitor.getCursorPos()
            monitor.write(tostring(text))
            monitor.setCursorPos(1, y + 1)
        end,
    }, {__index = _G})
    
    local success, err = pcall(function()
        -- Use fs.open (CC:Tweaked API) instead of io.open
        local file = fs.open(slideFile, "r")
        if not file then
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(colors.red)
            monitor.write("Error loading")
            monitor.setCursorPos(1, 2)
            monitor.write("slide " .. currentSlide)
            return
        end
        
        local content = file.readAll()
        file.close()
        
        -- Load and run slide code
        local func, loadErr = load(content, slideFile, "t", env)
        if func then
            func()
        else
            monitor.setCursorPos(1, 1)
            monitor.setTextColor(colors.red)
            monitor.write("Syntax error:")
            monitor.setCursorPos(1, 2)
            monitor.write(tostring(loadErr):sub(1, WIDTH))
        end
    end)
    
    if not success then
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setTextColor(colors.red)
        monitor.write("Runtime error:")
        monitor.setCursorPos(1, 2)
        monitor.setTextColor(colors.orange)
        monitor.write(tostring(err):sub(1, WIDTH))
    end
    
    -- Display slide counter at bottom right
    local counter = string.format("%d/%d", currentSlide, #slides)
    monitor.setCursorPos(WIDTH - #counter + 1, HEIGHT)
    monitor.setTextColor(colors.gray)
    monitor.write(counter)
end

-- Handle mouse click (left column = prev, right column = next)
local function handleClick(x, y)
    local leftZone = math.floor(WIDTH / 3)
    local rightZone = WIDTH - leftZone
    
    if x <= leftZone then
        -- Left third: go back
        currentSlide = currentSlide - 1
        if currentSlide < 1 then
            currentSlide = #slides
        end
    elseif x > rightZone then
        -- Right third: go forward
        currentSlide = currentSlide + 1
        if currentSlide > #slides then
            currentSlide = 1
        end
    end
    -- Middle: do nothing (could be used for other actions)
    
    renderSlide()
end

-- Main loop
local function main()
    print("Loading slideshow...")
    loadSlides()
    print("Found " .. #slides .. " slides")
    print("Monitor size: " .. WIDTH .. "x" .. HEIGHT)
    
    renderSlide()
    
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
        handleClick(x, y)
    end
end

main()
