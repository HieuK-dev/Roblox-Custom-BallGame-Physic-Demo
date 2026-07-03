-- File: ServerScriptService > PlayerManager
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Disable default character spawning
Players.CharacterAutoLoads = false 

local respawnEvent = ServerStorage:WaitForChild("RespawnBallEvent")

-- Clean up existing character models
local function cleanup(player)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == player.Name then
            obj:Destroy()
        end
    end
end

-- Core logic: Spawn custom physics ball
local function spawnBall(player)
    cleanup(player)
    
    local leaderstats = player:WaitForChild("leaderstats")
    local sizeValue = leaderstats:WaitForChild("Size")

    local baseScale = sizeValue.Value / 2.5

    local charModel = Instance.new("Model")
    charModel.Name = player.Name 

    local ball = Instance.new("Part")
    ball.Name = "HumanoidRootPart" 
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(baseScale, baseScale, baseScale)
    ball.Position = Vector3.new(math.random(-10, 10), baseScale, math.random(-10, 10))
    ball.Material = Enum.Material.SmoothPlastic

    local attachment = Instance.new("Attachment", ball)
    local linearVel = Instance.new("LinearVelocity", ball)
    linearVel.Name = "LinearVelocity"
    linearVel.Attachment0 = attachment
    linearVel.MaxForce = 100000 
    linearVel.VectorVelocity = Vector3.new(0, 0, 0)
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World

    -- Dummy Humanoid for camera tracking
    local humanoid = Instance.new("Humanoid")
    humanoid.PlatformStand = true 
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None 
    humanoid.Parent = charModel

    ball.Parent = charModel
    charModel.PrimaryPart = ball
    charModel.Parent = workspace

    player.Character = charModel
    ball:SetNetworkOwner(player)

    -- Handle dynamic resizing
    local sizeConnection
    sizeConnection = sizeValue:GetPropertyChangedSignal("Value"):Connect(function()
        if not ball or not ball.Parent then 
            sizeConnection:Disconnect()
            return 
        end
        local newScale = sizeValue.Value / 2.5
        ball.Size = Vector3.new(newScale, newScale, newScale)
    end)

    -- PvP Collision Logic (Eat smaller players)
    ball.Touched:Connect(function(hit)
        if hit.Name == "HumanoidRootPart" then 
            local enemyModel = hit.Parent
            local enemyPlayer = Players:GetPlayerFromCharacter(enemyModel)

            if enemyPlayer and enemyPlayer ~= player then
                local enemySizeValue = enemyPlayer.leaderstats.Size

                if enemyModel.Parent == workspace then
                    if sizeValue.Value > enemySizeValue.Value then
                        -- Consume enemy
                        sizeValue.Value += math.floor(enemySizeValue.Value / 2)
                        enemySizeValue.Value = 10
                        enemyModel:Destroy()

                        task.delay(2, function()
                            if enemyPlayer.Parent then 
                                spawnBall(enemyPlayer)
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    player:LoadCharacterAppearance(charModel)
end

-- Initialize Leaderstats
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local size = Instance.new("IntValue")
    size.Name = "Size"
    size.Value = 10 
    size.Parent = leaderstats

    local rebirths = Instance.new("IntValue")
    rebirths.Name = "Rebirths"
    rebirths.Value = 0
    rebirths.Parent = leaderstats

    spawnBall(player)
end)

-- Listen for custom respawn requests
respawnEvent.Event:Connect(function(player)
    if player and player.Parent then
        spawnBall(player)
    end
end)