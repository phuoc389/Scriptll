local aimbotEnabled = false
local targetAll = false
local fov = 100
local maxTransparency = 0.1
local aimDelay = 0.02

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Cam = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- Vòng FOV
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(128, 0, 128)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2
FOVring.Transparency = 0.1

local function calculateTransparency(distance)
    local maxDistance = fov
    local transparency = (1 - (distance / maxDistance)) * maxTransparency
    return transparency
end

local function getClosestPlayerInFOV(trg_part)
    local nearest = nil
    local last = math.huge
    local playerMousePos = Cam.ViewportSize / 2
    local localTeam = localPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if targetAll or player.Team ~= localTeam then
                local char = player.Character
                local part = char and char:FindFirstChild(trg_part)
                local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                    local distance = (Vector2.new(ePos.X, ePos.Y) - playerMousePos).Magnitude
                    if isVisible and distance < fov and distance < last then
                        last = distance
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

local function lookAt(targetPos)
    local lookVector = (targetPos - Cam.CFrame.Position).Unit
    Cam.CFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
end

local function updateDrawings()
    FOVring.Position = Cam.ViewportSize / 2
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AimbotUI"

-- Nút bật/tắt menu
local menuVisible = true
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 40, 0, 40)
toggleMenuBtn.Position = UDim2.new(0, 10, 0, 10)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleMenuBtn.TextColor3 = Color3.new(1, 1, 1)
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 20
toggleMenuBtn.Text = "≡"
toggleMenuBtn.Parent = ScreenGui
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 8)

-- Nút bật/tắt Aimbot
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 160, 0, 40)
toggleBtn.Position = UDim2.new(0, 50, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 20
toggleBtn.Text = "Aimbot: Tắt"
toggleBtn.Parent = ScreenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = "Aimbot: " .. (aimbotEnabled and "Bật" or "Tắt")
    FOVring.Visible = aimbotEnabled
end)

-- Nút chế độ: Địch / Tất cả
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0, 160, 0, 40)
modeBtn.Position = UDim2.new(0, 50, 0, 150)
modeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.Font = Enum.Font.Gotham
modeBtn.TextSize = 20
modeBtn.Text = "Chế độ: Địch"
modeBtn.Parent = ScreenGui
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 10)

modeBtn.MouseButton1Click:Connect(function()
    targetAll = not targetAll
    modeBtn.Text = "Chế độ: " .. (targetAll and "Tất Cả" or "Địch")
    modeBtn.BackgroundColor3 = targetAll and Color3.fromRGB(0, 120, 120) or Color3.fromRGB(60, 60, 60)
end)

-- Toggle menu hiển thị
toggleMenuBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    toggleBtn.Visible = menuVisible
    modeBtn.Visible = menuVisible
end)

-- Aimbot hoạt động
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    updateDrawings()
    local closest = getClosestPlayerInFOV("Head")
    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
        lookAt(closest.Character.Head.Position)
        local ePos = Cam:WorldToViewportPoint(closest.Character.Head.Position)
        local dist = (Vector2.new(ePos.X, ePos.Y) - (Cam.ViewportSize / 2)).Magnitude
        FOVring.Transparency = calculateTransparency(dist)
        task.wait(aimDelay)
    else
        FOVring.Transparency = 0.1
    end
end)
