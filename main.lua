
-- JOJOBA HUB | Summer Hunt
-- Version 0.1 - UI Prototype

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local parent = player:WaitForChild("PlayerGui")

local old = parent:FindFirstChild("JOJOBA_HUB")
if old then old:Destroy() end

local Settings = {
    AutoFarm = false,
    MatchmakingOnly = true,
    AutoPlace = false,
    AutoUpgrade = false,
    AutoModifiers = false,
    StopOnSecretPortal = true,
    Preferred = {},
    Avoid = {},
    Fallback = "Pause"
}

local Colors = {
    Background = Color3.fromRGB(12, 17, 30),
    Panel = Color3.fromRGB(24, 31, 49),
    Red = Color3.fromRGB(235, 50, 70),
    Blue = Color3.fromRGB(45, 125, 255),
    White = Color3.fromRGB(245, 247, 255)
}

local function create(className, properties, parentObject)
    local object = Instance.new(className)
    for key, value in pairs(properties) do
        object[key] = value
    end
    object.Parent = parentObject
    return object
end

local gui = create("ScreenGui", {
    Name = "JOJOBA_HUB",
    ResetOnSpawn = false
}, parent)

local main = create("Frame", {
    Size = UDim2.fromOffset(350, 450),
    Position = UDim2.new(0.5, -175, 0.5, -225),
    BackgroundColor3 = Colors.Background,
    Active = true,
    Draggable = true
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 14)
}, main)

create("UIStroke", {
    Color = Colors.Blue,
    Thickness = 2
}, main)

create("TextLabel", {
    Size = UDim2.new(1, -55, 0, 48),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "JOJOBA HUB | SUMMER HUNT",
    TextColor3 = Colors.White,
    TextSize = 17,
    Font = Enum.Font.GothamBold
}, main)

local hide = create("TextButton", {
    Size = UDim2.fromOffset(35, 30),
    Position = UDim2.new(1, -43, 0, 9),
    Text = "-",
    TextColor3 = Colors.White,
    BackgroundColor3 = Colors.Red
}, main)

local reopen = create("TextButton", {
    Size = UDim2.fromOffset(110, 40),
    Position = UDim2.fromOffset(15, 130),
    Text = "JOJOBA HUB",
    TextColor3 = Colors.White,
    BackgroundColor3 = Colors.Blue,
    Visible = false,
    Active = true,
    Draggable = true
}, gui)

hide.MouseButton1Click:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

local scroll = create("ScrollingFrame", {
    Position = UDim2.fromOffset(12, 55),
    Size = UDim2.new(1, -24, 1, -100),
    BackgroundTransparency = 1,
    ScrollBarThickness = 4,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.fromOffset(0, 0)
}, main)

create("UIListLayout", {
    Padding = UDim.new(0, 7)
}, scroll)

local status = create("TextLabel", {
    Position = UDim2.new(0, 10, 1, -43),
    Size = UDim2.new(1, -20, 0, 35),
    BackgroundTransparency = 1,
    Text = "JOJOBA HUB READY | UI ONLY",
    TextColor3 = Colors.White,
    TextSize = 11,
    TextWrapped = true
}, main)

local function addRow(label, initial, callback)
    local frame = create("Frame", {
        Size = UDim2.new(1, -5, 0, 40),
        BackgroundColor3 = Colors.Panel
    }, scroll)

    create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, frame)

    create("TextLabel", {
        Size = UDim2.new(0.63, 0, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Colors.White,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local button = create("TextButton", {
        Size = UDim2.new(0.3, 0, 0, 30),
        Position = UDim2.new(0.68, 0, 0, 5),
        BackgroundColor3 = Colors.Blue,
        TextColor3 = Colors.White,
        Text = initial,
        TextSize = 12
    }, frame)

    create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, button)

    button.MouseButton1Click:Connect(function()
        callback(button)
    end)

    return button
end

local function addToggle(label, key)
    local button = addRow(
        label,
        Settings[key] and "ON" or "OFF",
        function(b)
            Settings[key] = not Settings[key]
            b.Text = Settings[key] and "ON" or "OFF"
            b.BackgroundColor3 =
                Settings[key] and Colors.Blue or Colors.Red
        end
    )

    button.BackgroundColor3 =
        Settings[key] and Colors.Blue or Colors.Red
end

addToggle("Auto Farm", "AutoFarm")
addToggle("Matchmaking Only", "MatchmakingOnly")
addToggle("Auto Place", "AutoPlace")
addToggle("Auto Upgrade", "AutoUpgrade")
addToggle("Auto Modifiers", "AutoModifiers")
addToggle("Stop on Secret Portal", "StopOnSecretPortal")

local function addModifierInput(label, key)
    local frame = create("Frame", {
        Size = UDim2.new(1, -5, 0, 72),
        BackgroundColor3 = Colors.Panel
    }, scroll)

    create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, frame)

    create("TextLabel", {
        Size = UDim2.new(1, -15, 0, 28),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Colors.White,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local input = create("TextBox", {
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.fromOffset(8, 32),
        BackgroundColor3 = Colors.Background,
        TextColor3 = Colors.White,
        PlaceholderText = "Modifier 1, Modifier 2",
        Text = "",
        TextSize = 12,
        ClearTextOnFocus = false
    }, frame)

    create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, input)

    input.FocusLost:Connect(function()
        local names = {}

        for name in input.Text:gmatch("[^,]+") do
            name = name:match("^%s*(.-)%s*$")
            if name ~= "" then
                table.insert(names, name)
            end
        end

        Settings[key] = names
        status.Text = key .. ": "
            .. tostring(#names) .. " selected"
    end)
end

addModifierInput("Preferred Modifiers", "Preferred")
addModifierInput("Avoid Modifiers", "Avoid")

addRow("Fallback", "PAUSE", function(button)
    if Settings.Fallback == "Pause" then
        Settings.Fallback = "FirstAllowed"
        button.Text = "ALLOWED"
    else
        Settings.Fallback = "Pause"
        button.Text = "PAUSE"
    end
end)

addRow("Check Status", "CHECK", function()
    status.Text = "Settings ready | Automation not connected"
end)

print("JOJOBA HUB UI loaded successfully!")
