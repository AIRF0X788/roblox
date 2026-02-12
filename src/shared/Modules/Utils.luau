--[[
	Utils.luau
	Shared utility functions used by both server and client.
]]

local Utils = {}

-- Format a number with commas: 1234567 -> "1,234,567"
function Utils.FormatMoney(amount: number): string
	local formatted = tostring(math.floor(amount))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return "$" .. formatted
end

-- Short format: 1500 -> "1.5K", 2300000 -> "2.3M"
function Utils.FormatShort(amount: number): string
	if amount >= 1000000000 then
		return string.format("$%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(math.floor(amount))
	end
end

-- Deep copy a table
function Utils.DeepCopy(original)
	if type(original) ~= "table" then
		return original
	end
	local copy = {}
	for key, value in pairs(original) do
		copy[Utils.DeepCopy(key)] = Utils.DeepCopy(value)
	end
	return copy
end

-- Generate a unique ID
local idCounter = 0
function Utils.GenerateId(): string
	idCounter = idCounter + 1
	return tostring(tick()) .. "_" .. tostring(idCounter) .. "_" .. tostring(math.random(1000, 9999))
end

-- Lerp between two colors
function Utils.LerpColor(c1: Color3, c2: Color3, alpha: number): Color3
	return Color3.new(
		c1.R + (c2.R - c1.R) * alpha,
		c1.G + (c2.G - c1.G) * alpha,
		c1.B + (c2.B - c1.B) * alpha
	)
end

return Utils
