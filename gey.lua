-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local AimbotEnabled = false
local Target = nil
local ESPEnabled = false
local IgnoreTeammates = true
local OrbitEnabled = false
local OrbitSpeed = 0.1 -- Default speed (rad/frame)
local OrbitDistance = 5.0 -- Default distance
local OrbitTarget = nil
local OrbitAngle = 0.0
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Aim rác",
    LoadingTitle = "memaybeo",
    LoadingSubtitle = "🥵",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AimbotScript",
        FileName = "AimbotConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelinkyetlol",
        RememberJoins = true
    }
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

local AimbotToggle = AimbotTab:CreateToggle({
    Name = "Bật Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        AimbotEnabled = Value
        if AimbotEnabled then
            Target = GetClosestPlayer()
            StatusLabel:Set("Trạng thái: Bật")
        else
            Target = nil
            RemoveHighlight(Target)
            StatusLabel:Set("Trạng thái: Tắt")
        end
    end
})

local StatusLabel = AimbotTab:CreateLabel("Trạng thái: Tắt")

local IgnoreTeammatesToggle = AimbotTab:CreateToggle({
    Name = "đéo aim ng chung team",
    CurrentValue = true,
    Flag = "IgnoreTeammatesToggle",
    Callback = function(Value)
        IgnoreTeammates = Value
    end
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPToggle = ESPTab:CreateToggle({
    Name = "Bật ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESPEnabled = Value
        if not ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                RemoveESP(player)
            end
        end
    end
})

-- Orbit Tab
local OrbitTab = Window:CreateTab("Orbit", 4483362458)

local OrbitToggle = OrbitTab:CreateToggle({
    Name = "Bật Orbit",
    CurrentValue = false,
    Flag = "OrbitToggle",
    Callback = function(Value)
        OrbitEnabled = Value
        if OrbitEnabled then
            OrbitTarget = GetClosestPlayer()
            if OrbitTarget then
                TeleportToTarget()
            end
        else
            OrbitTarget = nil
        end
    end
})

local OrbitSpeedSlider = OrbitTab:CreateSlider({
    Name = "Tốc độ Quay",
    Range = {0.01, 1.0},
    Increment = 0.01,
    Suffix = "rad/frame",
    CurrentValue = 0.1,
    Flag = "OrbitSpeedSlider",
    Callback = function(Value)
        OrbitSpeed = Value
    end
})

local OrbitDistanceSlider = OrbitTab:CreateSlider({
    Name = "Khoảng Cách",
    Range = {1.0, 50.0},
    Increment = 0.5,
    Suffix = "units",
    CurrentValue = 5.0,
    Flag = "OrbitDistanceSlider",
    Callback = function(Value)
        OrbitDistance = Value
    end
})

-- Aimbot Functions
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = 500
    local localTeam = LocalPlayer and LocalPlayer.Team
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            local playerTeam = player.Team
            if not IgnoreTeammates or (not localTeam or not playerTeam) or (localTeam and playerTeam and localTeam ~= playerTeam) then
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function IsTargetVisible(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local origin = Camera.CFrame.Position
        local direction = (target.Character.Head.Position - origin).Unit
        local ray = Ray.new(origin, direction * 500)
        local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        return hit == nil or hit:IsDescendantOf(target.Character)
    end
    return false
end

local function AimAtTarget()
    if AimbotEnabled and Target and Target.Character and Target.Character:FindFirstChild("Head") and IsTargetVisible(Target) then
        local targetPos = Target.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
end

local function CheckTargetDeathOrSwitch()
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        if Target.Character.Humanoid.Health <= 0 or not Target.Character:FindFirstChild("Head") then
            local newTarget = GetClosestPlayer()
            if newTarget and IsTargetVisible(newTarget) then
                Target = newTarget
                StatusLabel:Set("Trạng thái: Bật (Target: " .. Target.Name .. ")")
            else
                Target = nil
                StatusLabel:Set("Trạng thái: Đang tìm target...")
            end
        else
            local newTarget = GetClosestPlayer()
            if newTarget and newTarget ~= Target then
                local currentDistance = Target and Target.Character and Target.Character:FindFirstChild("Head") and (Camera.CFrame.Position - Target.Character.Head.Position).Magnitude or math.huge
                local newDistance = newTarget.Character and newTarget.Character:FindFirstChild("Head") and (Camera.CFrame.Position - newTarget.Character.Head.Position).Magnitude or math.huge
                if newDistance < currentDistance and IsTargetVisible(newTarget) then
                    Target = newTarget
                    StatusLabel:Set("Trạng thái: Bật (Target: " .. Target.Name .. ")")
                end
            end
        end
    else
        local newTarget = GetClosestPlayer()
        if newTarget and IsTargetVisible(newTarget) then
            Target = newTarget
            StatusLabel:Set("Trạng thái: Bật (Target: " .. Target.Name .. ")")
        else
            StatusLabel:Set("Trạng thái: Đang tìm target...")
        end
    end
end

-- Highlight Functions
local function AddHighlight(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 215, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        return highlight
    end
    return nil
end

local function RemoveHighlight(player)
    if player.Character then
        for _, obj in pairs(player.Character:GetChildren()) do
            if obj:IsA("Highlight") then
                obj:Destroy()
            end
        end
    end
end

-- ESP Functions
local function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("ESP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Parent = player.Character
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Parent = billboard
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "HP: 100"
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextSize = 12

        local outline = Instance.new("BoxHandleAdornment")
        outline.Name = "ESPOutline"
        outline.Parent = player.Character
        outline.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        outline.Size = player.Character:FindFirstChild("HumanoidRootPart").Size + Vector3.new(0.2, 0.2, 0.2)
        outline.Transparency = 0.7
        outline.Color3 = Color3.fromRGB(255, 165, 0) -- Viền cam
        outline.AlwaysOnTop = true
        outline.ZIndex = 1

        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                if health > 0 then
                    healthLabel.Text = "HP: " .. math.floor(health)
                    healthLabel.TextColor3 = Color3.fromRGB(255 - (health / humanoid.MaxHealth * 255), health / humanoid.MaxHealth * 255, 0)
                else
                    healthLabel.Text = "HP: 0"
                    healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end

        player.Character.AncestryChanged:Connect(function()
            if not player.Character or not player.Character.Parent then
                billboard:Destroy()
                outline:Destroy()
            end
        end)

        player.CharacterAdded:Connect(function(char)
            wait(0.1)
            CreateESP(player)
        end)
    end
end

local function RemoveESP(player)
    if player.Character and player.Character:FindFirstChild("ESP") then
        player.Character.ESP:Destroy()
    end
    if player.Character and player.Character:FindFirstChild("ESPOutline") then
        player.Character.ESPOutline:Destroy()
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerTeam = player.Team
            local localTeam = LocalPlayer and LocalPlayer.Team
            if (not localTeam or not playerTeam) or (localTeam and playerTeam and localTeam ~= playerTeam) then
                if ESPEnabled and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    CreateESP(player)
                elseif not ESPEnabled then
                    RemoveESP(player)
                end
            end
        end
    end
end

-- Orbit Functions
local function TeleportToTarget()
    if OrbitTarget and OrbitTarget.Character and OrbitTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = OrbitTarget.Character.HumanoidRootPart.Position
        local offset = Vector3.new(0, 0, 10) -- Khoảng cách teleport 10 units
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + offset)
    end
end

local function UpdateOrbit()
    if OrbitEnabled then
        if not OrbitTarget or not OrbitTarget.Character or not OrbitTarget.Character:FindFirstChild("HumanoidRootPart") or
           (OrbitTarget.Character:FindFirstChild("Humanoid") and OrbitTarget.Character.Humanoid.Health <= 0) then
            local newOrbitTarget = GetClosestPlayer()
            if newOrbitTarget and newOrbitTarget ~= OrbitTarget then
                OrbitTarget = newOrbitTarget
                TeleportToTarget()
                OrbitAngle = 0.0
            end
        end
        if OrbitTarget and OrbitTarget.Character and OrbitTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = OrbitTarget.Character.HumanoidRootPart.Position
            OrbitAngle += OrbitSpeed
            local newPos = targetPos + Vector3.new(math.cos(OrbitAngle) * OrbitDistance, 0, math.sin(OrbitAngle) * OrbitDistance)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
        end
    end
end

-- Run Aimbot, ESP, and Orbit
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        CheckTargetDeathOrSwitch()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") and IsTargetVisible(Target) then
            AimAtTarget()
            AddHighlight(Target)
        end
    else
        if Target then
            RemoveHighlight(Target)
        end
    end
    if ESPEnabled then
        UpdateESP()
    end
    if OrbitEnabled then
        UpdateOrbit()
    end
end)