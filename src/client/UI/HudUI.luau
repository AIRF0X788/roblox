--[[
	HudUI.luau
	Main HUD: displays money, brainrot count, income per cycle,
	and base capacity at the top of the screen.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").Modules.GameConfig)
local Utils = require(ReplicatedStorage.Shared.Modules.Utils)
local UIBuilder = require(script.Parent.UIBuilder)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HudUI = {}

local screenGui
local moneyLabel
local brainrotCountLabel
local incomeLabel
local capacityBar

function HudUI.Create()
	screenGui = UIBuilder.CreateScreenGui("HudGui", playerGui)

	-- Top bar
	local topBar = UIBuilder.CreateFrame({
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 25),
		BackgroundTransparency = 0.2,
		Parent = screenGui,
	})

	-- Money display
	local moneyFrame = UIBuilder.CreateFrame({
		Name = "MoneyFrame",
		Size = UDim2.new(0, 250, 0, 40),
		Position = UDim2.new(0, 15, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 45),
		CornerRadius = UDim.new(0, 10),
		Parent = topBar,
	})

	UIBuilder.CreateLabel({
		Name = "MoneyIcon",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 8, 0.5, 0),
		Text = "💰",
		Parent = moneyFrame,
	}).AnchorPoint = Vector2.new(0, 0.5)

	moneyLabel = UIBuilder.CreateLabel({
		Name = "MoneyText",
		Size = UDim2.new(1, -45, 1, 0),
		Position = UDim2.new(0, 42, 0, 0),
		Text = "$0",
		TextColor3 = UIBuilder.Colors.AccentGold,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = moneyFrame,
	})

	-- Brainrot count
	local brainrotFrame = UIBuilder.CreateFrame({
		Name = "BrainrotFrame",
		Size = UDim2.new(0, 200, 0, 40),
		Position = UDim2.new(0, 280, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 45),
		CornerRadius = UDim.new(0, 10),
		Parent = topBar,
	})

	UIBuilder.CreateLabel({
		Name = "BrainrotIcon",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 8, 0.5, 0),
		Text = "🧠",
		Parent = brainrotFrame,
	}).AnchorPoint = Vector2.new(0, 0.5)

	brainrotCountLabel = UIBuilder.CreateLabel({
		Name = "CountText",
		Size = UDim2.new(1, -45, 1, 0),
		Position = UDim2.new(0, 42, 0, 0),
		Text = "0/5",
		TextColor3 = UIBuilder.Colors.Accent,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = brainrotFrame,
	})

	-- Income per cycle
	local incomeFrame = UIBuilder.CreateFrame({
		Name = "IncomeFrame",
		Size = UDim2.new(0, 200, 0, 40),
		Position = UDim2.new(0, 495, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 45),
		CornerRadius = UDim.new(0, 10),
		Parent = topBar,
	})

	UIBuilder.CreateLabel({
		Name = "IncomeIcon",
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 8, 0.5, 0),
		Text = "📈",
		Parent = incomeFrame,
	}).AnchorPoint = Vector2.new(0, 0.5)

	incomeLabel = UIBuilder.CreateLabel({
		Name = "IncomeText",
		Size = UDim2.new(1, -45, 1, 0),
		Position = UDim2.new(0, 42, 0, 0),
		Text = "$0/cycle",
		TextColor3 = UIBuilder.Colors.AccentGreen,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = incomeFrame,
	})
end

------------------------------------------------------------
-- UPDATE FUNCTIONS (called by PlayerState callbacks)
------------------------------------------------------------

function HudUI.UpdateMoney(amount: number)
	if moneyLabel then
		moneyLabel.Text = Utils.FormatMoney(amount)
	end
end

function HudUI.UpdateBrainrots(brainrots: { any }, maxBrainrots: number)
	if brainrotCountLabel then
		brainrotCountLabel.Text = tostring(#brainrots) .. "/" .. tostring(maxBrainrots)

		-- Color warning when near full
		local ratio = #brainrots / maxBrainrots
		if ratio >= 1 then
			brainrotCountLabel.TextColor3 = UIBuilder.Colors.AccentRed
		elseif ratio >= 0.8 then
			brainrotCountLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
		else
			brainrotCountLabel.TextColor3 = UIBuilder.Colors.Accent
		end
	end

	-- Update income
	if incomeLabel then
		local totalIncome = 0
		for _, b in ipairs(brainrots) do
			totalIncome = totalIncome + (b.MoneyPerCycle or 0)
		end
		incomeLabel.Text = Utils.FormatMoney(totalIncome) .. "/cycle"
	end
end

return HudUI
