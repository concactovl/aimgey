-- ═══════════════════════════════════════════════
--   CARRY & THROW · FIXED QUEUE ON TELEPORT
-- ═══════════════════════════════════════════════

local mainScript = [[
local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local UIS        = game:GetService("UserInputService")
local CoreGui    = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP    = Players.LocalPlayer
local Event = RS:WaitForChild("CarryAndThrow")

local BEHIND_OFFSET = 1
local STEP_DELAY    = 0.2
local SAFE_POS      = Vector3.new(-19, -345, -99)

local enabled = false
local selectedPlayer = nil 

-- Đảm bảo tầng chứa UI cao nhất chống chặn click trên Mobile
local targetParent = nil
local success, _ = pcall(function() local test = CoreGui.Name targetParent = CoreGui end)
if not success then targetParent = LP:WaitForChild("PlayerGui") end

-- ══ LOAD THƯ VIỆN FLUENT CHÍNH THỨC ══════════════════
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "troll hug tower 3",
    SubTitle = "lo vuong",
    TabWidth = 120,
    Size = UDim2.fromOffset(460, 270),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Bảng Điều Khiển", Icon = "sliders" })
}

-- ══ LOGIC QUÉT MỤC TIÊU KHÓA CỨNG ════════════════════
local function getNearestTarget()
    local myChar = LP.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, nearDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < nearDist then
                    nearDist = dist
                    nearest  = p
                end
            end
        end
    end
    return nearest
end

local function getTarget()
    if selectedPlayer then
        if selectedPlayer.Parent == Players and selectedPlayer.Character then
            local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum  = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                return selectedPlayer
            end
        end
        return nil 
    end
    return getNearestTarget()
end

local function runLoop()
    while enabled do
        local target = getTarget()
        if not target then task.wait(0.3); continue end

        local myChar = LP.Character
        if not myChar then task.wait(0.3); continue end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local hum    = myChar:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum then task.wait(0.3); continue end

        -- ── BƯỚC 1: BÁM DÍNH LIÊN TỤC ĐẰNG SAU (STICKY GLUE LOCK) ──
        local grabDuration = 0.25 
        local startTime = os.clock()
        
        while os.clock() - startTime < grabDuration and enabled do
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            myChar = LP.Character
            myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myRoot and tRoot then
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, BEHIND_OFFSET)
                myRoot.AssemblyLinearVelocity = Vector3.zero 
            end
            
            pcall(function() Event:FireServer(1) end)
            RunService.Heartbeat:Wait() 
        end

        if not enabled then break end

        -- ── BƯỚC 2: Tele tới vị trí an toàn trên không, neo lại ──
        myChar = LP.Character
        myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if myRoot and hum then
            hum.PlatformStand = true
            myRoot.CFrame                 = CFrame.new(SAFE_POS)
            myRoot.AssemblyLinearVelocity = Vector3.zero
        end

        task.wait(STEP_DELAY)
        if not enabled then break end

        -- ── BƯỚC 3: Ném mục tiêu xuống dung nham ─────────────────
        pcall(function() Event:FireServer("Throw") end)

        task.wait(STEP_DELAY)
        if hum then hum.PlatformStand = false end
        task.wait(0.05)
    end
    local c = LP.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = false end end
end

-- ══ THIẾT LẬP CÁC THÀNH PHẦN GIAO DIỆN MOBLE-FIRST ══

local Toggle = Tabs.Main:AddToggle("CarryToggle", {
    Title = "Kích Hoạt Auto Carry", 
    Default = false 
})
Toggle:OnChanged(function()
    enabled = Toggle.Value
    if enabled then task.spawn(runLoop) end
end)

local StatusParagraph = Tabs.Main:AddParagraph({
    Title = "🎯 Mục Tiêu: TỰ ĐỘNG",
    Content = "Đang quét và bám dính người chơi ở gần bạn nhất."
})

Tabs.Main:AddInput("NameInput", {
    Title = "nhập name để ghim ai đó",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value == "" then return end
        local found = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and (p.Name:lower():find(Value:lower()) or p.DisplayName:lower():find(Value:lower())) then
                found = p
                break
            end
        end
        
        if found then
            selectedPlayer = found
            StatusParagraph:SetTitle("🔒 MỤC TIÊU: " .. found.Name)
            StatusParagraph:SetContent("Đã ghim cứng! Sẽ dính chặt sau lưng duy nhất người này.")
            Fluent:Notify({Title = "Thành Công", Content = "Đã khóa cứng vào: " .. found.Name, Duration = 3})
        else
            Fluent:Notify({Title = "Thất Bại", Content = "Không tìm thấy ai có tên giống: " .. Value, Duration = 3})
        end
    end
})

Tabs.Main:AddButton({
    Title = "🎯 Hủy Khóa Cứng -> Quay Lại Tự Động",
    Description = "Bấm vào đây để hủy ghim tên và quay lại bế đứa gần nhất.",
    Callback = function()
        selectedPlayer = nil
        StatusParagraph:SetTitle("🎯 Mục Tiêu: TỰ ĐỘNG")
        StatusParagraph:SetContent("Đang quét và bám dính người chơi ở gần bạn nhất.")
        Fluent:Notify({Title = "Hệ Thống", Content = "Đã quay lại chế độ Tự Động!", Duration = 3})
    end
})

local function toggleUI()
    local fluentGui = targetParent:FindFirstChild("Fluent")
    if fluentGui then
        fluentGui.Enabled = not fluentGui.Enabled
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        toggleUI()
    end
end)

if targetParent:FindFirstChild("FluentMobileButton") then targetParent["FluentMobileButton"]:Destroy() end
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "FluentMobileButton"
MobileGui.ResetOnSpawn = false
MobileGui.Parent = targetParent

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 70, 0, 30)
FloatBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FloatBtn.TextColor3 = Color3.fromRGB(255, 110, 30)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 11
FloatBtn.Text = "ẨN/HIỆN"
FloatBtn.Parent = MobileGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)
local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(255, 110, 30)

FloatBtn.Activated:Connect(toggleUI)

local dragging, dragStart, startPos = false, nil, nil
FloatBtn.InputBegan:Connect(function(inp)
    local t = inp.UserInputType
    if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = inp.Position startPos = FloatBtn.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if not dragging then return end
    local t = inp.UserInputType
    if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

Window:SelectTab(1)
]]

-- ⚡ 1. CHẠY SCRIPT NGAY BÂY GIỜ CHO SERVER HIỆN TẠI
task.spawn(function()
    local success, err = pcall(function()
        loadstring(mainScript)()
    end)
    if not success then
        warn("Lỗi khởi chạy script chính: ", err)
    end
end)

-- ⚡ 2. HÀM TỰ ĐỘNG THÊM VÀO HÀNG ĐỢI TELEPORT (HỖ TRỢ ĐA DẠNG EXECUTOR)
local function queueScript()
    local teleportFunc = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if teleportFunc then
        teleportFunc(mainScript)
    end
end

-- Lắng nghe tín hiệu khi bắt đầu nhảy server để kịp đẩy code vào hàng đợi
pcall(function()
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            queueScript()
        end
    end)
end)

-- Gọi sẵn một lần để đảm bảo chắc chắn bộ nhớ đệm của Executor đã nhận lệnh
queueScript()
