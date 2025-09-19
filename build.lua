-- Build A Boat for Treasure Auto Teleport with Floating and Tween
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Danh sách tọa độ
local coordinates = {
    {-50, 43, 1766},
    {-61, 46, 2584},
    {-48, 62, 3351},
    {-51, 54, 4140},
    {-61, 81, 4781},
    {-49, 92, 5633},
    {-26, 47, 6397},
    {-61, 42, 7212},
    {-41, 34, 7949},
    {-57, -363, 9496}
}

local index = 1
local floatHeight = 10 -- Chiều cao lơ lửng
local tweenSpeed = 1.5 -- Thời gian tween (giây)

local function teleportAndFloat()
    while true do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local x, y, z = coordinates[index][1], coordinates[index][2], coordinates[index][3]
                local targetCFrame = CFrame.new(x, y + floatHeight, z)
                local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
                tween.Completed:Wait() -- Chờ tween hoàn thành
                wait(0) -- Đợi 2 giây
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                index = index % #coordinates + 1 -- Chuyển sang tọa độ tiếp theo
                if index == 1 and LocalPlayer.Character then -- Đã qua tọa độ cuối
                    local treasure = Workspace.Treasures:FindFirstChildWhichIsA("Part", true)
                    if treasure then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, treasure, 0) -- Lụm kho báu
                    end
                end
            else
                wait(1) -- Chờ nhân vật hồi sinh
            end
        else
            wait(1) -- Chờ nhân vật load
        end
        wait(0.1)
    end
end

-- Theo dõi nhân vật chết và hồi sinh
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(2) -- Đợi nhân vật load hoàn toàn
    teleportAndFloat()
end)

if LocalPlayer.Character then
    teleportAndFloat()
end