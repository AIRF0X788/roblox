--[[
	RemoteSetup.luau
	Creates all RemoteEvents and RemoteFunctions in ReplicatedStorage.Remotes
	so both server and client can reference them.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteNames = require(ReplicatedStorage.Shared.Modules.RemoteNames)

local RemoteSetup = {}

function RemoteSetup.Init()
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = ReplicatedStorage
	end

	-- Create all RemoteEvents
	for _, eventName in pairs(RemoteNames.Events) do
		if not remotesFolder:FindFirstChild(eventName) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = eventName
			remote.Parent = remotesFolder
		end
	end

	-- Create all RemoteFunctions
	for _, funcName in pairs(RemoteNames.Functions) do
		if not remotesFolder:FindFirstChild(funcName) then
			local remote = Instance.new("RemoteFunction")
			remote.Name = funcName
			remote.Parent = remotesFolder
		end
	end

	print("[RemoteSetup] All remotes created successfully.")
end

function RemoteSetup.GetEvent(name: string): RemoteEvent
	return ReplicatedStorage.Remotes:FindFirstChild(name)
end

function RemoteSetup.GetFunction(name: string): RemoteFunction
	return ReplicatedStorage.Remotes:FindFirstChild(name)
end

return RemoteSetup
