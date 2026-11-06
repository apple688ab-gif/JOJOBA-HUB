
-- JOJOBA HUB V3
-- iPad Touch Auto Clicker

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Http = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local CONFIG = "jojoba_clicker_config.json"

-- Stop previous instance
if type(_G.JOJOBA_STOP) == "function" then
    pcall(_G.JOJOBA_STOP)
end

local steps = {}
local running = false
local generation = 0
local selected = nil
local picking = false
local touchBusy = false
local activeTouch = false

local gui


local activeX, activeY = 0, 0

local function releaseTouch()
    pcall(function()
        VIM:SendTouchEvent(1, 2, activeX, activeY)
    end)
    activeTouch = false
end


local function save()
    if type(writefile) ~= "function" then
        return
    end

    local data = {
        enabled = running,
        steps = {}
    }

    for _, s in ipairs(steps) do
        table.insert(data.steps, {
            x = s.x,
            y = s.y,
            interval = s.interval
        })
    end

    pcall(function()
        writefile(CONFIG, Http:JSONEncode(data))
    end)
end

local function stopAll()
    running = false
    generation = generation + 1
    releaseTouch()
    save()
end

_G.JOJOBA_STOP = function()
    stopAll()
    if gui then gui:Destroy() end
end

local function load()
    if type(readfile) ~= "function"
        or type(isfile) ~= "function" then
        return false
    end

    local ok, data = pcall(function()
        if not isfile(CONFIG) then return nil end
        return Http:JSONDecode(readfile(CONFIG))
    end)

    if not ok or type(data) ~= "table" then
        return false
    end

    if type(data.steps) == "table" then
        for _, s in ipairs(data.steps) do
            if type(s.x) == "number"
                and type(s.y) == "number"
                and type(s.interval) == "number"
                and s.interval > 0 then

                table.insert(steps, {
                    x = math.floor(s.x),
                    y = math.floor(s.y),
                    interval = s.interval
                })
            end
        end
    end

    return data.enabled == true
end

local shouldResume = load()

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local BG = Color3.fromRGB(13, 17, 31)
local PANEL = Color3.fromRGB(28, 36, 57)
local BLUE = Color3.fromRGB(38, 118, 255)
local RED = Color3.fromRGB(230, 48, 75)
local WHITE = Color3.fromRGB(255, 255, 255)

gui = make("ScreenGui", guiParent, {
    Name = "JOJOBA_HUB_V3",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100
})

local main = make("Frame", gui, {
    Size = UDim2.fromOffset(310, 445),
    Position = UDim2.new(0.5, -155, 0.5, -222),
    BackgroundColor3 = BG,
    Active = true,
    Draggable = true
})
round(main, 12)

local mini = make("TextButton", gui, {
    Size = UDim2.fromOffset(90, 40),
    Position = UDim2.fromOffset(12, 160),
    BackgroundColor3 = RED,
    Text = "JOJOBA",
    TextColor3 = WHITE,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Visible = false
})
round(mini, 10)

local function btn(text, y, color)
    local b = make("TextButton", main, {
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.fromOffset(10, y),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = WHITE,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    round(b, 7)
    return b
end

make("TextLabel", main, {
    Size = UDim2.new(1, -60, 0, 40),
    Position = UDim2.fromOffset(10, 4),
    BackgroundTransparency = 1,
    Text = "JOJOBA HUB | V3",
    TextColor3 = WHITE,
    Font = Enum.Font.GothamBold,
    TextSize = 17
})

local minimize = make("TextButton", main, {
    Size = UDim2.fromOffset(36, 30),
    Position = UDim2.new(1, -43, 0, 8),
    BackgroundColor3 = RED,
    Text = "-",
    TextColor3 = WHITE,
    TextSize = 22
})
round(minimize, 7)

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

local pickButton = btn(
    "SELECT TAP POSITION", 52, BLUE
)

local positionLabel = make("TextLabel", main, {
    Size = UDim2.new(1, -20, 0, 24),
    Position = UDim2.fromOffset(10, 92),
    BackgroundTransparency = 1,
    Text = "Position: Not selected",
    TextColor3 = WHITE,
    TextSize = 12
})

local delayBox = make("TextBox", main, {
    Size = UDim2.fromOffset(170, 35),
    Position = UDim2.fromOffset(10, 123),
    BackgroundColor3 = PANEL,
    Text = "1",
    PlaceholderText = "Interval",
    ClearTextOnFocus = false,
    TextColor3 = WHITE,
    TextSize = 15
})
round(delayBox, 7)

local unitButton = make("TextButton", main, {
    Size = UDim2.fromOffset(110, 35),
    Position = UDim2.fromOffset(190, 123),
    BackgroundColor3 = BLUE,
    Text = "MINUTES",
    TextColor3 = WHITE,
    TextSize = 12
})
round(unitButton, 7)

local seconds = false

unitButton.MouseButton1Click:Connect(function()
    seconds = not seconds
    unitButton.Text = seconds
        and "SECONDS" or "MINUTES"
end)

local addButton = btn("+ ADD TAP", 168, BLUE)
local startButton = btn("START ALL", 211, RED)
local clearButton = btn("CLEAR ALL", 254, PANEL)

local list = make("ScrollingFrame", main, {
    Size = UDim2.new(1, -20, 0, 107),
    Position = UDim2.fromOffset(10, 298),
    BackgroundColor3 = PANEL,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new()
})
round(list, 7)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

layout:GetPropertyChangedSignal(
    "AbsoluteContentSize"
):Connect(function()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 8
    )
end)

local status = make("TextLabel", main, {
    Size = UDim2.new(1, -20, 0, 26),
    Position = UDim2.fromOffset(10, 411),
    BackgroundTransparency = 1,
    Text = "Ready",
    TextColor3 = WHITE,
    TextSize = 12
})

local function refresh()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for i, step in ipairs(steps) do
        local row = make("Frame", list, {
            Size = UDim2.new(1, -8, 0, 38),
            BackgroundColor3 = BG
        })
        round(row, 6)

        make("TextLabel", row, {
            Size = UDim2.new(1, -43, 1, 0),
            BackgroundTransparency = 1,
            Text = string.format(
                "#%d (%d,%d) Every %gs",
                i, step.x, step.y, step.interval
            ),
            TextColor3 = WHITE,
            TextSize = 11
        })

        local delete = make("TextButton", row, {
            Size = UDim2.fromOffset(32, 30),
            Position = UDim2.new(1, -35, 0, 4),
            BackgroundColor3 = RED,
            Text = "X",
            TextColor3 = WHITE
        })
        round(delete, 5)

        delete.MouseButton1Click:Connect(function()
            step.deleted = true
            table.remove(steps, i)
            save()
            refresh()
        end)
    end

    startButton.Text = running
        and "STOP ALL" or "START ALL"

    status.Text = (running and "RUNNING" or "READY")
        .. " | " .. #steps .. " taps"
end

pickButton.MouseButton1Click:Connect(function()
    if picking then return end
    picking = true
    main.Visible = false

    local overlay = make("TextButton", gui, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.8,
        Text = "TAP YOUR TARGET",
        TextColor3 = WHITE,
        TextSize = 18,
        ZIndex = 50
    })

    overlay.InputBegan:Connect(function(input)
        if not picking then return end

        if input.UserInputType
            ~= Enum.UserInputType.Touch
            and input.UserInputType
            ~= Enum.UserInputType.MouseButton1 then
            return
        end

        picking = false

        selected = Vector2.new(
            math.floor(input.Position.X),
            math.floor(input.Position.Y)
        )

        positionLabel.Text = string.format(
            "Position: %d, %d",
            selected.X, selected.Y
        )

        overlay:Destroy()
        main.Visible = true
    end)
end)

addButton.MouseButton1Click:Connect(function()
    if not selected then
        status.Text = "Select position first!"
        return
    end

    local value = tonumber(delayBox.Text)

    if not value or value <= 0 then
        status.Text = "Invalid interval!"
        return
    end

    local interval = value * (seconds and 1 or 60)

    table.insert(steps, {
        x = selected.X,
        y = selected.Y,
        interval = interval,
        nextTap = os.clock() + interval,
        deleted = false
    })

    save()
    refresh()
end)

-- Safe tap using tested touch events
local function tap(x, y)
    if touchBusy then return end
    touchBusy = true

    local started = pcall(function()
    
activeX, activeY = x, y
VIM:SendTouchEvent(1, 0, x, y)
activeTouch = true

    end)

    if started then
        task.wait(0.12)
    end

    releaseTouch()
    touchBusy = false
end

local function startAll()
    if running then return end
    if #steps == 0 then
        status.Text = "Add a tap first!"
        return
    end

    running = true
    generation = generation + 1
    local currentGeneration = generation

    for _, s in ipairs(steps) do
        s.nextTap = os.clock() + s.interval
    end

    save()
    refresh()

    task.spawn(function()
        while running
            and generation == currentGeneration do

            local now = os.clock()

            for _, s in ipairs(steps) do
                if not s.deleted
                    and now >= s.nextTap then

                    s.nextTap = now + s.interval
                    task.spawn(tap, s.x, s.y)
                end
            end

            task.wait(0.05)
        end
    end)
end

startButton.MouseButton1Click:Connect(function()
    if running then
        stopAll()
        refresh()
    else
        startAll()
    end
end)

clearButton.MouseButton1Click:Connect(function()
    stopAll()
    steps = {}
    selected = nil
    positionLabel.Text = "Position: Not selected"
    save()
    refresh()
end)

refresh()

if shouldResume and #steps > 0 then
    task.delay(2, function()
        if gui and gui.Parent then
            startAll()
        end
    end)
end

print("JOJOBA HUB V3 loaded")
