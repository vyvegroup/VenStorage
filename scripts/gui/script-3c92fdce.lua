--[[
	Cat & Fish Manager v3
	Zero-config · Auto-detect · Big Tech Design
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local AnimalConfig = require(ReplicatedStorage.Config.AnimalConfig)
local BaseService = ReplicatedStorage.Packages.Knit.Services.BaseService

-- ═══════════════════════════════════════════
-- DESIGN TOKENS (Apple HIG + Material 3)
-- ═══════════════════════════════════════════
local T = {}

-- Surfaces
T.base         = Color3.fromRGB(250, 250, 252)
T.panel        = Color3.fromRGB(255, 255, 255)
T.elevated     = Color3.fromRGB(255, 255, 255)
T.recessed     = Color3.fromRGB(242, 242, 247)
T.recessedHov  = Color3.fromRGB(235, 235, 240)
T.divider      = Color3.fromRGB(228, 228, 233)
T.overlay      = Color3.fromRGB(0, 0, 0)

-- Text
T.ink          = Color3.fromRGB(0, 0, 0)
T.inkSec       = Color3.fromRGB(99, 99, 102)
T.inkTer       = Color3.fromRGB(174, 174, 178)
T.inkOn        = Color3.fromRGB(255, 255, 255)

-- Semantic
T.accent       = Color3.fromRGB(0, 122, 255)
T.accentHov    = Color3.fromRGB(0, 100, 220)
T.accentSoft   = Color3.fromRGB(224, 237, 255)
T.positive     = Color3.fromRGB(52, 199, 89)
T.positiveHov  = Color3.fromRGB(40, 170, 72)
T.positiveSoft = Color3.fromRGB(223, 249, 231)
T.negative     = Color3.fromRGB(255, 59, 48)
T.negativeHov  = Color3.fromRGB(220, 45, 38)
T.negativeSoft = Color3.fromRGB(255, 231, 229)
T.caution      = Color3.fromRGB(255, 149, 0)
T.cautionSoft  = Color3.fromRGB(255, 241, 214)
T.violet       = Color3.fromRGB(88, 86, 214)
T.violetHov    = Color3.fromRGB(72, 70, 190)
T.violetSoft   = Color3.fromRGB(234, 233, 252)
T.teal         = Color3.fromRGB(0, 199, 190)
T.tealSoft     = Color3.fromRGB(218, 249, 247)

-- Rarity
T.rCommon      = Color3.fromRGB(174, 174, 178)
T.rRare        = Color3.fromRGB(0, 122, 255)
T.rEpic        = Color3.fromRGB(88, 86, 214)
T.rLegendary   = Color3.fromRGB(255, 149, 0)

-- Type
T.sans         = Enum.Font.GothamMedium
T.sansBold     = Enum.Font.GothamBold
T.sansBook     = Enum.Font.Gotham
T.mono         = Enum.Font.RobotoMono

-- Radius
T.r4  = UDim.new(0, 4)
T.r8  = UDim.new(0, 8)
T.r12 = UDim.new(0, 12)
T.r16 = UDim.new(0, 16)
T.rPill = UDim.new(0, 999)

local RARITY_ORDER  = {Legendary = 1, Epic = 2, Rare = 3, Common = 4}
local RARITY_COLORS = {Common = T.rCommon, Rare = T.rRare, Epic = T.rEpic, Legendary = T.rLegendary}
local RARITY_SOFT   = {
	Common    = Color3.fromRGB(240, 240, 242),
	Rare      = T.accentSoft,
	Epic      = T.violetSoft,
	Legendary = T.cautionSoft,
}

-- ═══════════════════════════════════════════
-- PRIMITIVES
-- ═══════════════════════════════════════════
local function tw(obj, props, d, s, dir)
	if not obj or not obj.Parent then return end
	TweenService:Create(obj, TweenInfo.new(d or 0.18, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function corner(p, r)
	local c = Instance.new("UICorner"); c.CornerRadius = r or T.r12; c.Parent = p; return c
end

local function stroke(p, col, th)
	local s = Instance.new("UIStroke"); s.Color = col or T.divider; s.Thickness = th or 1; s.Transparency = 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end

local function pad(p, l, r, t, b)
	local u = Instance.new("UIPadding"); u.PaddingLeft = UDim.new(0, l or 0); u.PaddingRight = UDim.new(0, r or 0); u.PaddingTop = UDim.new(0, t or 0); u.PaddingBottom = UDim.new(0, b or 0); u.Parent = p; return u
end

local function list(p, dir, gap, sort)
	local l = Instance.new("UIListLayout"); l.FillDirection = dir or Enum.FillDirection.Vertical; l.Padding = UDim.new(0, gap or 0); l.SortOrder = sort or Enum.SortOrder.LayoutOrder; l.Parent = p; return l
end

-- Haptic-style press feedback
local function pressAnim(btn)
	tw(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 2, btn.Size.Y.Scale, btn.Size.Y.Offset - 2)}, 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.06, function()
		tw(btn, {Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 2, btn.Size.Y.Scale, btn.Size.Y.Offset + 2)}, 0.15)
	end)
end

-- ═══════════════════════════════════════════
-- AUTO-DETECT PLAYER BASE & CATS FOLDER
-- ═══════════════════════════════════════════
local function findBase()
	local bases = Workspace:FindFirstChild("PlayerBases")
	if not bases then return nil, nil end
	-- Try player UserId first
	local b = bases:FindFirstChild(tostring(player.UserId))
	if not b then
		-- Fallback: find any base that has a Cats folder
		for _, child in ipairs(bases:GetChildren()) do
			if child:FindFirstChild("Cats") then
				b = child
				break
			end
		end
	end
	if not b then return nil, nil end
	return b, b:FindFirstChild("Cats")
end

-- ═══════════════════════════════════════════
-- SCREEN GUI
-- ═══════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "CatFishMgr"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- ─── Scrim (subtle backdrop when open) ───
local scrim = Instance.new("Frame")
scrim.Size = UDim2.new(1, 0, 1, 0)
scrim.BackgroundColor3 = T.overlay
scrim.BackgroundTransparency = 1
scrim.BorderSizePixel = 0
scrim.ZIndex = 1
scrim.Parent = gui

-- ─── Main Card ───
local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Size = UDim2.new(0, 540, 0, 340)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.BackgroundColor3 = T.panel
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 10
card.Parent = gui
corner(card, T.r16)
stroke(card, T.divider, 1)

-- Shadow layers
for i = 1, 2 do
	local sh = Instance.new("ImageLabel")
	sh.BackgroundTransparency = 1
	sh.Image = "rbxassetid://6015897843"
	sh.ImageColor3 = T.overlay
	sh.ImageTransparency = i == 1 and 0.92 or 0.96
	sh.ScaleType = Enum.ScaleType.Slice
	sh.SliceCenter = Rect.new(49, 49, 450, 450)
	local off = i == 1 and 20 or 40
	sh.Size = UDim2.new(1, off, 1, off)
	sh.Position = UDim2.new(0, -off/2, 0, -off/2 + (i == 1 and 3 or 6))
	sh.ZIndex = card.ZIndex - i
	sh.Parent = card
end

local isCollapsed = false
local fullSize = UDim2.new(0, 540, 0, 340)
local miniSize = UDim2.new(0, 540, 0, 42)

-- ═══════════════════════════════
-- CHROME BAR (Title)
-- ═══════════════════════════════
local chrome = Instance.new("Frame")
chrome.Name = "Chrome"
chrome.Size = UDim2.new(1, 0, 0, 42)
chrome.BackgroundTransparency = 1
chrome.BorderSizePixel = 0
chrome.ZIndex = 50
chrome.Parent = card

-- Drag pill
local pill = Instance.new("Frame")
pill.AnchorPoint = Vector2.new(0.5, 0)
pill.Size = UDim2.new(0, 36, 0, 4)
pill.Position = UDim2.new(0.5, 0, 0, 6)
pill.BackgroundColor3 = T.inkTer
pill.BorderSizePixel = 0
pill.ZIndex = 52
pill.Parent = chrome
corner(pill, T.rPill)

-- Status dot (live indicator)
local liveDot = Instance.new("Frame")
liveDot.AnchorPoint = Vector2.new(0, 0.5)
liveDot.Size = UDim2.new(0, 7, 0, 7)
liveDot.Position = UDim2.new(0, 16, 0.5, 0)
liveDot.BackgroundColor3 = T.positive
liveDot.BorderSizePixel = 0
liveDot.ZIndex = 52
liveDot.Parent = chrome
corner(liveDot, T.rPill)

-- Pulse animation on liveDot
task.spawn(function()
	while gui.Parent do
		tw(liveDot, {BackgroundTransparency = 0.5}, 0.8)
		task.wait(0.8)
		tw(liveDot, {BackgroundTransparency = 0}, 0.8)
		task.wait(0.8)
	end
end)

local titleLbl = Instance.new("TextLabel")
titleLbl.AnchorPoint = Vector2.new(0, 0.5)
titleLbl.Size = UDim2.new(0, 200, 0, 20)
titleLbl.Position = UDim2.new(0, 30, 0.5, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Cat · Fish Manager"
titleLbl.TextColor3 = T.ink
titleLbl.TextSize = 13
titleLbl.Font = T.sansBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 52
titleLbl.Parent = chrome

-- Chrome buttons
local chromeBtns = Instance.new("Frame")
chromeBtns.AnchorPoint = Vector2.new(1, 0.5)
chromeBtns.Size = UDim2.new(0, 64, 0, 26)
chromeBtns.Position = UDim2.new(1, -12, 0.5, 0)
chromeBtns.BackgroundTransparency = 1
chromeBtns.ZIndex = 52
chromeBtns.Parent = chrome
list(chromeBtns, Enum.FillDirection.Horizontal, 6).HorizontalAlignment = Enum.HorizontalAlignment.Right

local function chromeBtn(icon, bg, fg, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 26, 0, 26)
	b.BackgroundColor3 = bg
	b.Text = icon
	b.TextColor3 = fg
	b.TextSize = 11
	b.Font = T.sansBold
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.ClipsDescendants = true
	b.LayoutOrder = order
	b.ZIndex = 53
	b.Parent = chromeBtns
	corner(b, T.r8)
	return b
end

local collapseBtn = chromeBtn("−", T.recessed, T.inkSec, 1)
local closeBtn    = chromeBtn("✕", T.negativeSoft, T.negative, 2)

collapseBtn.MouseButton1Click:Connect(function()
	pressAnim(collapseBtn)
	isCollapsed = not isCollapsed
	if isCollapsed then
		tw(card, {Size = miniSize}, 0.3)
		collapseBtn.Text = "＋"
	else
		tw(card, {Size = fullSize}, 0.3)
		collapseBtn.Text = "−"
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	pressAnim(closeBtn)
	tw(card, {Size = UDim2.new(0, 540, 0, 0), BackgroundTransparency = 1}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tw(scrim, {BackgroundTransparency = 1}, 0.2)
	task.delay(0.22, function() gui:Destroy() end)
end)

-- Chrome divider
local chromeLine = Instance.new("Frame")
chromeLine.Size = UDim2.new(1, -24, 0, 1)
chromeLine.AnchorPoint = Vector2.new(0.5, 1)
chromeLine.Position = UDim2.new(0.5, 0, 1, 0)
chromeLine.BackgroundColor3 = T.divider
chromeLine.BorderSizePixel = 0
chromeLine.ZIndex = 50
chromeLine.Parent = chrome

-- ═══════════════════════════════
-- TAB SYSTEM (Segmented Control)
-- ═══════════════════════════════
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -24, 0, 32)
tabBar.AnchorPoint = Vector2.new(0.5, 0)
tabBar.Position = UDim2.new(0.5, 0, 0, 46)
tabBar.BackgroundColor3 = T.recessed
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 40
tabBar.Parent = card
corner(tabBar, T.r8)

-- Tab indicator (sliding pill)
local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0, 0, 0, 26)
tabIndicator.Position = UDim2.new(0, 3, 0, 3)
tabIndicator.BackgroundColor3 = T.panel
tabIndicator.BorderSizePixel = 0
tabIndicator.ZIndex = 41
tabIndicator.Parent = tabBar
corner(tabIndicator, UDim.new(0, 6))

-- Tab shadow
local tabShadow = Instance.new("ImageLabel")
tabShadow.BackgroundTransparency = 1
tabShadow.Image = "rbxassetid://6015897843"
tabShadow.ImageColor3 = T.overlay
tabShadow.ImageTransparency = 0.94
tabShadow.ScaleType = Enum.ScaleType.Slice
tabShadow.SliceCenter = Rect.new(49, 49, 450, 450)
tabShadow.Size = UDim2.new(1, 6, 1, 6)
tabShadow.Position = UDim2.new(0, -3, 0, -1)
tabShadow.ZIndex = 40
tabShadow.Parent = tabIndicator

local TABS = {"Cats", "Fish", "Log"}
local tabButtons = {}
local tabPages = {}
local activeTab = "Cats"

local tabW = math.floor((540 - 24 - 6) / #TABS)
tabIndicator.Size = UDim2.new(0, tabW, 0, 26)

for i, name in ipairs(TABS) do
	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0, tabW, 1, 0)
	tb.Position = UDim2.new(0, (i-1) * tabW, 0, 0)
	tb.BackgroundTransparency = 1
	tb.Text = name
	tb.TextColor3 = i == 1 and T.ink or T.inkTer
	tb.TextSize = 12
	tb.Font = i == 1 and T.sansBold or T.sans
	tb.BorderSizePixel = 0
	tb.AutoButtonColor = false
	tb.ZIndex = 42
	tb.Parent = tabBar
	tabButtons[name] = tb
end

local function switchTab(name)
	activeTab = name
	for tName, tb in pairs(tabButtons) do
		if tName == name then
			tw(tb, {TextColor3 = T.ink}, 0.15)
			tb.Font = T.sansBold
		else
			tw(tb, {TextColor3 = T.inkTer}, 0.15)
			tb.Font = T.sans
		end
	end
	-- Slide indicator
	local idx = table.find(TABS, name) or 1
	tw(tabIndicator, {Position = UDim2.new(0, 3 + (idx-1) * tabW, 0, 3)}, 0.25)
	-- Show/hide pages
	for pName, page in pairs(tabPages) do
		if pName == name then
			page.Visible = true
			tw(page, {BackgroundTransparency = 0}, 0.15)
		else
			page.Visible = false
		end
	end
end

for name, tb in pairs(tabButtons) do
	tb.MouseButton1Click:Connect(function()
		pressAnim(tb)
		switchTab(name)
	end)
end

-- ═══════════════════════════════
-- PAGE CONTAINER
-- ═══════════════════════════════
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, 0, 1, -82)
pageContainer.Position = UDim2.new(0, 0, 0, 82)
pageContainer.BackgroundTransparency = 1
pageContainer.BorderSizePixel = 0
pageContainer.ZIndex = 12
pageContainer.ClipsDescendants = true
pageContainer.Parent = card

-- ═══════════════════════════════════════════
-- PAGE: CATS
-- ═══════════════════════════════════════════
local catPage = Instance.new("Frame")
catPage.Name = "CatPage"
catPage.Size = UDim2.new(1, 0, 1, 0)
catPage.BackgroundTransparency = 1
catPage.BorderSizePixel = 0
catPage.ZIndex = 13
catPage.Parent = pageContainer
tabPages["Cats"] = catPage

-- Left: cat list | Right: controls
local catLeft = Instance.new("ScrollingFrame")
catLeft.Size = UDim2.new(0.55, -6, 1, 0)
catLeft.Position = UDim2.new(0, 0, 0, 0)
catLeft.BackgroundColor3 = T.base
catLeft.BorderSizePixel = 0
catLeft.ScrollBarThickness = 2
catLeft.ScrollBarImageColor3 = T.inkTer
catLeft.ScrollBarImageTransparency = 0.4
catLeft.ZIndex = 14
catLeft.Parent = catPage
pad(catLeft, 10, 6, 8, 8)
local catListLayout = list(catLeft, nil, 4)
catListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	catLeft.CanvasSize = UDim2.new(0, 0, 0, catListLayout.AbsoluteContentSize.Y + 16)
end)

local catRight = Instance.new("ScrollingFrame")
catRight.Size = UDim2.new(0.45, -6, 1, 0)
catRight.Position = UDim2.new(0.55, 6, 0, 0)
catRight.BackgroundColor3 = T.base
catRight.BorderSizePixel = 0
catRight.ScrollBarThickness = 2
catRight.ScrollBarImageColor3 = T.inkTer
catRight.ScrollBarImageTransparency = 0.4
catRight.ZIndex = 14
catRight.Parent = catPage
pad(catRight, 8, 8, 8, 8)
local catRightLayout = list(catRight, nil, 6)
catRightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	catRight.CanvasSize = UDim2.new(0, 0, 0, catRightLayout.AbsoluteContentSize.Y + 16)
end)

-- ═══ Cat Controls (right panel) ═══

-- Pill button builder
local function pillBtn(parent, text, bg, fg, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = bg
	b.Text = text
	b.TextColor3 = fg
	b.TextSize = 11
	b.Font = T.sansBold
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.ClipsDescendants = true
	b.LayoutOrder = order
	b.ZIndex = 16
	b.Parent = parent
	corner(b, T.r8)
	-- Press
	b.MouseButton1Down:Connect(function() pressAnim(b) end)
	return b
end

-- Section header
local function secHead(parent, text, order)
	local h = Instance.new("TextLabel")
	h.Size = UDim2.new(1, 0, 0, 18)
	h.BackgroundTransparency = 1
	h.Text = string.upper(text)
	h.TextColor3 = T.inkTer
	h.TextSize = 9
	h.Font = T.sansBold
	h.TextXAlignment = Enum.TextXAlignment.Left
	h.LayoutOrder = order
	h.ZIndex = 16
	h.Parent = parent
	return h
end

-- Chip selector (Selection Mode)
local function chipGroup(parent, options, default, order, callback)
	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, 0, 0, 0)
	wrapper.AutomaticSize = Enum.AutomaticSize.Y
	wrapper.BackgroundTransparency = 1
	wrapper.LayoutOrder = order
	wrapper.ZIndex = 16
	wrapper.Parent = parent
	local wl = list(wrapper, nil, 4)

	local current = default
	local chips = {}

	for i, opt in ipairs(options) do
		local chip = Instance.new("TextButton")
		chip.Size = UDim2.new(1, 0, 0, 30)
		chip.BackgroundColor3 = opt.value == default and T.accentSoft or T.recessed
		chip.Text = ""
		chip.BorderSizePixel = 0
		chip.AutoButtonColor = false
		chip.ClipsDescendants = true
		chip.LayoutOrder = i
		chip.ZIndex = 17
		chip.Parent = wrapper
		corner(chip, T.r8)

		-- Icon
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 20, 1, 0)
		icon.Position = UDim2.new(0, 8, 0, 0)
		icon.BackgroundTransparency = 1
		icon.Text = opt.icon or ""
		icon.TextColor3 = opt.value == default and T.accent or T.inkTer
		icon.TextSize = 12
		icon.Font = T.sansBook
		icon.ZIndex = 18
		icon.Parent = chip

		-- Label
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -56, 1, 0)
		lbl.Position = UDim2.new(0, 30, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = opt.label
		lbl.TextColor3 = opt.value == default and T.accent or T.ink
		lbl.TextSize = 10
		lbl.Font = opt.value == default and T.sansBold or T.sans
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.ZIndex = 18
		lbl.Parent = chip

		-- Check
		local chk = Instance.new("TextLabel")
		chk.Name = "Chk"
		chk.Size = UDim2.new(0, 20, 1, 0)
		chk.Position = UDim2.new(1, -26, 0, 0)
		chk.BackgroundTransparency = 1
		chk.Text = opt.value == default and "●" or "○"
		chk.TextColor3 = opt.value == default and T.accent or T.inkTer
		chk.TextSize = 12
		chk.Font = T.sansBook
		chk.ZIndex = 18
		chk.Parent = chip

		chips[opt.value] = {chip = chip, icon = icon, lbl = lbl, chk = chk}

		chip.MouseButton1Click:Connect(function()
			pressAnim(chip)
			current = opt.value
			for v, parts in pairs(chips) do
				local isActive = v == current
				tw(parts.chip, {BackgroundColor3 = isActive and T.accentSoft or T.recessed}, 0.15)
				tw(parts.icon, {TextColor3 = isActive and T.accent or T.inkTer}, 0.15)
				tw(parts.lbl, {TextColor3 = isActive and T.accent or T.ink}, 0.15)
				parts.lbl.Font = isActive and T.sansBold or T.sans
				parts.chk.Text = isActive and "●" or "○"
				tw(parts.chk, {TextColor3 = isActive and T.accent or T.inkTer}, 0.15)
			end
			if callback then callback(current) end
		end)
	end

	return function() return current end
end

-- Toggle switch builder
local function toggleSwitch(parent, label, default, order, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = T.recessed
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.ZIndex = 16
	row.Parent = parent
	corner(row, T.r8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = T.ink
	lbl.TextSize = 10
	lbl.Font = T.sans
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = 17
	lbl.Parent = row

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(0, 36, 0, 20)
	track.Position = UDim2.new(1, -44, 0.5, -10)
	track.BackgroundColor3 = default and T.positive or T.divider
	track.Text = ""
	track.BorderSizePixel = 0
	track.AutoButtonColor = false
	track.ZIndex = 18
	track.Parent = row
	corner(track, T.rPill)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = default and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = T.panel
	knob.BorderSizePixel = 0
	knob.ZIndex = 19
	knob.Parent = track
	corner(knob, T.rPill)

	-- Knob shadow
	local knobSh = Instance.new("ImageLabel")
	knobSh.BackgroundTransparency = 1
	knobSh.Image = "rbxassetid://6015897843"
	knobSh.ImageColor3 = T.overlay
	knobSh.ImageTransparency = 0.9
	knobSh.ScaleType = Enum.ScaleType.Slice
	knobSh.SliceCenter = Rect.new(49, 49, 450, 450)
	knobSh.Size = UDim2.new(1, 6, 1, 6)
	knobSh.Position = UDim2.new(0, -3, 0, -2)
	knobSh.ZIndex = 18
	knobSh.Parent = knob

	local isOn = default or false

	local function setOn(state, silent)
		isOn = state
		tw(track, {BackgroundColor3 = isOn and T.positive or T.divider}, 0.2)
		tw(knob, {Position = isOn and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
		if not silent and callback then callback(isOn) end
	end

	track.MouseButton1Click:Connect(function()
		setOn(not isOn)
	end)

	return function() return isOn end, setOn
end

-- ─── Build Cat Controls ───
secHead(catRight, "Mode", 1)

local selectionMode = "top3"
local getMode = chipGroup(catRight, {
	{label = "All Cats",        value = "all",    icon = "▣"},
	{label = "Top 3 Rarity",    value = "top3",   icon = "★"},
	{label = "Manual + Top 3",  value = "manual", icon = "✎"},
}, "top3", 2, function(v) selectionMode = v end)

secHead(catRight, "Actions", 10)

local scanBtn   = pillBtn(catRight, "Scan",           T.accent,   T.inkOn,    11)
local pickupBtn = pillBtn(catRight, "Auto Pickup",     T.positive, T.inkOn,    12)
local petBtn    = pillBtn(catRight, "Auto Pet",        T.violet,   T.inkOn,    13)

secHead(catRight, "Stats", 20)

-- Stats card
local statsCard = Instance.new("Frame")
statsCard.Size = UDim2.new(1, 0, 0, 0)
statsCard.AutomaticSize = Enum.AutomaticSize.Y
statsCard.BackgroundColor3 = T.recessed
statsCard.BorderSizePixel = 0
statsCard.LayoutOrder = 21
statsCard.ZIndex = 16
statsCard.Parent = catRight
corner(statsCard, T.r8)
pad(statsCard, 10, 10, 8, 8)
list(statsCard, nil, 3)

local function statRow(label, val, order)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 14)
	f.BackgroundTransparency = 1
	f.LayoutOrder = order
	f.ZIndex = 17
	f.Parent = statsCard

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.5, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = label
	l.TextColor3 = T.inkTer
	l.TextSize = 9
	l.Font = T.sans
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 17
	l.Parent = f

	local v = Instance.new("TextLabel")
	v.Name = "V"
	v.Size = UDim2.new(0.5, 0, 1, 0)
	v.Position = UDim2.new(0.5, 0, 0, 0)
	v.BackgroundTransparency = 1
	v.Text = val
	v.TextColor3 = T.ink
	v.TextSize = 9
	v.Font = T.sansBold
	v.TextXAlignment = Enum.TextXAlignment.Right
	v.ZIndex = 17
	v.Parent = f
	return v
end

local vStatus  = statRow("Status",  "Ready",  1)
local vPicked  = statRow("Picked",  "0",      2)
local vPetted  = statRow("Petted",  "0",      3)
local vFish    = statRow("Fish",    "0",      4)
local vCats    = statRow("Found",   "0",      5)
local vLast    = statRow("Last",    "—",      6)

-- ═══════════════════════════════════════════
-- PAGE: FISH
-- ═══════════════════════════════════════════
local fishPage = Instance.new("Frame")
fishPage.Name = "FishPage"
fishPage.Size = UDim2.new(1, 0, 1, 0)
fishPage.BackgroundTransparency = 1
fishPage.BorderSizePixel = 0
fishPage.Visible = false
fishPage.ZIndex = 13
fishPage.Parent = pageContainer
tabPages["Fish"] = fishPage

local fishScroll = Instance.new("ScrollingFrame")
fishScroll.Size = UDim2.new(1, 0, 1, 0)
fishScroll.BackgroundTransparency = 1
fishScroll.BorderSizePixel = 0
fishScroll.ScrollBarThickness = 2
fishScroll.ScrollBarImageColor3 = T.inkTer
fishScroll.ZIndex = 14
fishScroll.Parent = fishPage
pad(fishScroll, 14, 14, 10, 10)
local fishLayout = list(fishScroll, nil, 8)
fishLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	fishScroll.CanvasSize = UDim2.new(0, 0, 0, fishLayout.AbsoluteContentSize.Y + 20)
end)

-- Fish illustration
local fishHero = Instance.new("Frame")
fishHero.Size = UDim2.new(1, 0, 0, 60)
fishHero.BackgroundColor3 = T.tealSoft
fishHero.BorderSizePixel = 0
fishHero.LayoutOrder = 1
fishHero.ZIndex = 15
fishHero.Parent = fishScroll
corner(fishHero, T.r12)

local fishHeroIcon = Instance.new("TextLabel")
fishHeroIcon.Size = UDim2.new(0, 40, 1, 0)
fishHeroIcon.Position = UDim2.new(0, 14, 0, 0)
fishHeroIcon.BackgroundTransparency = 1
fishHeroIcon.Text = "🐟"
fishHeroIcon.TextSize = 24
fishHeroIcon.Font = T.sansBook
fishHeroIcon.ZIndex = 16
fishHeroIcon.Parent = fishHero

local fishHeroText = Instance.new("TextLabel")
fishHeroText.Size = UDim2.new(1, -70, 1, 0)
fishHeroText.Position = UDim2.new(0, 58, 0, 0)
fishHeroText.BackgroundTransparency = 1
fishHeroText.Text = "Auto Fish Pickup\nDetects VFX spawns & guards zone 42"
fishHeroText.TextColor3 = T.ink
fishHeroText.TextSize = 10
fishHeroText.Font = T.sans
fishHeroText.TextXAlignment = Enum.TextXAlignment.Left
fishHeroText.TextYAlignment = Enum.TextYAlignment.Center
fishHeroText.TextWrapped = true
fishHeroText.ZIndex = 16
fishHeroText.Parent = fishHero

secHead(fishScroll, "Options", 2)

local fishAutoGet, fishAutoSet = toggleSwitch(fishScroll, "Auto Pickup Fish", false, 3)
local fishGuardGet, fishGuardSet = toggleSwitch(fishScroll, "Guard Zone 42", false, 4)

-- Fish stats
secHead(fishScroll, "Activity", 10)

local fishLog = Instance.new("Frame")
fishLog.Size = UDim2.new(1, 0, 0, 0)
fishLog.AutomaticSize = Enum.AutomaticSize.Y
fishLog.BackgroundColor3 = T.recessed
fishLog.BorderSizePixel = 0
fishLog.LayoutOrder = 11
fishLog.ZIndex = 15
fishLog.ClipsDescendants = true
fishLog.Parent = fishScroll
corner(fishLog, T.r8)
pad(fishLog, 10, 10, 8, 8)
local fishLogLayout = list(fishLog, nil, 2)

local fishLogCount = 0

local function addFishLog(msg, color)
	fishLogCount = fishLogCount + 1
	local e = Instance.new("TextLabel")
	e.Size = UDim2.new(1, 0, 0, 0)
	e.AutomaticSize = Enum.AutomaticSize.Y
	e.BackgroundTransparency = 1
	e.Text = os.date("%H:%M:%S") .. "  " .. msg
	e.TextColor3 = color or T.inkSec
	e.TextSize = 9
	e.Font = T.mono
	e.TextXAlignment = Enum.TextXAlignment.Left
	e.TextWrapped = true
	e.LayoutOrder = fishLogCount
	e.ZIndex = 16
	e.Parent = fishLog
	-- Limit
	if fishLogCount > 40 then
		for _, c in ipairs(fishLog:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() break end
		end
	end
end

addFishLog("Fish module ready", T.teal)

-- ═══════════════════════════════════════════
-- PAGE: LOG
-- ═══════════════════════════════════════════
local logPage = Instance.new("Frame")
logPage.Name = "LogPage"
logPage.Size = UDim2.new(1, 0, 1, 0)
logPage.BackgroundTransparency = 1
logPage.BorderSizePixel = 0
logPage.Visible = false
logPage.ZIndex = 13
logPage.Parent = pageContainer
tabPages["Log"] = logPage

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, 0, 1, 0)
logScroll.BackgroundColor3 = T.recessed
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = T.inkTer
logScroll.ZIndex = 14
logScroll.Parent = logPage
pad(logScroll, 10, 10, 8, 8)
corner(logScroll, T.r8)
local logListLayout = list(logScroll, nil, 1)
logListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	logScroll.CanvasSize = UDim2.new(0, 0, 0, logListLayout.AbsoluteContentSize.Y + 16)
end)

local logIdx = 0
local function addLog(msg, color)
	logIdx = logIdx + 1
	local e = Instance.new("TextLabel")
	e.Size = UDim2.new(1, 0, 0, 0)
	e.AutomaticSize = Enum.AutomaticSize.Y
	e.BackgroundTransparency = 1
	e.Text = os.date("%H:%M:%S") .. "  " .. msg
	e.TextColor3 = color or T.inkSec
	e.TextSize = 9
	e.Font = T.mono
	e.TextXAlignment = Enum.TextXAlignment.Left
	e.TextWrapped = true
	e.LayoutOrder = logIdx
	e.ZIndex = 15
	e.Parent = logScroll
	task.defer(function()
		logScroll.CanvasPosition = Vector2.new(0, logListLayout.AbsoluteContentSize.Y)
	end)
	if logIdx > 100 then
		for _, c in ipairs(logScroll:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() break end
		end
	end
end

addLog("Manager initialized", T.positive)
addLog("Player: " .. player.Name, T.inkTer)

-- ═══════════════════════════════════════════
-- CORE DATA
-- ═══════════════════════════════════════════
local autoPickupRunning = false
local autoPetRunning = false
local manualSelected = {}
local pickedUp = 0
local petted = 0
local fishPickedUp = 0
local catsInBase = {}
local catWidgets = {}

local function setStatus(text, color)
	vStatus.Text = text
	if color then vStatus.TextColor3 = color end
	liveDot.BackgroundColor3 = color or T.positive
end

local function updateStats(last)
	vPicked.Text = tostring(pickedUp)
	vPetted.Text = tostring(petted)
	vFish.Text = tostring(fishPickedUp)
	vCats.Text = tostring(#catsInBase)
	vLast.Text = last or "—"
end

-- ═══════════════════════════════════════════
-- TOP 3 RARITY (REALTIME)
-- ═══════════════════════════════════════════
local function getTop3()
	local byName = {}
	for _, c in ipairs(catsInBase) do
		if not byName[c.name] then
			byName[c.name] = RARITY_ORDER[c.rarity] or 99
		end
	end
	local sorted = {}
	for n, o in pairs(byName) do table.insert(sorted, {n = n, o = o}) end
	table.sort(sorted, function(a, b) return a.o < b.o end)
	local t = {}
	for i = 1, math.min(3, #sorted) do t[sorted[i].n] = true end
	return t
end

local function getEffective()
	local mode = getMode()
	if mode == "all" then
		local a = {}
		for _, c in ipairs(catsInBase) do a[c.name] = true end
		return a
	elseif mode == "top3" then
		return getTop3()
	else
		local combined = {}
		for n, _ in pairs(manualSelected) do combined[n] = true end
		for n, _ in pairs(getTop3()) do combined[n] = true end
		return combined
	end
end

-- ═══════════════════════════════════════════
-- SCAN CATS
-- ═══════════════════════════════════════════
local function scanCats()
	catsInBase = {}
	setStatus("Scanning...", T.caution)

	local base, catsFolder = findBase()
	if not base then
		setStatus("No base", T.negative)
		addLog("Base not found", T.negative)
		return
	end
	if not catsFolder then
		setStatus("No cats", T.negative)
		addLog("Cats folder missing", T.negative)
		return
	end

	for _, m in ipairs(catsFolder:GetChildren()) do
		if m:IsA("Model") then
			local aid = m:GetAttribute("animalId")
			if aid then
				local n = m:GetAttribute("name") or m.Name
				local ok, cfg = pcall(function() return AnimalConfig[n] end)
				if ok and cfg then
					table.insert(catsInBase, {
						id = aid, name = n, model = m,
						rarity = cfg.Rarity or "Common",
					})
				end
			end
		end
	end

	-- Clear old widgets
	for _, w in ipairs(catWidgets) do
		if w and w.Parent then w:Destroy() end
	end
	catWidgets = {}

	local top3 = getTop3()
	local count = #catsInBase

	if count == 0 then
		setStatus("Empty", T.caution)
		addLog("No cats found", T.caution)

		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 50)
		empty.BackgroundTransparency = 1
		empty.Text = "No cats detected\nTap Scan to retry"
		empty.TextColor3 = T.inkTer
		empty.TextSize = 10
		empty.Font = T.sansBook
		empty.TextWrapped = true
		empty.ZIndex = 16
		empty.Parent = catLeft
		table.insert(catWidgets, empty)
		updateStats()
		return
	end

	-- Group
	local groups = {}
	for _, c in ipairs(catsInBase) do
		if not groups[c.name] then groups[c.name] = {count = 0, rarity = c.rarity} end
		groups[c.name].count = groups[c.name].count + 1
	end

	local sorted = {}
	for n, d in pairs(groups) do table.insert(sorted, {name = n, count = d.count, rarity = d.rarity}) end
	table.sort(sorted, function(a, b)
		local oa, ob = RARITY_ORDER[a.rarity] or 99, RARITY_ORDER[b.rarity] or 99
		if oa ~= ob then return oa < ob end
		return a.name < b.name
	end)

	for i, data in ipairs(sorted) do
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = manualSelected[data.name] and T.positiveSoft or T.panel
		row.BorderSizePixel = 0
		row.AutoButtonColor = false
		row.ClipsDescendants = true
		row.LayoutOrder = i
		row.Text = ""
		row.ZIndex = 16
		row.Parent = catLeft
		corner(row, T.r8)
		stroke(row, T.divider, 1)

		-- Rarity bar
		local rBar = Instance.new("Frame")
		rBar.Size = UDim2.new(0, 3, 0.5, 0)
		rBar.Position = UDim2.new(0, 5, 0.25, 0)
		rBar.BackgroundColor3 = RARITY_COLORS[data.rarity] or T.inkTer
		rBar.BorderSizePixel = 0
		rBar.ZIndex = 18
		rBar.Parent = row
		corner(rBar, T.rPill)

		-- Name
		local nLbl = Instance.new("TextLabel")
		nLbl.Size = UDim2.new(1, -68, 0, 16)
		nLbl.Position = UDim2.new(0, 16, 0, 5)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = data.name
		nLbl.TextColor3 = T.ink
		nLbl.TextSize = 11
		nLbl.Font = manualSelected[data.name] and T.sansBold or T.sans
		nLbl.TextXAlignment = Enum.TextXAlignment.Left
		nLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nLbl.ZIndex = 18
		nLbl.Parent = row

		-- Subtitle
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -16, 0, 12)
		sub.Position = UDim2.new(0, 16, 0, 22)
		sub.BackgroundTransparency = 1
		sub.Text = data.rarity .. "  ×" .. data.count
		sub.TextColor3 = T.inkTer
		sub.TextSize = 9
		sub.Font = T.sansBook
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.ZIndex = 18
		sub.Parent = row

		-- Badges container
		local badges = Instance.new("Frame")
		badges.Size = UDim2.new(0, 50, 0, 18)
		badges.Position = UDim2.new(1, -56, 0, 11)
		badges.BackgroundTransparency = 1
		badges.ZIndex = 18
		badges.Parent = row
		list(badges, Enum.FillDirection.Horizontal, 3).HorizontalAlignment = Enum.HorizontalAlignment.Right

		-- Top 3 badge
		if top3[data.name] then
			local star = Instance.new("TextLabel")
			star.Size = UDim2.new(0, 18, 0, 18)
			star.BackgroundColor3 = T.cautionSoft
			star.Text = "★"
			star.TextColor3 = T.caution
			star.TextSize = 10
			star.Font = T.sansBook
			star.ZIndex = 19
			star.Parent = badges
			corner(star, T.rPill)
		end

		-- Check
		local chk = Instance.new("TextLabel")
		chk.Name = "Chk"
		chk.Size = UDim2.new(0, 18, 0, 18)
		chk.BackgroundColor3 = manualSelected[data.name] and T.positiveSoft or Color3.new(0,0,0)
		chk.BackgroundTransparency = manualSelected[data.name] and 0 or 1
		chk.Text = manualSelected[data.name] and "✓" or ""
		chk.TextColor3 = T.positive
		chk.TextSize = 10
		chk.Font = T.sansBold
		chk.ZIndex = 19
		chk.Parent = badges
		corner(chk, T.r4)

		table.insert(catWidgets, row)

		-- Tap to toggle manual selection
		row.MouseButton1Click:Connect(function()
			pressAnim(row)
			if manualSelected[data.name] then
				manualSelected[data.name] = nil
				tw(row, {BackgroundColor3 = T.panel}, 0.12)
				nLbl.Font = T.sans
				chk.Text = ""
				chk.BackgroundTransparency = 1
				addLog("− " .. data.name, T.inkSec)
			else
				manualSelected[data.name] = true
				tw(row, {BackgroundColor3 = T.positiveSoft}, 0.12)
				nLbl.Font = T.sansBold
				chk.Text = "✓"
				chk.BackgroundTransparency = 0
				chk.BackgroundColor3 = T.positiveSoft
				addLog("+ " .. data.name, T.positive)
			end
		end)
	end

	setStatus(count .. " cats", T.positive)
	addLog("Scanned: " .. count .. " cats, " .. #sorted .. " types", T.positive)
	updateStats()
end

-- ═══════════════════════════════════════════
-- BUTTON HANDLERS
-- ═══════════════════════════════════════════
scanBtn.MouseButton1Click:Connect(function()
	scanBtn.Text = "..."
	tw(scanBtn, {BackgroundColor3 = T.divider}, 0.1)
	scanCats()
	task.wait(0.2)
	scanBtn.Text = "Scan"
	tw(scanBtn, {BackgroundColor3 = T.accent}, 0.2)
end)

-- Auto Pickup
local function pickupLoop()
	while autoPickupRunning do
		pcall(function()
			scanCats()
			local eff = getEffective()
			for _, cat in ipairs(catsInBase) do
				if not autoPickupRunning then break end
				if eff[cat.name] and cat.model and cat.model.Parent then
					local ok = pcall(function()
						BaseService.RF.PickupAnimal:InvokeServer(cat.id)
					end)
					if ok then
						pickedUp = pickedUp + 1
						task.wait(0.3)
						pcall(function()
							BaseService.RF.PutdownAnimal:InvokeServer(cat.id)
						end)
						updateStats(cat.name)
						addLog("↑↓ " .. cat.name, T.positive)
						task.wait(0.5)
						break
					end
				end
			end
		end)
		task.wait(2)
	end
end

pickupBtn.MouseButton1Click:Connect(function()
	autoPickupRunning = not autoPickupRunning
	if autoPickupRunning then
		local eff = getEffective()
		if not next(eff) then
			autoPickupRunning = false
			setStatus("Select cats", T.negative)
			addLog("No cats to pickup", T.negative)
			return
		end
		pickupBtn.Text = "Stop Pickup"
		tw(pickupBtn, {BackgroundColor3 = T.negative}, 0.2)
		setStatus("Pickup ●", T.positive)
		addLog("Pickup started [" .. getMode() .. "]", T.positive)
		task.spawn(pickupLoop)
	else
		pickupBtn.Text = "Auto Pickup"
		tw(pickupBtn, {BackgroundColor3 = T.positive}, 0.2)
		setStatus("Stopped", T.inkTer)
		addLog("Pickup stopped", T.caution)
	end
end)

-- Auto Pet
local function petLoop()
	while autoPetRunning do
		pcall(function()
			local eff = getEffective()
			for _, cat in ipairs(catsInBase) do
				if not autoPetRunning then break end
				if eff[cat.name] and cat.model and cat.model.Parent then
					local ok = pcall(function()
						BaseService.RF.PetAnimal:InvokeServer(cat.id)
					end)
					if ok then
						petted = petted + 1
						updateStats(cat.name .. " ♡")
						addLog("♡ " .. cat.name, T.violet)
						task.wait(0.5)
					end
				end
			end
		end)
		task.wait(1)
	end
end

petBtn.MouseButton1Click:Connect(function()
	autoPetRunning = not autoPetRunning
	if autoPetRunning then
		local eff = getEffective()
		if not next(eff) then
			autoPetRunning = false
			setStatus("Select cats", T.negative)
			return
		end
		petBtn.Text = "Stop Pet"
		tw(petBtn, {BackgroundColor3 = T.negative}, 0.2)
		setStatus("Pet ●", T.violet)
		addLog("Pet started [" .. getMode() .. "]", T.violet)
		task.spawn(petLoop)
	else
		petBtn.Text = "Auto Pet"
		tw(petBtn, {BackgroundColor3 = T.violet}, 0.2)
		setStatus("Stopped", T.inkTer)
		addLog("Pet stopped", T.caution)
	end
end)

-- ═══════════════════════════════════════════
-- FISH: VFX WATCHER
-- ═══════════════════════════════════════════
local function teleportTo(pos)
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(pos) end
	end
end

task.spawn(function()
	local vfx = Workspace:WaitForChild("VFX", 30)
	if not vfx then
		addFishLog("VFX folder not found", T.caution)
		addLog("WARN: No VFX folder", T.caution)
		return
	end
	addFishLog("Watching VFX...", T.teal)
	addLog("Fish watcher active", T.teal)

	local function handleFish(child)
		if not fishAutoGet() then return end
		if child.Name == "PickupFish" or child.Name:find("PickupFish") then
			local pos
			if child:IsA("Model") then
				local p = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
				if p then pos = p.Position end
			elseif child:IsA("BasePart") then
				pos = child.Position
			end
			if pos then
				teleportTo(pos)
				fishPickedUp = fishPickedUp + 1
				updateStats("Fish!")
				addFishLog("Teleported → fish", T.positive)
				addLog("🐟 Fish pickup @ " .. tostring(math.floor(pos.X)) .. "," .. tostring(math.floor(pos.Z)), T.teal)
			end
		end
	end

	vfx.ChildAdded:Connect(function(child)
		task.wait(0.1)
		handleFish(child)
	end)
	for _, c in ipairs(vfx:GetChildren()) do handleFish(c) end
end)

-- ═══════════════════════════════════════════
-- FISH: GUARD ZONE 42
-- ═══════════════════════════════════════════
task.spawn(function()
	local newMap = Workspace:FindFirstChild("NewMap")
	if not newMap then
		addFishLog("NewMap not found", T.caution)
		return
	end
	local ch = newMap:GetChildren()
	if #ch < 42 then
		addFishLog("NewMap < 42 children", T.caution)
		return
	end
	local zone = ch[42]
	addFishLog("Zone 42: " .. zone.Name, T.teal)
	addLog("Guard zone: " .. zone.Name, T.teal)

	local parts = {}
	if zone:IsA("BasePart") then
		table.insert(parts, zone)
	else
		for _, p in ipairs(zone:GetDescendants()) do
			if p:IsA("BasePart") then table.insert(parts, p) end
		end
	end

	for _, zp in ipairs(parts) do
		zp.Touched:Connect(function(hit)
			if not fishGuardGet() then return end
			local _, catsFolder = findBase()
			if not catsFolder then return end
			local mdl = hit.Parent
			while mdl and mdl ~= catsFolder do
				if mdl.Parent == catsFolder then
					local aid = mdl:GetAttribute("animalId")
					if aid then
						local name = mdl:GetAttribute("name") or mdl.Name
						addFishLog("Guard: " .. name, T.caution)
						addLog("⚠ Zone 42: " .. name, T.caution)
						pcall(function() BaseService.RF.PickupAnimal:InvokeServer(aid) end)
						task.wait(0.3)
						pcall(function() BaseService.RF.PutdownAnimal:InvokeServer(aid) end)
						pickedUp = pickedUp + 1
						updateStats("Guard: " .. name)
					end
					break
				end
				mdl = mdl.Parent
			end
		end)
	end
end)

-- ═══════════════════════════════════════════
-- DRAG (Mouse + Touch)
-- ═══════════════════════════════════════════
local dragging, dragStart, startPos = false, nil, nil

chrome.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		startPos = card.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = Vector2.new(input.Position.X, input.Position.Y) - dragStart
		card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

-- ═══════════════════════════════════════════
-- ENTRANCE
-- ═══════════════════════════════════════════
card.BackgroundTransparency = 1
card.Size = UDim2.new(0, 540, 0, 0)

task.defer(function()
	tw(scrim, {BackgroundTransparency = 0.97}, 0.3)
	tw(card, {BackgroundTransparency = 0, Size = fullSize}, 0.4, Enum.EasingStyle.Quint)
end)

-- Auto initial scan
task.delay(0.8, function()
	scanCats()
end)

switchTab("Cats")
print("Cat · Fish Manager v3 loaded")