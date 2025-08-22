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
    Name = "Aimbot by Bé Iuu 🥰",
    LoadingTitle = "Loading Aimbot Script",
    LoadingSubtitle = "by xAI",
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
        else
            Target = nil
            RemoveHighlight(Target)
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
    Range = {1.0, 50.0}, -- Increased max distance to 50.0
    Increment = 0.5,
    Suffix = "units",
    CurrentValue = 5.0,
    Flag = "OrbitDistanceSlider",
    Callback = function(Value)
        OrbitDistance = Value
    end
})

-- Aimbot Functions
function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if IgnoreTeammates and player.Team == LocalPlayer.Team then continue end
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

function IsTargetVisible(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return false end
    local ray = Ray.new(Camera.CFrame.Position, (target.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 500)
    local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    return hit == nil or hit:IsDescendantOf(target.Character)
end

function AimAtTarget()
    if Target and Target.Character and Target.Character:FindFirstChild("Head") then
        local headPos = Target.Character.Head.Position
        VirtualUser:CaptureController()
        Mouse.Target = Vector3.new(headPos.X, headPos.Y, headPos.Z)
    end
end

function CheckTargetDeathOrSwitch()
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") and Target.Character.Humanoid.Health <= 0 then
        Target = GetClosestPlayer()
    end
end

function AddHighlight(player)
    if player and player.Character and not player.Character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 0)
    end
end

function RemoveHighlight(player)
    if player and player.Character and player.Character:FindFirstChild("Highlight") then
        player.Character.Highlight:Destroy()
    end
end

-- ESP Functions
function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("ESPBillboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Parent = player.Character.Head
        billboard.Adornee = player.Character.Head
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.AlwaysOnTop = true
        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = player.Name
        text.TextColor3 = Color3.new(1, 0, 0)
        text.BackgroundTransparency = 1
    end
end

function RemoveESP(player)
    if player.Character and player.Character:FindFirstChild("ESPBillboard") then
        player.Character.ESPBillboard:Destroy()
    end
end

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("ESPBillboard") then
                CreateESP(player)
            end
        end
    end
end

-- Orbit Functions
local function TeleportToTarget()
    if OrbitTarget and OrbitTarget.Character and OrbitTarget.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = OrbitTarget.Character.HumanoidRootPart.CFrame
    end
end

local function UpdateOrbit()
    if OrbitEnabled and OrbitTarget and OrbitTarget.Character and OrbitTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = OrbitTarget.Character.HumanoidRootPart.Position
        OrbitAngle += OrbitSpeed
        local newPos = targetPos + Vector3.new(math.cos(OrbitAngle) * OrbitDistance, 0, math.sin(OrbitAngle) * OrbitDistance)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
        -- Check if target is dead, switch to new target
        if OrbitTarget.Character:FindFirstChild("Humanoid") and OrbitTarget.Character.Humanoid.Health <= 0 then
            OrbitTarget = GetClosestPlayer()
            if OrbitTarget then
                TeleportToTarget()
            end
        end
    end
end

-- Run Aimbot, ESP, and Orbit with separate checks
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local newTarget = GetClosestPlayer()
        if newTarget and (not Target or Target.Character.Humanoid.Health <= 0) then
            Target = newTarget
        end
        if Target and Target.Character and Target.Character:FindFirstChild("Head") and IsTargetVisible(Target) then
            AimAtTarget()
            AddHighlight(Target)
        else
            RemoveHighlight(Target)
            Target = nil
        end
    end
    if ESPEnabled then
        UpdateESP()
    end
    if OrbitEnabled then
        UpdateOrbit()
    end
end)

-- Debug
print("Aimbot by Bé Iuu đã chạy xong! 🥰")