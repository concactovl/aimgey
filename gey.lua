-- Variables
local AimbotEnabled = false
local Target = nil
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AimbotUI"

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Màu tím
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0, 180, 0, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219) -- Màu tím nhạt cho nút
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Bật Aimbot"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.Size = UDim2.new(0, 180, 0, 30)
StatusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Trạng thái: Tắt"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14

-- Aimbot function
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = 500 -- Tăng lên 500 để aim xa hơn
    local localTeam = LocalPlayer and LocalPlayer.Team
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            local playerTeam = player.Team
            if (not localTeam or not playerTeam) or (localTeam and playerTeam and localTeam ~= playerTeam) then
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
        local ray = Ray.new(origin, direction * 500) -- Tăng raycast lên 500
        local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        return hit == nil or hit:IsDescendantOf(target.Character)
    end
    return false
end

local function AimAtTarget()
    if AimbotEnabled and Target and Target.Character and Target.Character:FindFirstChild("Head") and IsTargetVisible(Target) then
        local targetPos = Target.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos) -- Aim tức thì
    end
end

local function CheckTargetDeathOrSwitch()
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        if Target.Character.Humanoid.Health <= 0 or not Target.Character:FindFirstChild("Head") then
            local newTarget = GetClosestPlayer()
            if newTarget and IsTargetVisible(newTarget) then
                Target = newTarget
                print("Chuyển target sang: " .. Target.Name)
                StatusLabel.Text = "Trạng thái: Bật (Target: " .. Target.Name .. ")"
            else
                Target = nil
                StatusLabel.Text = "Trạng thái: Đang tìm target..."
            end
        else
            local newTarget = GetClosestPlayer()
            if newTarget and newTarget ~= Target then
                local currentDistance = Target and Target.Character and Target.Character:FindFirstChild("Head") and (Camera.CFrame.Position - Target.Character.Head.Position).Magnitude or math.huge
                local newDistance = newTarget.Character and newTarget.Character:FindFirstChild("Head") and (Camera.CFrame.Position - newTarget.Character.Head.Position).Magnitude or math.huge
                if newDistance < currentDistance and IsTargetVisible(newTarget) then
                    Target = newTarget
                    print("Chuyển target sang player gần hơn: " .. Target.Name)
                    StatusLabel.Text = "Trạng thái: Bật (Target: " .. Target.Name .. ")"
                end
            end
        end
    else
        local newTarget = GetClosestPlayer()
        if newTarget and IsTargetVisible(newTarget) then
            Target = newTarget
            print("Tìm thấy target mới: " .. Target.Name)
            StatusLabel.Text = "Trạng thái: Bật (Target: " .. Target.Name .. ")"
        else
            StatusLabel.Text = "Trạng thái: Đang tìm target..."
        end
    end
end

-- Highlight function
local function AddHighlight(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Màu vàng nhạt
        highlight.OutlineColor = Color3.fromRGB(255, 165, 0) -- Màu cam nhạt
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

-- Toggle Aimbot
ToggleButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        Target = GetClosestPlayer()
        if Target and IsTargetVisible(Target) then
            ToggleButton.Text = "Tắt Aimbot"
            StatusLabel.Text = "Trạng thái: Bật (Target: " .. Target.Name .. ")"
            AddHighlight(Target)
            print("Aimbot bật, nhắm vào: " .. Target.Name)
        else
            Target = nil
            ToggleButton.Text = "Tắt Aimbot"
            StatusLabel.Text = "Trạng thái: Đang tìm target..."
            print("Aimbot bật, đang tìm target...")
        end
    else
        Target = nil
        ToggleButton.Text = "Bật Aimbot"
        StatusLabel.Text = "Trạng thái: Tắt"
        RemoveHighlight(Target)
        print("Aimbot tắt")
    end
end)

-- Run Aimbot
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
end)

