-- File: ServerScriptService > DataManager
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playerDataStore = DataStoreService:GetDataStore("PlayerStats_V4")

Players.PlayerAdded:Connect(function(player)
    -- Wait for leaderstats initialization
    local leaderstats = player:WaitForChild("leaderstats")
    local size = leaderstats:WaitForChild("Size")
    local rebirths = leaderstats:WaitForChild("Rebirths")

    -- Fetch player data safely
    local success, data = pcall(function()
        return playerDataStore:GetAsync(player.UserId .. "-Data")
    end)

    -- Apply saved data or fallback to defaults
    if success and data then
        size.Value = data.Size or 10 
        rebirths.Value = data.Rebirths or 0
    end
end)

-- Core save function
local function saveData(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        -- Bundle stats into a dictionary
        local dataToSave = {
            Size = leaderstats.Size.Value,
            Rebirths = leaderstats.Rebirths.Value
        }

        -- Save to DataStore
        pcall(function()
            playerDataStore:SetAsync(player.UserId .. "-Data", dataToSave)
        end)
    end
end

Players.PlayerRemoving:Connect(saveData)

-- Handle server shutdown
game:BindToClose(function()
    for _, player in pairs(Players:GetPlayers()) do
        saveData(player)
    end
    -- Yield to ensure all saves complete before shutdown
    task.wait(2) 
end)