
-- JOJOBA HUB | AUTO CLICKER V2
-- Independent tap timers and touch position picker

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("JOJOBA_AUTOCLICKER")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "JOJOBA_AUTOCLICKER"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local steps = {}
local running = false
local picking = false
local generation = 0

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local bg = Color3.fromRGB(12, 17, 30)
local panel = Color3.fromRGB(24, 31, 49)
local blue = Color3.fromRGB(40, 125, 255)
local red = Color3.fromRGB(235, 55, 75)
local white = Color3.fromRGB(245, 245, 255)

local main = make("Frame", gui, {
    Size = UDim2.fromOffset(310, 440),
    Position = UDim2.new(0.5, -155, 0.5, -220),
    BackgroundColor3 = bg,
    Active = true,
    Draggable = true
})
corner(main, 12)

local function button(parent, text, y, color, height)
    local b = make("TextButton", parent, {
        Size = UDim2.new(1, -20, 0, height or 36),
        Position = UDim2.fromOffset(10, y),
        BackgroundColor3 = color,
        Text = text,
        TextColor3 = white,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    corner(b, 7)
    return b
end

local title = make("TextLabel", main, {
    Size = UDim2.new(1, -55, 0, 42),
    Position = UDim2.fromOffset(10, 3),
    BackgroundTransparency = 1,
    Text = "JOJOBA HUB | AUTO CLICKER",
    TextColor3 = white,
    TextSize = 14,
    Font = Enum.Font.GothamBold
})

local close = make("TextButton", main, {
    Size = UDim2.fromOffset(35, 30),
    Position = UDim2.new(1, -40, 0, 7),
    BackgroundColor3 = red,
    Text = "X",
    TextColor3 = white
})
corner(close, 6)

local selected = nil

local pick = button(main, "SELECT TAP POSITION", 52, blue)

local positionLabel = make("TextLabel", main, {
    Size = UDim2.new(1, -20, 0, 24),
    Position = UDim2.fromOffset(10, 92),
    BackgroundTransparency = 1,
    Text = "Position: Not selected",
    TextColor3 = white,
    TextSize = 12
})

local delayBox = make("TextBox", main, {
    Size = UDim2.new(0.6, -15, 0, 35),
    Position = UDim2.fromOffset(10, 121),
    BackgroundColor3 = panel,
    Text = "1",
    PlaceholderText = "Interval",
    TextColor3 = white,
    TextSize = 15,
    ClearTextOnFocus = false
})
corner(delayBox, 7)

local unit = make("TextButton", main, {
    Size = UDim2.new(0.4, -15, 0, 35),
    Position = UDim2.new(0.6, 5, 0, 121),
    BackgroundColor3 = blue,
    Text = "MINUTES",
    TextColor3 = white,
    TextSize = 12
})
corner(unit, 7)

local useSeconds = false
unit.MouseButton1Click:Connect(function()
    useSeconds = not useSeconds
    unit.Text = useSeconds and "SECONDS" or "MINUTES"
end)

local add = button(main, "+ ADD TAP", 166, blue)
local toggle = button(main, "START ALL", 209, red)
local clear = button(main, "CLEAR ALL", 252, panel)

local list = make("ScrollingFrame", main, {
    Size = UDim2.new(1, -20, 0, 108),
    Position = UDim2.fromOffset(10, 296),
    BackgroundColor3 = panel,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new()
})
corner(list, 7)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 8
    )
end)

local status = make("TextLabel", main, {
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.fromOffset(10, 409),
    BackgroundTransparency = 1,
    Text = "Ready | 0 taps",
    TextColor3 = white,
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
            BackgroundColor3 = bg
        })
        corner(row, 6)

        make("TextLabel", row, {
            Size = UDim2.new(1, -44, 1, 0),
            BackgroundTransparency = 1,
            Text = string.format(
                "#%d  (%d,%d)  Every %gs",
                i, step.x, step.y, step.interval
            ),
            TextColor3 = white,
            TextSize = 11
        })

        local del = make("TextButton", row, {
            Size = UDim2.fromOffset(32, 30),
            Position = UDim2.new(1, -35, 0, 4),
            BackgroundColor3 = red,
            Text = "X",
            TextColor3 = white
        })
        corner(del, 5)

        del.MouseButton1Click:Connect(function()
            step.deleted = true
            table.remove(steps, i)
            refresh()
        end)
    end

    status.Text = (running and "Running" or "Ready")
        .. " | " .. #steps .. " taps"
end

local overlay

pick.MouseButton1Click:Connect(function()
    if picking then return end
    picking = true
    main.Visible = false

    overlay = make("TextButton", gui, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.75,
        Text = "TAP THE POSITION YOU WANT",
        TextColor3 = white,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 50
    })

    overlay.InputBegan:Connect(function(input)
        if not picking then return end
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        picking = false
        selected = Vector2.new(
            math.floor(input.Position.X),
            math.floor(input.Position.Y)
        )

        positionLabel.Text = string.format(
            "Position: X=%d Y=%d",
            selected.X, selected.Y
        )

        overlay:Destroy()
        overlay = nil
        main.Visible = true
    end)
end)

add.MouseButton1Click:Connect(function()
    if not selected then
        status.Text = "Select a position first!"
        return
    end

    local value = tonumber(delayBox.Text)
    if not value or value <= 0 then
        status.Text = "Enter a valid interval!"
        return
    end

    local interval = value * (useSeconds and 1 or 60)

    table.insert(steps, {
        x = selected.X,
        y = selected.Y,
        interval = interval,
        nextTap = os.clock() + interval,
        deleted = false
    })

    refresh()
end)

local function tap(x, y)
    local ok, err = pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.06)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    if not ok then
        warn("JOJOBA tap failed:", err)
    end
end

toggle.MouseButton1Click:Connect(function()
    running = not running
    generation = generation + 1
    local myGeneration = generation

    toggle.Text = running and "STOP ALL" or "START ALL"

    if running then
        for _, step in ipairs(steps) do
            step.nextTap = os.clock() + step.interval
        end

        task.spawn(function()
            while running and generation == myGeneration do
                local now = os.clock()

                for _, step in ipairs(steps) do
                    if not step.deleted and now >= step.nextTap then
                        step.nextTap = now + step.interval
                        task.spawn(tap, step.x, step.y)
                    end
                end

                task.wait(0.05)
            end
        end)
    end

    refresh()
end)

clear.MouseButton1Click:Connect(function()
    running = false
    generation = generation + 1
    steps = {}
    selected = nil
    toggle.Text = "START ALL"
    positionLabel.Text = "Position: Not selected"
    refresh()
end)

close.MouseButton1Click:Connect(function()
    running = false
    generation = generation + 1
    gui:Destroy()
end)

refresh()
print("JOJOBA HUB AUTO CLICKER V2 loaded")
