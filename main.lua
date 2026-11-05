
-- JOJOBA HUB | AUTO CLICKER
-- Red & Blue Edition

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local parent = player:WaitForChild("PlayerGui")

local FILE = "jojoba_clicker_config.json"

if _G.JOJOBA_CLICKER_STOP then
    _G.JOJOBA_CLICKER_STOP()
end

local running = false
local alive = true
local steps = {}
local current = 1
local savedEnabled = false

local function save()
    if type(writefile) == "function" then
        pcall(function()
            writefile(FILE, HttpService:JSONEncode({
                steps = steps,
                enabled = running
            }))
        end)
    end
end

local function load()
    if type(isfile) == "function"
        and type(readfile) == "function" then
        local ok, result = pcall(function()
            if isfile(FILE) then
                return HttpService:JSONDecode(
                    readfile(FILE)
                )
            end
        end)

        if ok and type(result) == "table" then
            if type(result.steps) == "table" then
                steps = result.steps
            end
            savedEnabled = result.enabled == true
        end
    end
end

load()

local old = parent:FindFirstChild("JOJOBA_Clicker")
if old then old:Destroy() end

local function make(class, props, parentObj)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parentObj
    return obj
end

local bg = Color3.fromRGB(16,19,34)
local panel = Color3.fromRGB(29,36,58)
local blue = Color3.fromRGB(42,118,245)
local red = Color3.fromRGB(220,51,75)
local white = Color3.fromRGB(242,246,255)

local gui = make("ScreenGui", {
    Name = "JOJOBA_Clicker",
    ResetOnSpawn = false
}, parent)

local main = make("Frame", {
    Size = UDim2.fromOffset(340,435),
    Position = UDim2.new(.5,-170,.5,-217),
    BackgroundColor3 = bg,
    Active = true,
    Draggable = true
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0,13)
}, main)

make("UIStroke", {
    Color = blue,
    Thickness = 2
}, main)

make("TextLabel", {
    Text = "JOJOBA HUB | AUTO CLICKER",
    TextColor3 = white,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-55,0,44)
}, main)

local minimize = make("TextButton", {
    Text = "-",
    TextColor3 = white,
    BackgroundColor3 = red,
    Position = UDim2.new(1,-42,0,7),
    Size = UDim2.fromOffset(32,30)
}, main)

local reopen = make("TextButton", {
    Text = "JOJOBA",
    TextColor3 = white,
    BackgroundColor3 = blue,
    Position = UDim2.fromOffset(12,125),
    Size = UDim2.fromOffset(90,38),
    Visible = false,
    Active = true,
    Draggable = true
}, gui)

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

local list = make("ScrollingFrame", {
    Position = UDim2.fromOffset(12,52),
    Size = UDim2.new(1,-24,1,-110),
    BackgroundTransparency = 1,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.fromOffset(0,0),
    ScrollBarThickness = 3
}, main)

make("UIListLayout", {
    Padding = UDim.new(0,7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, list)

local status = make("TextLabel", {
    Text = "Ready | Add steps, then START",
    TextColor3 = white,
    TextSize = 11,
    TextWrapped = true,
    BackgroundTransparency = 1,
    Position = UDim2.new(0,8,1,-53),
    Size = UDim2.new(1,-16,0,35)
}, main)

local function button(label, callback)
    local b = make("TextButton", {
        Text = label,
        TextColor3 = white,
        TextSize = 12,
        BackgroundColor3 = blue,
        Size = UDim2.new(1,-5,0,32)
    }, list)

    make("UICorner", {
        CornerRadius = UDim.new(0,7)
    }, b)

    b.MouseButton1Click:Connect(callback)
    return b
end

local function input(label, default)
    local wrap = make("Frame", {
        Size = UDim2.new(1,-5,0,56),
        BackgroundColor3 = panel
    }, list)

    make("UICorner", {
        CornerRadius = UDim.new(0,7)
    }, wrap)

    make("TextLabel", {
        Text = label,
        TextColor3 = white,
        TextSize = 12,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7,2),
        Size = UDim2.new(1,-14,0,20),
        TextXAlignment = Enum.TextXAlignment.Left
    }, wrap)

    local tb = make("TextBox", {
        Text = default,
        TextColor3 = white,
        TextSize = 13,
        ClearTextOnFocus = false,
        BackgroundColor3 = bg,
        Position = UDim2.fromOffset(7,25),
        Size = UDim2.new(1,-14,0,26)
    }, wrap)

    make("UICorner", {
        CornerRadius = UDim.new(0,5)
    }, tb)

    return tb
end

local xInput = input("X Position (pixels)", "500")
local yInput = input("Y Position (pixels)", "350")
local delayInput = input(
    "Wait BEFORE tap (minutes)", "1"
)

local function tap(x,y)
    x = math.floor(x)
    y = math.floor(y)

    VIM:SendMouseButtonEvent(
        x,y,0,true,game,0
    )

    task.wait(0.08)

    VIM:SendMouseButtonEvent(
        x,y,0,false,game,0
    )
end

local refresh

refresh = function()
    for _,child in ipairs(list:GetChildren()) do
        if child.Name == "StepRow" then
            child:Destroy()
        end
    end

    for i,step in ipairs(steps) do
        local index = i

        local row = make("Frame", {
            Name = "StepRow",
            Size = UDim2.new(1,-5,0,35),
            BackgroundColor3 = panel
        }, list)

        make("TextLabel", {
            Text = string.format(
                "%d. (%d,%d) after %.2f min",
                i,
                tonumber(step.x) or 0,
                tonumber(step.y) or 0,
                tonumber(step.minutes) or 0
            ),
            TextColor3 = white,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(7,0),
            Size = UDim2.new(1,-60,1,0)
        }, row)

        local del = make("TextButton", {
            Text = "X",
            TextColor3 = white,
            BackgroundColor3 = red,
            Position = UDim2.new(1,-45,0,4),
            Size = UDim2.fromOffset(38,27)
        }, row)

        del.MouseButton1Click:Connect(function()
            running = false
            table.remove(steps,index)
            current = 1
            save()
            refresh()
        end)
    end
end

button("ADD TAP STEP", function()
    local x = tonumber(xInput.Text)
    local y = tonumber(yInput.Text)
    local m = tonumber(delayInput.Text)

    if not x or not y or not m or m < 0 then
        status.Text = "Invalid coordinates or minutes"
        return
    end

    table.insert(steps, {
        x = x,
        y = y,
        minutes = m
    })

    save()
    refresh()
    status.Text = "Added step " .. #steps
end)

local start = button("START / STOP", function()
    if #steps == 0 then
        status.Text = "Add at least one step"
        return
    end

    running = not running
    current = 1
    save()

    status.Text = running
        and "RUNNING | Repeating sequence"
        or "STOPPED"
end)

start.BackgroundColor3 = red

button("CLEAR ALL STEPS", function()
    running = false
    steps = {}
    current = 1
    save()
    refresh()
    status.Text = "Steps cleared"
end)

refresh()

_G.JOJOBA_CLICKER_STOP = function()
    alive = false
    running = false
    gui:Destroy()
end

if savedEnabled and #steps > 0 then
    running = true
    status.Text = "AUTO-RESUMED"
end

task.spawn(function()
    while alive do
        if running and #steps > 0 then
            if current > #steps then
                current = 1
            end

            local step = steps[current]

            if step then
                local duration = math.max(
                    0,
                    tonumber(step.minutes) or 0
                ) * 60

                local elapsed = 0

                while alive and running
                    and elapsed < duration do

                    local delta = math.min(
                        0.25,
                        duration - elapsed
                    )

                    task.wait(delta)
                    elapsed = elapsed + delta
                end

                if alive and running then
                    local ok,err = pcall(
                        tap,
                        tonumber(step.x) or 0,
                        tonumber(step.y) or 0
                    )

                    if not ok then
                        running = false
                        status.Text = "Tap failed: "
                            .. tostring(err)
                        save()
                    else
                        current = current + 1
                    end
                end
            end
        else
            task.wait(0.2)
        end
    end
end)

print("JOJOBA HUB Auto Clicker loaded!")
