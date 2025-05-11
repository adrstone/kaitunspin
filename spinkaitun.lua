-- Tối ưu đồ họa
local decalsyeeted = true
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
local Players = g:GetService("Players")
local RunService = g:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tối ưu nước
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0

-- Ánh sáng & môi trường
l.GlobalShadows = false
l.FogEnd = 9e9
l.Brightness = 0

-- Chất lượng thấp
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Tối ưu từng object
local function optimizePart(v)
    if (v:IsA("BasePart") or v:IsA("Part")) and not v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") and decalsyeeted then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.TextureID = "rbxassetid://0"
        v.Color = Color3.fromRGB(0, 0, 0)
    elseif v:IsA("SpecialMesh") and decalsyeeted then
        v.TextureId = ""
    elseif v:IsA("ShirtGraphic") and decalsyeeted then
        v.Graphic = ""
    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
        local prop = v.ClassName .. "Template"
        if v[prop] ~= nil then
            v[prop] = ""
        end
    end
end

-- Áp dụng tối ưu
for _, v in pairs(w:GetDescendants()) do
    optimizePart(v)
end

local function optimizeLightingEffect(effect)
    if effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

for _, effect in pairs(l:GetChildren()) do
    optimizeLightingEffect(effect)
end

l.ChildAdded:Connect(optimizeLightingEffect)
w.DescendantAdded:Connect(function(v)
    task.wait()
    optimizePart(v)
end)

-- Tạo GUI FPS ở góc trên bên trái
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.Position = UDim2.new(0, 10, 0, 10) -- Đặt lại ở góc trên bên trái
textLabel.Font = Enum.Font.FredokaOne
textLabel.TextScaled = true
textLabel.BackgroundTransparency = 1
textLabel.TextStrokeTransparency = 0

-- Tính FPS và hiển thị với màu cầu vồng
local hue = 0
local frameCount = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    -- Cầu vồng
    hue = hue + 0.005
    if hue > 1 then hue = 0 end
    textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)

    -- FPS và tên người chơi hiển thị trên 1 dòng
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        local fps = frameCount / (now - lastUpdate)
        frameCount = 0
        lastUpdate = now

        textLabel.Text = string.format("%s | FPS: %d", LocalPlayer.Name, math.floor(fps))
    end
end)

-- Mã tự động nhấn vào nút Spin và Enter
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicator = ReplicatedStorage:WaitForChild("Replicator")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local spinButton = nil

-- Chờ cho đến khi nút "Spin" xuất hiện và hiển thị
while not spinButton do
    local success, result = pcall(function()
        return gui:WaitForChild("UI")
            :WaitForChild("MainMenu")
            :WaitForChild("Buttons")
            :FindFirstChild("Spin")
    end)
    if success and result and result:IsA("GuiButton") and result.Visible then
        spinButton = result
        print("Nút Spin đã tìm thấy!")
    else
        print("Chưa tìm thấy nút Spin hoặc nút không thể hiển thị")
    end
    task.wait(0.2)
end

-- Đảm bảo nút có thể được focus
spinButton.Selectable = true
print("Đã set focus cho nút Spin")

-- Focus vào nút
GuiService.SelectedObject = spinButton
task.wait(0.5)

-- Giả lập ba lần nhấn phím Enter
for i = 1, 3 do
    print("Giả lập nhấn Enter lần", i)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.5)  -- Thêm một chút thời gian giữa các lần ấn
end

-- Chờ 10 giây sau khi nhấn Enter
task.wait(10)

-- Kiểm tra và spin trái cây
local rareFruits = {
    "DarkXQuake",
    "DragonV2",
    "DoughV2",
    "Nika",
    "LeopardV2",
    "Ope",
    "Okuchi",
    "Soul",
    "Lightning"
}

local function isRare(fruitName)
    for _, v in pairs(rareFruits) do
        if string.lower(v) == string.lower(fruitName) then
            return true
        end
    end
    return false
end

local currentSlot = 1
local maxSlot = 4
local autoSpin = true

local function getEquippedFruit()
    local slotValue = player:FindFirstChild("MAIN_DATA") and player.MAIN_DATA.Slots[tostring(currentSlot)]
    return slotValue and slotValue.Value or nil
end

while autoSpin do
    local equipped = getEquippedFruit()
    print("Slot", currentSlot, "đang cầm:", equipped)

    if equipped and isRare(equipped) then
        print("👉 Gặp trái hiếm:", equipped)

        if currentSlot < maxSlot then
            currentSlot += 1
            print("🔁 Đổi sang slot tiếp theo:", currentSlot)
            Replicator:InvokeServer("FruitsHandler", "SwitchSlot", {Slot = currentSlot})
            task.wait(1.5)
        else
            print("✅ Đã đến slot cuối cùng, dừng lại.")
            autoSpin = false
            break
        end
    else
        print("⚙️ Spin vì không phải trái hiếm...")
        local result = Replicator:InvokeServer("FruitsHandler", "Spin", {})
        task.wait(2.5)
    end

    task.wait(1)
end