-- COR AudioPeripheral Controller
-- Execute langsung di Delta pakai loadstring

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- CORE FUNCTIONS
-- =====================

local function getMyTruck()
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("Model") then
            local ownerVal = obj:FindFirstChild("Owner") or obj:FindFirstChildWhichIsA("StringValue")
            if ownerVal and (ownerVal.Value == LocalPlayer.Name or ownerVal.Value == tostring(LocalPlayer.UserId)) then
                return obj
            end
            if string.find(obj.Name:lower(), LocalPlayer.Name:lower()) then
                return obj
            end
        end
    end
    return nil
end

local function getPeripherals(truck)
    local peripherals = {}
    if not truck then return peripherals end
    for _, obj in ipairs(truck:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, n in ipairs({"CR4400","DR260","NR13004MK3","PA1600W","SongPicker","VUMTR32"}) do
                if string.find(obj.Name, n) then
                    table.insert(peripherals, obj)
                    break
                end
            end
        end
    end
    return peripherals
end

local function setPower(peripheral, state)
    pcall(function()
        peripheral:SetAttribute("PowerState", state)
        local pw = peripheral:FindFirstChild("Power") or peripheral:FindFirstChild("IsOn")
        if pw and pw:IsA("BoolValue") then pw.Value = state end
        local re = game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent", true)
        if re then re:FireServer("SetPower", peripheral, state) end
    end)
end

local function setKnobValue(peripheral, value)
    pcall(function()
        local knob = peripheral:FindFirstChild("Volume")
            or peripheral:FindFirstChild("Gain")
            or peripheral:FindFirstChild("KnobValue")
            or peripheral:FindFirstChildWhichIsA("NumberValue")
        if knob then knob.Value = value end
        local re = game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent", true)
        if re then re:FireServer("SetKnob", peripheral, value) end
    end)
end

-- =====================
-- GUI
-- =====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "COR_HUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 330)
MainFrame.Position = UDim2.new(0, 40, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "COR Controller"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Drag window
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 24)
StatusLabel.Position = UDim2.new(0, 10, 0, 44)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Truck: scanning..."
StatusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Power button
local PowerBtn = Instance.new("TextButton")
PowerBtn.Size = UDim2.new(1, -20, 0, 38)
PowerBtn.Position = UDim2.new(0, 10, 0, 76)
PowerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PowerBtn.Text = "Power ON"
PowerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerBtn.TextSize = 13
PowerBtn.Font = Enum.Font.GothamBold
PowerBtn.BorderSizePixel = 0
PowerBtn.Parent = MainFrame
Instance.new("UICorner", PowerBtn).CornerRadius = UDim.new(0, 6)

-- Knob label
local KnobLabel = Instance.new("TextLabel")
KnobLabel.Size = UDim2.new(1, -20, 0, 20)
KnobLabel.Position = UDim2.new(0, 10, 0, 126)
KnobLabel.BackgroundTransparency = 1
KnobLabel.Text = "Volume (drag kanan = full)"
KnobLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
KnobLabel.TextSize = 12
KnobLabel.Font = Enum.Font.Gotham
KnobLabel.TextXAlignment = Enum.TextXAlignment.Left
KnobLabel.Parent = MainFrame

-- Slider track
local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -20, 0, 14)
SliderTrack.Position = UDim2.new(0, 10, 0, 152)
SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = MainFrame
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(0, 7)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 80, 220)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 7)

local KnobHandle = Instance.new("Frame")
KnobHandle.Size = UDim2.new(0, 22, 0, 22)
KnobHandle.Position = UDim2.new(1, -11, 0.5, -11)
KnobHandle.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
KnobHandle.BorderSizePixel = 0
KnobHandle.ZIndex = 2
KnobHandle.Parent = SliderFill
Instance.new("UICorner", KnobHandle).CornerRadius = UDim.new(1, 0)

-- Knob value
local KnobValueLabel = Instance.new("TextLabel")
KnobValueLabel.Size = UDim2.new(1, -20, 0, 20)
KnobValueLabel.Position = UDim2.new(0, 10, 0, 174)
KnobValueLabel.BackgroundTransparency = 1
KnobValueLabel.Text = "Value: 0%"
KnobValueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
KnobValueLabel.TextSize = 11
KnobValueLabel.Font = Enum.Font.Gotham
KnobValueLabel.TextXAlignment = Enum.TextXAlignment.Left
KnobValueLabel.Parent = MainFrame

-- Full button
local FullBtn = Instance.new("TextButton")
FullBtn.Size = UDim2.new(1, -20, 0, 34)
FullBtn.Position = UDim2.new(0, 10, 0, 202)
FullBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 160)
FullBtn.Text = "Set Full (100%)"
FullBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FullBtn.TextSize = 13
FullBtn.Font = Enum.Font.GothamBold
FullBtn.BorderSizePixel = 0
FullBtn.Parent = MainFrame
Instance.new("UICorner", FullBtn).CornerRadius = UDim.new(0, 6)

-- Log
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -20, 0, 70)
LogLabel.Position = UDim2.new(0, 10, 0, 248)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "Log: idle"
LogLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
LogLabel.TextSize = 10
LogLabel.Font = Enum.Font.Code
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.TextWrapped = true
LogLabel.Parent = MainFrame

local function log(msg) LogLabel.Text = "Log: "..msg end

-- Slider drag
local sliderDragging = false

local function updateSlider(inputPos)
    local abs = SliderTrack.AbsolutePosition
    local sz = SliderTrack.AbsoluteSize
    local ratio = math.clamp((inputPos.X - abs.X) / sz.X, 0, 1)
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    KnobValueLabel.Text = string.format("Value: %d%%", math.floor(ratio * 100))
    local truck = getMyTruck()
    if truck then
        for _, p in ipairs(getPeripherals(truck)) do
            setKnobValue(p, ratio)
        end
    end
end

SliderTrack.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true; updateSlider(i.Position)
    end
end)
KnobHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if sliderDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(i.Position)
    end
end)

-- Power logic
local powerState = false
PowerBtn.MouseButton1Click:Connect(function()
    local truck = getMyTruck()
    if not truck then log("truck tidak ditemukan!") StatusLabel.Text = "Truck: tidak ditemukan" return end
    powerState = not powerState
    local peripherals = getPeripherals(truck)
    for _, p in ipairs(peripherals) do setPower(p, powerState) end
    if powerState then
        PowerBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
        PowerBtn.Text = "Power OFF"
        log("ON — "..#peripherals.." peripheral")
    else
        PowerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        PowerBtn.Text = "Power ON"
        log("power OFF")
    end
end)

-- Full logic
FullBtn.MouseButton1Click:Connect(function()
    local truck = getMyTruck()
    if not truck then log("truck tidak ditemukan!") return end
    SliderFill.Size = UDim2.new(1, 0, 1, 0)
    KnobValueLabel.Text = "Value: 100%"
    for _, p in ipairs(getPeripherals(truck)) do setKnobValue(p, 1.0) end
    log("knob full 100%")
end)

-- Scan truck loop
task.spawn(function()
    while task.wait(3) do
        local truck = getMyTruck()
        StatusLabel.Text = truck and ("Truck: "..truck.Name) or "Truck: scanning..."
    end
end)

log("siap")
