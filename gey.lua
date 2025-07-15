-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local AimbotEnabled = false
local Target = nil
local ESPEnabled = false
local IgnoreTeammates = true
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "bat nat hub",
    LoadingTitle = "Loading Aimgay",
    LoadingSubtitle = "huhuhuuhuhuhuhuhuhuhuuhuhuhuhuhuhuhuhuhuhuhuuhuhu",
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
            if Target and IsTargetVisible(Target) then
            else
            end
        else
            Target = nil
        end
    end
})

local StatusLabel = AimbotTab:CreateLabel("Trạng thái: Tắt")

local IgnoreTeammatesToggle = AimbotTab:CreateToggle({
    Name = "Không Aim Đồng Đội",
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

-- Aimbot function
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

-- Highlight function
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

-- ESP function with orange outline
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

-- Run Aimbot and ESP
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
end)
