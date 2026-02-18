--// ═══════════════════════════════════════════════════════════
--// STALKER JOIN UI v2.0 - Big Tech Design
--// Mobile Friendly + Draggable + Cross-Game Join
--// ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// ═══════════════════════════════════════════════════════════
--// THEME CONFIG
--// ═══════════════════════════════════════════════════════════
local Theme = {
    Background = Color3.fromRGB(13, 13, 15),
    Surface = Color3.fromRGB(22, 22, 26),
    SurfaceHover = Color3.fromRGB(30, 30, 36),
    Card = Color3.fromRGB(28, 28, 34),
    CardHover = Color3.fromRGB(35, 35, 42),
    Primary = Color3.fromRGB(99, 102, 241),     -- Indigo
    PrimaryHover = Color3.fromRGB(129, 140, 248),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    Info = Color3.fromRGB(56, 189, 248),
    Text = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(148, 148, 168),
    TextMuted = Color3.fromRGB(88, 88, 108),
    Border = Color3.fromRGB(42, 42, 52),
    Accent = Color3.fromRGB(168, 85, 247),       -- Purple
    AccentGlow = Color3.fromRGB(139, 92, 246),
    Gradient1 = Color3.fromRGB(99, 102, 241),
    Gradient2 = Color3.fromRGB(168, 85, 247),
    Shadow = Color3.fromRGB(0, 0, 0),
}

--// ═══════════════════════════════════════════════════════════
--// UTILITY FUNCTIONS
--// ═══════════════════════════════════════════════════════════
local function CreateTween(obj, props, duration, style, direction)
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    ), props)
    return tween
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function AddPadding(parent, t, b, l, r)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, t or 8)
    padding.PaddingBottom = UDim.new(0, b or 8)
    padding.PaddingLeft = UDim.new(0, l or 8)
    padding.PaddingRight = UDim.new(0, r or 8)
    padding.Parent = parent
    return padding
end

local function AddShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, size or 30, 1, size or 30)
    shadow.Position = UDim2.new(0, -(size or 30)/2, 0, -(size or 30)/2)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function RippleEffect(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 5
    ripple.Parent = button
    AddCorner(ripple, 100)

    local pos = Vector2.new(x, y) - button.AbsolutePosition
    ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    local tween = CreateTween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quart)
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

--// ═══════════════════════════════════════════════════════════
--// DESTROY OLD UI
--// ═══════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("StalkerJoinUI") then
    CoreGui:FindFirstChild("StalkerJoinUI"):Destroy()
end

--// ═══════════════════════════════════════════════════════════
--// MAIN SCREENGUI
--// ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StalkerJoinUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// ═══════════════════════════════════════════════════════════
--// TOGGLE BUTTON (Floating Action Button)
--// ═══════════════════════════════════════════════════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
ToggleBtn.BackgroundColor3 = Theme.Primary
ToggleBtn.Text = ""
ToggleBtn.AutoButtonColor = false
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui
AddCorner(ToggleBtn, 25)
AddShadow(ToggleBtn, 20, 0.4)

local ToggleIcon = Instance.new("TextLabel")
ToggleIcon.Name = "Icon"
ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Text = "👁"
ToggleIcon.TextSize = 22
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.TextColor3 = Theme.Text
ToggleIcon.ZIndex = 101
ToggleIcon.Parent = ToggleBtn

local ToggleGlow = Instance.new("ImageLabel")
ToggleGlow.Size = UDim2.new(1, 20, 1, 20)
ToggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleGlow.BackgroundTransparency = 1
ToggleGlow.Image = "rbxassetid://5554236805"
ToggleGlow.ImageColor3 = Theme.Primary
ToggleGlow.ImageTransparency = 0.7
ToggleGlow.ScaleType = Enum.ScaleType.Slice
ToggleGlow.SliceCenter = Rect.new(23, 23, 277, 277)
ToggleGlow.ZIndex = 99
ToggleGlow.Parent = ToggleBtn

-- Pulse animation for toggle
spawn(function()
    while ToggleBtn and ToggleBtn.Parent do
        CreateTween(ToggleGlow, {ImageTransparency = 0.5, Size = UDim2.new(1, 30, 1, 30)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
        wait(1)
        CreateTween(ToggleGlow, {ImageTransparency = 0.8, Size = UDim2.new(1, 15, 1, 15)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
        wait(1)
    end
end)

--// ═══════════════════════════════════════════════════════════
--// MAIN FRAME
--// ═══════════════════════════════════════════════════════════
local MainSize = IsMobile and UDim2.new(0, 340, 0, 520) or UDim2.new(0, 400, 0, 560)
local MainPos = UDim2.new(0.5, 0, 0.5, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = MainPos
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
AddCorner(MainFrame, 16)
AddStroke(MainFrame, Theme.Border, 1, 0.5)
AddShadow(MainFrame, 60, 0.3)

--// ═══════════════════════════════════════════════════════════
--// DRAG SYSTEM (Mobile + PC)
--// ═══════════════════════════════════════════════════════════
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// ═══════════════════════════════════════════════════════════
--// HEADER BAR
--// ═══════════════════════════════════════════════════════════
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Theme.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 12
Header.Parent = MainFrame
AddCorner(Header, 16)

-- Fix bottom corners of header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 20)
HeaderFix.Position = UDim2.new(0, 0, 1, -20)
HeaderFix.BackgroundColor3 = Theme.Surface
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 12
HeaderFix.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.BackgroundColor3 = Theme.Border
HeaderLine.BackgroundTransparency = 0.5
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 13
HeaderLine.Parent = Header

-- Gradient accent line
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Theme.Primary
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 15
AccentLine.Parent = Header
AddCorner(AccentLine, 1)

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.Gradient1),
    ColorSequenceKeypoint.new(0.5, Theme.Gradient2),
    ColorSequenceKeypoint.new(1, Theme.Gradient1),
}
AccentGradient.Parent = AccentLine

-- Animate gradient
spawn(function()
    local offset = 0
    while AccentLine and AccentLine.Parent do
        offset = (offset + 0.005) % 1
        AccentGradient.Offset = Vector2.new(offset, 0)
        RunService.Heartbeat:Wait()
    end
end)

-- Title
local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(1, -100, 1, 0)
TitleContainer.Position = UDim2.new(0, 15, 0, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.ZIndex = 14
TitleContainer.Parent = Header

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 28, 0, 28)
TitleIcon.Position = UDim2.new(0, 0, 0.5, -14)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🎯"
TitleIcon.TextSize = 18
TitleIcon.ZIndex = 14
TitleIcon.Parent = TitleContainer

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -35, 0, 20)
TitleLabel.Position = UDim2.new(0, 33, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STALKER JOIN"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextSize = IsMobile and 15 or 16
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 14
TitleLabel.Parent = TitleContainer

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -35, 0, 14)
SubTitle.Position = UDim2.new(0, 33, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "No Friend Required • Cross-Game"
SubTitle.TextColor3 = Theme.TextMuted
SubTitle.TextSize = IsMobile and 10 or 11
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 14
SubTitle.Parent = TitleContainer

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -48, 0.5, -18)
CloseBtn.BackgroundColor3 = Theme.SurfaceHover
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 14
CloseBtn.Parent = Header
AddCorner(CloseBtn, 10)

local CloseIcon = Instance.new("TextLabel")
CloseIcon.Size = UDim2.new(1, 0, 1, 0)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "✕"
CloseIcon.TextColor3 = Theme.TextSecondary
CloseIcon.TextSize = 16
CloseIcon.Font = Enum.Font.GothamBold
CloseIcon.ZIndex = 15
CloseIcon.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CreateTween(CloseBtn, {BackgroundColor3 = Theme.Error}, 0.2):Play()
    CreateTween(CloseIcon, {TextColor3 = Theme.Text}, 0.2):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    CreateTween(CloseBtn, {BackgroundColor3 = Theme.SurfaceHover}, 0.2):Play()
    CreateTween(CloseIcon, {TextColor3 = Theme.TextSecondary}, 0.2):Play()
end)

MakeDraggable(MainFrame, Header)

--// ═══════════════════════════════════════════════════════════
--// CONTENT AREA
--// ═══════════════════════════════════════════════════════════
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -56)
Content.Position = UDim2.new(0, 0, 0, 56)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.Primary
Content.ScrollBarImageTransparency = 0.5
Content.CanvasSize = UDim2.new(0, 0, 0, 600)
Content.ZIndex = 11
Content.Parent = MainFrame
AddPadding(Content, 15, 15, 15, 15)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 12)
ContentLayout.Parent = Content

--// ═══════════════════════════════════════════════════════════
--// STATUS CARD
--// ═══════════════════════════════════════════════════════════
local StatusCard = Instance.new("Frame")
StatusCard.Name = "StatusCard"
StatusCard.Size = UDim2.new(1, 0, 0, 50)
StatusCard.BackgroundColor3 = Theme.Card
StatusCard.BorderSizePixel = 0
StatusCard.ZIndex = 12
StatusCard.LayoutOrder = 0
StatusCard.Parent = Content
AddCorner(StatusCard, 10)
AddStroke(StatusCard, Theme.Border, 1, 0.7)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 15, 0.5, -4)
StatusDot.BackgroundColor3 = Theme.Success
StatusDot.ZIndex = 13
StatusDot.Parent = StatusCard
AddCorner(StatusDot, 4)

-- Pulse dot
spawn(function()
    while StatusDot and StatusDot.Parent do
        CreateTween(StatusDot, {BackgroundTransparency = 0.5}, 0.8):Play()
        wait(0.8)
        CreateTween(StatusDot, {BackgroundTransparency = 0}, 0.8):Play()
        wait(0.8)
    end
end)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 1, 0)
StatusText.Position = UDim2.new(0, 32, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Sẵn sàng • Chờ lệnh"
StatusText.TextColor3 = Theme.TextSecondary
StatusText.TextSize = IsMobile and 11 or 12
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 13
StatusText.Parent = StatusCard

local function UpdateStatus(text, color)
    StatusText.Text = text
    StatusDot.BackgroundColor3 = color or Theme.Success
end

--// ═══════════════════════════════════════════════════════════
--// SECTION: TARGET USER ID
--// ═══════════════════════════════════════════════════════════
local function CreateSection(title, icon, order)
    local section = Instance.new("Frame")
    section.Name = title
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundTransparency = 1
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.ZIndex = 12
    section.LayoutOrder = order
    section.Parent = Content

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Padding = UDim.new(0, 8)
    sectionLayout.Parent = section

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = "  " .. icon .. "  " .. title
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = IsMobile and 11 or 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12
    label.LayoutOrder = 0
    label.Parent = section

    return section
end

local function CreateInput(parent, placeholder, order, isSecret)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 44)
    inputFrame.BackgroundColor3 = Theme.Surface
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 12
    inputFrame.LayoutOrder = order or 1
    inputFrame.Parent = parent
    AddCorner(inputFrame, 10)
    local inputStroke = AddStroke(inputFrame, Theme.Border, 1, 0.5)

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Theme.TextMuted
    textBox.TextColor3 = Theme.Text
    textBox.TextSize = IsMobile and 13 or 14
    textBox.Font = Enum.Font.GothamMedium
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 13
    textBox.ClipsDescendants = true
    textBox.Parent = inputFrame

    -- Focus animations
    textBox.Focused:Connect(function()
        CreateTween(inputStroke, {Color = Theme.Primary, Transparency = 0}, 0.2):Play()
        CreateTween(inputFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.2):Play()
    end)
    textBox.FocusLost:Connect(function()
        CreateTween(inputStroke, {Color = Theme.Border, Transparency = 0.5}, 0.2):Play()
        CreateTween(inputFrame, {BackgroundColor3 = Theme.Surface}, 0.2):Play()
    end)

    return textBox
end

-- Target Section
local TargetSection = CreateSection("MỤC TIÊU", "🎯", 1)

local UserIdInput = CreateInput(TargetSection, "Nhập User ID mục tiêu...", 1)

-- Username lookup display
local UserInfoCard = Instance.new("Frame")
UserInfoCard.Name = "UserInfo"
UserInfoCard.Size = UDim2.new(1, 0, 0, 56)
UserInfoCard.BackgroundColor3 = Theme.Surface
UserInfoCard.BorderSizePixel = 0
UserInfoCard.ZIndex = 12
UserInfoCard.LayoutOrder = 2
UserInfoCard.Visible = false
UserInfoCard.Parent = TargetSection
AddCorner(UserInfoCard, 10)
AddStroke(UserInfoCard, Theme.Primary, 1, 0.7)

local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Size = UDim2.new(0, 38, 0, 38)
UserAvatar.Position = UDim2.new(0, 10, 0.5, -19)
UserAvatar.BackgroundColor3 = Theme.SurfaceHover
UserAvatar.ZIndex = 13
UserAvatar.Parent = UserInfoCard
AddCorner(UserAvatar, 19)

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Size = UDim2.new(1, -65, 0, 18)
UserNameLabel.Position = UDim2.new(0, 56, 0, 10)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Text = "Username"
UserNameLabel.TextColor3 = Theme.Text
UserNameLabel.TextSize = IsMobile and 13 or 14
UserNameLabel.Font = Enum.Font.GothamBold
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
UserNameLabel.ZIndex = 13
UserNameLabel.Parent = UserInfoCard

local UserStatusLabel = Instance.new("TextLabel")
UserStatusLabel.Size = UDim2.new(1, -65, 0, 14)
UserStatusLabel.Position = UDim2.new(0, 56, 0, 30)
UserStatusLabel.BackgroundTransparency = 1
UserStatusLabel.Text = "Đang kiểm tra..."
UserStatusLabel.TextColor3 = Theme.TextMuted
UserStatusLabel.TextSize = IsMobile and 10 or 11
UserStatusLabel.Font = Enum.Font.GothamMedium
UserStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
UserStatusLabel.ZIndex = 13
UserStatusLabel.Parent = UserInfoCard

--// ═══════════════════════════════════════════════════════════
--// SECTION: COOKIE
--// ═══════════════════════════════════════════════════════════
local CookieSection = CreateSection("XÁC THỰC", "🔐", 2)

local CookieInput = CreateInput(CookieSection, "Dán .ROBLOSECURITY cookie...", 1, true)

-- Cookie info text
local CookieInfo = Instance.new("TextLabel")
CookieInfo.Size = UDim2.new(1, 0, 0, 30)
CookieInfo.BackgroundTransparency = 1
CookieInfo.Text = "⚠ Cookie dùng để truy vấn API Presence\n    Không được lưu trữ hay gửi đi đâu"
CookieInfo.TextColor3 = Theme.TextMuted
CookieInfo.TextSize = IsMobile and 9 or 10
CookieInfo.Font = Enum.Font.Gotham
CookieInfo.TextXAlignment = Enum.TextXAlignment.Left
CookieInfo.TextWrapped = true
CookieInfo.ZIndex = 12
CookieInfo.LayoutOrder = 2
CookieInfo.Parent = CookieSection

--// ═══════════════════════════════════════════════════════════
--// SECTION: ACTIONS
--// ═══════════════════════════════════════════════════════════
local ActionSection = CreateSection("HÀNH ĐỘNG", "⚡", 3)

local function CreateButton(parent, text, icon, color, order)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Size = UDim2.new(1, 0, 0, 48)
    btn.BackgroundColor3 = color or Theme.Primary
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.LayoutOrder = order or 1
    btn.ClipsDescendants = true
    btn.Parent = parent
    AddCorner(btn, 10)

    -- Gradient overlay
    local btnGrad = Instance.new("UIGradient")
    btnGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.15),
    }
    btnGrad.Rotation = 90
    btnGrad.Parent = btn

    local btnIcon = Instance.new("TextLabel")
    btnIcon.Size = UDim2.new(0, 24, 1, 0)
    btnIcon.Position = UDim2.new(0.5, -50, 0, 0)
    btnIcon.BackgroundTransparency = 1
    btnIcon.Text = icon
    btnIcon.TextSize = 16
    btnIcon.ZIndex = 13
    btnIcon.Parent = btn

    local btnLabel = Instance.new("TextLabel")
    btnLabel.Size = UDim2.new(0, 120, 1, 0)
    btnLabel.Position = UDim2.new(0.5, -22, 0, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.Text = text
    btnLabel.TextColor3 = Theme.Text
    btnLabel.TextSize = IsMobile and 13 or 14
    btnLabel.Font = Enum.Font.GothamBold
    btnLabel.TextXAlignment = Enum.TextXAlignment.Left
    btnLabel.ZIndex = 13
    btnLabel.Parent = btn

    -- Hover
    btn.MouseEnter:Connect(function()
        CreateTween(btn, {BackgroundColor3 = Color3.new(
            math.min(1, color.R + 0.08),
            math.min(1, color.G + 0.08),
            math.min(1, color.B + 0.08)
        )}, 0.2):Play()
    end)
    btn.MouseLeave:Connect(function()
        CreateTween(btn, {BackgroundColor3 = color}, 0.2):Play()
    end)

    -- Ripple on click
    btn.MouseButton1Down:Connect(function(x, y)
        RippleEffect(btn, btn.AbsolutePosition.X + btn.AbsoluteSize.X/2, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y/2)
    end)

    return btn
end

local TrackBtn = CreateButton(ActionSection, "DÒ TÌM", "🔍", Theme.Primary, 1)
local JoinBtn = CreateButton(ActionSection, "THAM GIA", "🚀", Theme.Success, 2)
local AutoTrackBtn = CreateButton(ActionSection, "TỰ ĐỘNG THEO", "🔄", Theme.Accent, 3)

--// ═══════════════════════════════════════════════════════════
--// SECTION: LOG
--// ═══════════════════════════════════════════════════════════
local LogSection = CreateSection("NHẬT KÝ", "📋", 4)

local LogFrame = Instance.new("Frame")
LogFrame.Name = "LogFrame"
LogFrame.Size = UDim2.new(1, 0, 0, 120)
LogFrame.BackgroundColor3 = Theme.Surface
LogFrame.BorderSizePixel = 0
LogFrame.ZIndex = 12
LogFrame.LayoutOrder = 1
LogFrame.ClipsDescendants = true
LogFrame.Parent = LogSection
AddCorner(LogFrame, 10)
AddStroke(LogFrame, Theme.Border, 1, 0.7)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -16, 1, -10)
LogScroll.Position = UDim2.new(0, 8, 0, 5)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 2
LogScroll.ScrollBarImageColor3 = Theme.Primary
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ZIndex = 13
LogScroll.Parent = LogFrame

local LogLayout = Instance.new("UIListLayout")
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 3)
LogLayout.Parent = LogScroll

local logCount = 0
local function AddLog(text, color)
    logCount = logCount + 1
    local log = Instance.new("TextLabel")
    log.Size = UDim2.new(1, 0, 0, 16)
    log.BackgroundTransparency = 1
    log.Text = os.date("[%H:%M:%S] ") .. text
    log.TextColor3 = color or Theme.TextSecondary
    log.TextSize = IsMobile and 10 or 11
    log.Font = Enum.Font.Code
    log.TextXAlignment = Enum.TextXAlignment.Left
    log.TextWrapped = true
    log.AutomaticSize = Enum.AutomaticSize.Y
    log.ZIndex = 14
    log.LayoutOrder = logCount
    log.Parent = LogScroll

    -- Auto scroll to bottom
    task.wait()
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
end

--// ═══════════════════════════════════════════════════════════
--// UPDATE CANVAS SIZE
--// ═══════════════════════════════════════════════════════════
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
end)

--// ═══════════════════════════════════════════════════════════
--// CORE LOGIC
--// ═══════════════════════════════════════════════════════════
local lastPlaceId = nil
local lastJobId = nil
local autoTracking = false

local function LookupUser(userId)
    pcall(function()
        local thumbUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
        UserAvatar.Image = thumbUrl
    end)

    local success, result = pcall(function()
        local url = "https://users.roblox.com/v1/users/" .. userId
        local response = request({
            Url = url,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"}
        })
        if response.Success then
            return HttpService:JSONDecode(response.Body)
        end
        return nil
    end)

    if success and result then
        UserNameLabel.Text = result.displayName or result.name or "Unknown"
        UserInfoCard.Visible = true
        return result.name
    end
    return nil
end

local function GetPresence(userId, cookie)
    AddLog("Đang truy vấn vị trí mục tiêu...", Theme.Info)
    UpdateStatus("Đang dò tìm...", Theme.Warning)

    local url = "https://presence.roblox.com/v1/presence/users"
    local body = HttpService:JSONEncode({userIds = {tonumber(userId)}})

    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Cookie"] = ".ROBLOSECURITY=" .. cookie
            },
            Body = body
        })
    end)

    if not success then
        AddLog("❌ Lỗi request: " .. tostring(response), Theme.Error)
        UpdateStatus("Lỗi kết nối", Theme.Error)
        return nil, nil
    end

    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        local presence = data.userPresences and data.userPresences[1]

        if presence then
            local presType = presence.userPresenceType
            if presType == 0 then
                AddLog("⚫ Mục tiêu đang Offline", Theme.TextMuted)
                UserStatusLabel.Text = "⚫ Offline"
                UserStatusLabel.TextColor3 = Theme.TextMuted
                UpdateStatus("Mục tiêu offline", Theme.TextMuted)
            elseif presType == 1 then
                AddLog("🟢 Mục tiêu đang Online (Website)", Theme.Success)
                UserStatusLabel.Text = "🟢 Online - Website"
                UserStatusLabel.TextColor3 = Theme.Success
                UpdateStatus("Online nhưng chưa vào game", Theme.Warning)
            elseif presType == 2 then
                local placeId = presence.placeId
                local jobId = presence.gameId
                local gameName = presence.lastLocation or "Unknown Game"
                AddLog("🎮 Đang chơi: " .. gameName, Theme.Success)
                AddLog("📍 PlaceId: " .. tostring(placeId), Theme.Info)
                AddLog("🔗 JobId: " .. tostring(jobId), Theme.Info)
                UserStatusLabel.Text = "🎮 " .. gameName
                UserStatusLabel.TextColor3 = Theme.Success
                UpdateStatus("Đã tìm thấy! Sẵn sàng join", Theme.Success)
                lastPlaceId = placeId
                lastJobId = jobId
                return placeId, jobId
            elseif presType == 3 then
                AddLog("🎬 Mục tiêu đang ở Studio", Theme.Warning)
                UserStatusLabel.Text = "🎬 Roblox Studio"
                UserStatusLabel.TextColor3 = Theme.Warning
                UpdateStatus("Đang ở Studio", Theme.Warning)
            end
        else
            AddLog("❌ Không lấy được dữ liệu presence", Theme.Error)
        end
    else
        AddLog("❌ API Error: " .. tostring(response.StatusCode), Theme.Error)
        if response.StatusCode == 401 then
            AddLog("🔒 Cookie hết hạn hoặc không hợp lệ!", Theme.Error)
            UpdateStatus("Cookie lỗi!", Theme.Error)
        elseif response.StatusCode == 403 then
            AddLog("🚫 Bị chặn truy cập", Theme.Error)
        end
    end

    return nil, nil
end

local function JoinTarget()
    if lastPlaceId and lastJobId then
        AddLog("🚀 Đang teleport đến server...", Theme.Success)
        UpdateStatus("Đang teleport...", Theme.Primary)

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(lastPlaceId, lastJobId, LocalPlayer)
        end)

        if not success then
            AddLog("❌ Teleport thất bại: " .. tostring(err), Theme.Error)
            AddLog("💡 Thử teleport bằng PlaceId...", Theme.Warning)

            pcall(function()
                TeleportService:Teleport(lastPlaceId, LocalPlayer)
            end)
        end
    else
        AddLog("⚠ Chưa có dữ liệu server. Hãy Dò Tìm trước!", Theme.Warning)
        UpdateStatus("Chưa dò tìm!", Theme.Warning)
    end
end

--// ═══════════════════════════════════════════════════════════
--// BUTTON EVENTS
--// ═══════════════════════════════════════════════════════════
TrackBtn.MouseButton1Click:Connect(function()
    local userId = UserIdInput.Text
    local cookie = CookieInput.Text

    if userId == "" or not tonumber(userId) then
        AddLog("⚠ Vui lòng nhập User ID hợp lệ!", Theme.Warning)
        return
    end
    if cookie == "" then
        AddLog("⚠ Vui lòng nhập Cookie!", Theme.Warning)
        return
    end

    LookupUser(tonumber(userId))
    GetPresence(tonumber(userId), cookie)
end)

JoinBtn.MouseButton1Click:Connect(function()
    if not lastPlaceId then
        AddLog("⚠ Hãy Dò Tìm trước khi Join!", Theme.Warning)
        return
    end
    JoinTarget()
end)

AutoTrackBtn.MouseButton1Click:Connect(function()
    autoTracking = not autoTracking

    if autoTracking then
        AddLog("🔄 Bật chế độ tự động theo dõi", Theme.Accent)
        UpdateStatus("Tự động theo dõi...", Theme.Accent)

        -- Update button appearance
        spawn(function()
            while autoTracking do
                local userId = UserIdInput.Text
                local cookie = CookieInput.Text

                if userId ~= "" and cookie ~= "" and tonumber(userId) then
                    local placeId, jobId = GetPresence(tonumber(userId), cookie)
                    if placeId and jobId then
                        AddLog("✅ Phát hiện mục tiêu! Tự động join...", Theme.Success)
                        task.wait(2)
                        JoinTarget()
                        autoTracking = false
                        break
                    end
                end

                for i = 15, 1, -1 do
                    if not autoTracking then break end
                    UpdateStatus("Tự động dò • Thử lại sau " .. i .. "s", Theme.Accent)
                    task.wait(1)
                end
            end
            UpdateStatus("Sẵn sàng • Chờ lệnh", Theme.Success)
        end)
    else
        AddLog("⏹ Tắt chế độ tự động", Theme.TextSecondary)
        UpdateStatus("Sẵn sàng • Chờ lệnh", Theme.Success)
    end
end)

-- UserID auto-lookup
local lookupDebounce = false
UserIdInput.FocusLost:Connect(function()
    if lookupDebounce then return end
    lookupDebounce = true

    local userId = UserIdInput.Text
    if userId ~= "" and tonumber(userId) then
        LookupUser(tonumber(userId))
    else
        UserInfoCard.Visible = false
    end

    lookupDebounce = false
end)

--// ═══════════════════════════════════════════════════════════
--// OPEN / CLOSE ANIMATIONS
--// ═══════════════════════════════════════════════════════════
local isOpen = false

local function OpenUI()
    isOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundTransparency = 1

    local openTween = CreateTween(MainFrame, {
        Size = MainSize,
        BackgroundTransparency = 0
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    openTween:Play()

    CreateTween(ToggleBtn, {
        Position = UDim2.new(0, -60, 0.5, -25),
        BackgroundTransparency = 0.5
    }, 0.3):Play()
end

local function CloseUI()
    isOpen = false
    autoTracking = false

    local closeTween = CreateTween(MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    closeTween:Play()
    closeTween.Completed:Connect(function()
        MainFrame.Visible = false
    end)

    CreateTween(ToggleBtn, {
        Position = UDim2.new(0, 15, 0.5, -25),
        BackgroundTransparency = 0
    }, 0.3):Play()
end

ToggleBtn.MouseButton1Click:Connect(function()
    if isOpen then
        CloseUI()
    else
        OpenUI()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    CloseUI()
end)

--// ═══════════════════════════════════════════════════════════
--// INITIAL LOG
--// ═══════════════════════════════════════════════════════════
AddLog("Stalker Join UI v2.0 đã khởi động", Theme.Primary)
AddLog("Platform: " .. (IsMobile and "📱 Mobile" or "💻 Desktop"), Theme.TextSecondary)
AddLog("Hỗ trợ: Cross-Game Join + No Friend", Theme.TextSecondary)
AddLog("──────────────────────────────", Theme.Border)
AddLog("Bước 1: Nhập User ID mục tiêu", Theme.Text)
AddLog("Bước 2: Dán Cookie xác thực", Theme.Text)
AddLog("Bước 3: Dò Tìm → Tham Gia", Theme.Text)

print("[Stalker Join] UI loaded successfully!")