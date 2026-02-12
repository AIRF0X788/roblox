--[[
	RemoteHelper.luau (Client)
	Helper to easily access remotes from the client side.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Shared").Modules.RemoteNames)

local RemoteHelper = {}

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

function RemoteHelper.GetEvent(name: string): RemoteEvent?
	return remotesFolder:WaitForChild(name, 10)
end

function RemoteHelper.GetFunction(name: string): RemoteFunction?
	return remotesFolder:WaitForChild(name, 10)
end

function RemoteHelper.FireServer(eventName: string, data: any?)
	local event = RemoteHelper.GetEvent(eventName)
	if event then
		event:FireServer(data)
	else
		warn("[RemoteHelper] Event not found: " .. eventName)
	end
end

function RemoteHelper.InvokeServer(funcName: string, ...): any
	local func = RemoteHelper.GetFunction(funcName)
	if func then
		return func:InvokeServer(...)
	else
		warn("[RemoteHelper] Function not found: " .. funcName)
		return nil
	end
end

return RemoteHelper
