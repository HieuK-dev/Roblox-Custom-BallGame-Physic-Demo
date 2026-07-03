-- File: Workspace > RebirthPillar > Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local pillar = script.Parent
local showEvent = ReplicatedStorage:WaitForChild("ShowRebirthUI")
local confirmEvent = ReplicatedStorage:WaitForChild("ConfirmRebirth")
local respawnEvent = ServerStorage:WaitForChild("RespawnBallEvent")

pillar.Touched:Connect(function(hit)
    -- Prevent triggering from accessories by getting the root model
    local character = hit:FindFirstAncestorOfClass("Model")
    
    if character then
        local player = Players:GetPlayerFromCharacter(character)
        
        if player then
            local currentRebirths = player.leaderstats.Rebirths.Value
            local requiredSize = (currentRebirths + 1) * 20

            showEvent:FireClient(player, requiredSize) 
        end
    end
end)

confirmEvent.OnServerEvent:Connect(function(player)
    local stats = player.leaderstats
    local currentRebirths = stats.Rebirths.Value
    local requiredSize = (currentRebirths + 1) * 20

    if stats.Size.Value >= requiredSize then
        -- Reset size and increment rebirth count
        stats.Size.Value = 10 
        stats.Rebirths.Value += 1

        -- Trigger custom respawn logic in PlayerManager
        respawnEvent:Fire(player)
    end
end)