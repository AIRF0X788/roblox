--[[
	UIBuilder.luau
	Utility module to create consistent UI elements.
	Provides factory functions for common UI components.
]]

local UIBuilder = {}

-- Color palette
UIBuilder.Colors = {
	Background      = Color3.fromRGB(20, 20, 30),
	BackgroundLight = Color3.fromRGB(35, 35, 50),
	Panel           = Color3.fromRGB(30, 30, 45),
	PanelHover      = Color3.fromRGB(45, 45, 65),
	Accent          = Color3.fromRGB(0, 170, 255),
	AccentGold      = Color3.fromRGB(255, 200, 50),
	AccentGreen     = Color3.fromRGB(50, 200, 80),
	AccentRed       = Color3.fromRGB(220, 60, 60),
	TextPrimary     = Color3.fromRGB(255, 255, 255),
	TextSecondary   = Color3.fromRGB(180, 180, 200),
	TextMuted       = Color3.fromRGB(120, 120, 140),
}

function UIBuilder.CreateScreenGui(name: string, parent: Instance): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = false
	gui.Parent = parent
	return gui
end

function UIBuilder.CreateFrame(props: {
	Name: string?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	Parent: Instance?,
	CornerRadius: UDim?,
}): Frame
	local frame = Instance.new("Frame")
	frame.Name = props.Name or "Frame"
	frame.Size = props.Size or UDim2.new(1, 0, 1, 0)
	frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
	frame.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	frame.BackgroundColor3 = props.BackgroundColor3 or UIBuilder.Colors.Panel
	frame.BackgroundTransparency = props.BackgroundTransparency or 0
	frame.BorderSizePixel = 0

	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = props.CornerRadius
		corner.Parent = frame
	end

	if props.Parent then
		frame.Parent = props.Parent
	end

	return frame
end

function UIBuilder.CreateLabel(props: {
	Name: string?,
	Size: UDim2?,
	Position: UDim2?,
	Text: string?,
	TextColor3: Color3?,
	TextSize: number?,
	TextScaled: boolean?,
	Font: Enum.Font?,
	TextXAlignment: Enum.TextXAlignment?,
	Parent: Instance?,
}): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = props.Name or "Label"
	label.Size = props.Size or UDim2.new(1, 0, 1, 0)
	label.Position = props.Position or UDim2.new(0, 0, 0, 0)
	label.Text = props.Text or ""
	label.TextColor3 = props.TextColor3 or UIBuilder.Colors.TextPrimary
	label.BackgroundTransparency = 1
	label.Font = props.Font or Enum.Font.GothamBold
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center

	if props.TextScaled ~= false then
		label.TextScaled = true
	else
		label.TextSize = props.TextSize or 14
	end

	if props.Parent then
		label.Parent = props.Parent
	end

	return label
end

function UIBuilder.CreateButton(props: {
	Name: string?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Text: string?,
	TextColor3: Color3?,
	BackgroundColor3: Color3?,
	Font: Enum.Font?,
	CornerRadius: UDim?,
	Parent: Instance?,
	OnClick: (() -> ())?,
}): TextButton
	local button = Instance.new("TextButton")
	button.Name = props.Name or "Button"
	button.Size = props.Size or UDim2.new(0, 150, 0, 40)
	button.Position = props.Position or UDim2.new(0, 0, 0, 0)
	button.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	button.Text = props.Text or "Button"
	button.TextColor3 = props.TextColor3 or UIBuilder.Colors.TextPrimary
	button.BackgroundColor3 = props.BackgroundColor3 or UIBuilder.Colors.Accent
	button.BorderSizePixel = 0
	button.Font = props.Font or Enum.Font.GothamBold
	button.TextScaled = true
	button.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = props.CornerRadius or UDim.new(0, 8)
	corner.Parent = button

	-- Padding inside button text
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = button

	if props.OnClick then
		button.MouseButton1Click:Connect(props.OnClick)
	end

	if props.Parent then
		button.Parent = props.Parent
	end

	return button
end

function UIBuilder.CreateScrollFrame(props: {
	Name: string?,
	Size: UDim2?,
	Position: UDim2?,
	Parent: Instance?,
	CanvasSize: UDim2?,
}): ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = props.Name or "ScrollFrame"
	scroll.Size = props.Size or UDim2.new(1, 0, 1, 0)
	scroll.Position = props.Position or UDim2.new(0, 0, 0, 0)
	scroll.CanvasSize = props.CanvasSize or UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = UIBuilder.Colors.Accent
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0

	if props.Parent then
		scroll.Parent = props.Parent
	end

	return scroll
end

function UIBuilder.AddListLayout(parent: Instance, padding: UDim?, fillDirection: Enum.FillDirection?): UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.Padding = padding or UDim.new(0, 4)
	layout.FillDirection = fillDirection or Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

function UIBuilder.AddGridLayout(parent: Instance, cellSize: UDim2?, cellPadding: UDim2?): UIGridLayout
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = cellSize or UDim2.new(0, 100, 0, 100)
	layout.CellPadding = cellPadding or UDim2.new(0, 6, 0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

return UIBuilder
