local collar = require(game.ServerScriptService:WaitForChild("CollarCommand").Module)
local events = game.ReplicatedStorage:WaitForChild("CollarEvents")
local debounce = {}
local blockedBy = {}

events.SendRequest.OnServerEvent:Connect(function(player, target)
	if not debounce[player.Name] then
		debounce[player.Name] = true
		local received = events.PromptLocalUI:InvokeClient(target, player.Name)
		if received and received.result and received.result == "yes" then
			collar.MakeCollar(player, target)
		end
		wait (3.5)
		debounce[player.Name] = false
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	debounce[player.Name] = nil
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
	blockedBy[player.Name] = {}
end)


game:GetService("ReplicatedStorage").ServerEvents.SendRequest.OnServerEvent:Connect(function(player, target)
	if not debounce[player.Name] then
		debounce[player.Name] = true
		if blockedBy[player.Name][target.Name] then
			game:GetService("ReplicatedStorage").ServerEvents.SendRequest:FireClient(player)
			return
		end
		local received = game:GetService("ReplicatedStorage").ServerEvents.PromptLocalUI:InvokeClient(target, player.Name)
		if received and received.result and received.result == "yes" then
			local TS = game:GetService("TeleportService")
			local Players = {player,target}
			local DSS = game:GetService("DataStoreService")
			local DS = DSS:GetGlobalDataStore()
			
			local code = DS:GetAsync("ReservedServer")
			code = TS:ReserveServer(game.PlaceId)
			DS:SetAsync("ReservedServer",code)
			
			TS:TeleportToPrivateServer(game.PlaceId,code,Players)
		elseif received and received.result and received.result == "no" then
			blockedBy[player.Name][target.Name] = true
		end
		wait (3.5)
		debounce[player.Name] = false
	end
end)