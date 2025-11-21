repeat wait() until game:IsLoaded()
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local AimbotEnabled = false
local ESPEnabled = false
local IgnoreTeammates = true
local Target = nil
local ESPs = {}  -- Lưu ESP của từng người

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "chó chết hub",
    LoadingTitle = "Đang load script chó sài...",
    LoadingSubtitle = "me may beo 😂😂😂😂😂😂😂😂😂😂"
})

local MainTab = Window:CreateTab("Main")
local StatusLabel = MainTab:CreateLabel("Trạng thái: Tắt")

MainTab:CreateToggle({
    Name = "Bật Aimbot",
    CurrentValue = false,
    Callback = function(v)
        AimbotEnabled = v
        StatusLabel:Set(v and "Trạng thái: BẬT " or "Trạng thái: TẮT")
    end
})

MainTab:CreateToggle({
    Name = "Bật ESP (Tất cả người chơi)",
    CurrentValue = false,
    Callback = function(v) ESPEnabled = v end
})

MainTab:CreateToggle({
    Name = "Không Aim Đồng Đội",
    CurrentValue = false,
    Callback = function(v) IgnoreTeammates = v end
})

-- Kiểm tra xem có thấy được không
local function IsVisible(plr)
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local target = plr.Character.Head.Position
    local direction = target - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(plr.Character)
end

-- Tìm địch gần nhất + thấy được
local function GetClosestVisible()
    local closest = nil
    local dist = math.huge
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if IgnoreTeammates and plr.Team == LocalPlayer.Team then continue end
            if not IsVisible(plr) then continue end
            local d = (Camera.CFrame.Position - plr.Character.Head.Position).Magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end
    return closest
end

-- TẠO ESP SIÊU ĐẸP (FIX HP + TẤT CẢ NGƯỜI CHƠI)
local function CreateESP(plr)
    if ESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end

    local char = plr.Character

    -- Highlight đổi màu theo visible
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 0)  -- Xanh = thấy được
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = char

    -- Billboard tên + HP
    local bill = Instance.new("BillboardGui")
    bill.Name = "RealESP"
    bill.Adornee = char.Head
    bill.Size = UDim2.new(0, 200, 0, 70)
    bill.StudsOffset = Vector3.new(0, 3.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = char.Head

    local nameLabel = Instance.new("TextLabel", bill)
    nameLabel.Size = UDim2.new(1, 0, 0.45, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.DisplayName or plr.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold

    local hpLabel = Instance.new("TextLabel", bill)
    hpLabel.Size = UDim2.new(1, 0, 0.45, 0)
    hpLabel.Position = UDim2.new(0, 0, 0.45, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100"
    hpLabel.TextColor3 = Color3.new(0, 1, 0)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    hpLabel.TextScaled = true
    hpLabel.Font = Enum.Font.Gotham

    -- Cập nhật HP + màu highlight theo visible
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hpLabel.Text = "HP: " .. math.floor(hum.Health)
        hum.HealthChanged:Connect(function(h)
            hpLabel.Text = "HP: " .. math.floor(h)
        end)
    end

    ESPs[plr] = {highlight = highlight, billboard = bill}
end

-- Xóa ESP
local function RemoveESP(plr)
    if ESPs[plr] then
        if ESPs[plr].highlight then ESPs[plr].highlight:Destroy() end
        if ESPs[plr].billboard then ESPs[plr].billboard:Destroy() end
        ESPs[plr] = nil
    end
end

-- Cập nhật ESP cho tất cả người chơi
local function UpdateESP()
    for _, plr in Players:GetPlayers() do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            CreateESP(plr)
            if ESPs[plr] and ESPs[plr].highlight then
                ESPs[plr].highlight.FillColor = IsVisible(plr) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
            end
        else
            RemoveESP(plr)
        end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    else
        for plr, _ in pairs(ESPs) do RemoveESP(plr) end
        ESPs = {}
    end

    if AimbotEnabled then
        Target = GetClosestVisible()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

-- Tự động tạo ESP khi người chơi respawn hoặc vào game
for _, plr in Players:GetPlayers() do
    plr.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then CreateESP(plr) end
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then CreateESP(plr) end
    end)
end)
