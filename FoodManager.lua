-- File: ServerScriptService > FoodManager
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local maxFood = 20

-- Organize food objects
local foodFolder = Instance.new("Folder")
foodFolder.Name = "FoodFolder"
foodFolder.Parent = workspace

local function spawnSingleFood()
    local food = Instance.new("Part")
    food.Name = "Food"
    food.Size = Vector3.new(2, 2, 2)
    food.Shape = Enum.PartType.Ball
    food.BrickColor = BrickColor.Random() 

    -- Randomize spawn position
    local randomX = math.random(-100, 100)
    local randomZ = math.random(-100, 100)
    food.Position = Vector3.new(randomX, 2, randomZ)
    food.Parent = foodFolder

    -- Handle consumption logic
    food.Touched:Connect(function(hit)
        local character = hit.Parent
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoid then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                -- Scale size based on current Rebirths multiplier
                local currentRebirths = player.leaderstats.Rebirths.Value
                player.leaderstats.Size.Value += 1 + (currentRebirths * 2) 

                food:Destroy()
                spawnSingleFood() -- Respawn to maintain maxFood count
            end
        end
    end)
end

-- Initial spawn loop
for i = 1, maxFood do
    spawnSingleFood()
end