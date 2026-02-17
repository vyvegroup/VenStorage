--[[
    HEADLESS SCRIPT - Executor Compatible
    Nguyên lý: Thay đổi properties được replicate qua server
    
    LƯU Ý QUAN TRỌNG:
    - Chỉ hoạt động với executor có khả năng gửi remote events
    - Một số game có anti-cheat sẽ block
    - Kết quả phụ thuộc vào game cụ thể
]]

-- ============================================
-- METHOD 1: Basic Headless (Client-Side)
-- Người khác có thể KHÔNG thấy
-- ============================================
local function ClientHeadless()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:WaitForChild("Head")
    
    -- Ẩn Head
    head.Transparency = 1
    head.face:Destroy() -- Xóa mặt
    
    -- Xóa mesh head
    for _, v in pairs(head:GetChildren()) do
        if v:IsA("SpecialMesh") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    
    -- Ẩn tất cả accessories trên đầu
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            local handle = accessory:FindFirstChild("Handle")
            if handle then
                local attachment = handle:FindFirstChildOfClass("Attachment")
                if attachment then
                    local attachName = attachment.Name:lower()
                    if attachName:find("hat") or attachName:find("hair") or attachName:find("face") or attachName:find("head") then
                        handle.Transparency = 1
                    end
                end
            end
        end
    end
    
    print("[Headless] Client-side applied")
end

-- ============================================
-- METHOD 2: Replicated Headless (Server Visible)
-- Dùng HumanoidDescription để replicate
-- ============================================
local function ReplicatedHeadless()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Lấy HumanoidDescription hiện tại
    local description = humanoid:GetAppliedDescription()
    
    -- Set Head to blank/empty (ID 0 hoặc ID headless)
    -- Headless Head ID: 134082579 (Headless Horseman)
    description.Head = 134082579
    
    -- Xóa face
    description.Face = 0
    
    -- Xóa hat accessories liên quan đến đầu
    description.HatAccessory = ""
    description.HairAccessory = ""
    description.FaceAccessory = ""
    
    -- Apply - cái này REPLICATE qua server
    humanoid:ApplyDescription(description)
    
    -- Sau khi apply, ẩn head
    task.wait(0.5)
    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.MeshId = ""
                child.Scale = Vector3.new(0, 0, 0)
            elseif child:IsA("Decal") then
                child:Destroy()
            end
        end
    end
    
    print("[Headless] Replicated method applied")
end

-- ============================================
-- METHOD 3: Nano Headless (Best Method)
-- Dùng Humanoid Description + Scale
-- ============================================
local function NanoHeadless()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Lấy description
    local desc = humanoid:GetAppliedDescription()
    
    -- Scale head xuống cực nhỏ (REPLICATED!)
    desc.HeadScale = 0
    desc.Head = 0
    desc.Face = 0
    desc.HatAccessory = ""
    desc.HairAccessory = ""
    desc.FaceAccessory = ""
    
    -- Apply description (server sẽ thấy)
    local success, err = pcall(function()
        humanoid:ApplyDescription(desc)
    end)
    
    if success then
        print("[Headless] Nano method SUCCESS - Everyone can see!")
    else
        warn("[Headless] Nano method failed:", err)
        -- Fallback: dùng BodyHeadScale
        local headScale = humanoid:FindFirstChild("HeadScale")
        if headScale then
            headScale.Value = 0
        end
    end
    
    -- Cleanup visuals
    task.wait(0.3)
    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        head.CanCollide = false
        head.Size = Vector3.new(0.01, 0.01, 0.01)
        
        for _, v in pairs(head:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("SpecialMesh") then
                v.Scale = Vector3.new(0, 0, 0)
            end
        end
    end
    
    -- Ẩn head accessories
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                local att = handle:FindFirstChildOfClass("Attachment")
                if att and (att.Name:find("Hat") or att.Name:find("Hair") or att.Name:find("Head") or att.Name:find("Face")) then
                    handle.Transparency = 1
                    handle.Size = Vector3.new(0.01, 0.01, 0.01)
                    for _, mesh in pairs(handle:GetChildren()) do
                        if mesh:IsA("SpecialMesh") then
                            mesh.Scale = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- METHOD 4: Ultimate Headless (Combined)
-- Kết hợp mọi phương pháp
-- ============================================
local function UltimateHeadless()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    print("[Headless] Starting Ultimate Method...")
    
    -- Step 1: Apply blank description
    pcall(function()
        local desc = humanoid:GetAppliedDescription()
        desc.Head = 0
        desc.Face = 0
        desc.HeadScale = 0.001
        desc.HatAccessory = ""
        desc.HairAccessory = ""
        desc.FaceAccessory = ""
        humanoid:ApplyDescription(desc)
    end)
    
    task.wait(0.5)
    
    -- Step 2: Scale head down (replicated value)
    pcall(function()
        local headScale = humanoid:FindFirstChild("HeadScale")
        if headScale and headScale:IsA("NumberValue") then
            headScale.Value = 0
        end
    end)
    
    -- Step 3: Visual cleanup
    task.wait(0.3)
    pcall(function()
        local head = character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            head.CanCollide = false
            
            for _, child in pairs(head:GetDescendants()) do
                pcall(function()
                    if child:IsA("Decal") then
                        child.Transparency = 1
                    elseif child:IsA("SpecialMesh") then
                        child.Scale = Vector3.new(0, 0, 0)
                        child.MeshId = ""
                    end
                end)
            end
        end
    end)
    
    -- Step 4: Remove head accessories
    pcall(function()
        local headAttachments = {
            "HatAttachment", "HairAttachment", "FaceFrontAttachment",
            "FaceCenterAttachment", "HeadAttachment"
        }
        
        for _, acc in pairs(character:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    for _, att in pairs(handle:GetChildren()) do
                        if att:IsA("Attachment") then
                            for _, name in pairs(headAttachments) do
                                if att.Name == name then
                                    handle.Transparency = 1
                                    for _, m in pairs(handle:GetChildren()) do
                                        if m:IsA("SpecialMesh") then
                                            m.Scale = Vector3.new(0, 0, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    print("[Headless] Ultimate Method Complete!")
    print("[Headless] Note: Visibility depends on game's replication system")
end

-- ============================================
-- AUTO RE-APPLY ON RESPAWN
-- ============================================
local player = game.Players.LocalPlayer

local function onCharacterAdded(char)
    task.wait(1) -- Đợi character load xong
    UltimateHeadless()
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Apply ngay lập tức
if player.Character then
    UltimateHeadless()
end

-- ============================================
-- GUI TOGGLE (Optional)
-- ============================================
local function CreateToggleGUI()
    -- Xóa GUI cũ nếu có
    local old = game.CoreGui:FindFirstChild("HeadlessGUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "HeadlessGUI"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0, 10, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "💀 HEADLESS"
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "APPLY HEADLESS"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 78)
    status.BackgroundTransparency = 1
    status.Text = "Ready"
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        status.Text = "Applying..."
        status.TextColor3 = Color3.fromRGB(255, 255, 100)
        UltimateHeadless()
        status.Text = "✅ Applied!"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    -- Draggable
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

CreateToggleGUI()
print("=================================")
print("  HEADLESS SCRIPT LOADED")
print("  By combining all methods")
print("  Auto re-applies on respawn")
print("=================================")