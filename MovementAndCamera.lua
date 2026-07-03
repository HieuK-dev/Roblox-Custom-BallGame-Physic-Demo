-- File: StarterPlayer > StarterPlayerScripts > MovementController
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local currentBall = nil
local linearVel = nil

-- Movement configuration
local MAX_SPEED = 40       
local ACCELERATION = 200   

local function setupNewBall(newCharacter)
    currentBall = newCharacter:WaitForChild("HumanoidRootPart") 
    linearVel = currentBall:WaitForChild("LinearVelocity")

    -- Lock camera focus to the rolling ball
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom 
    workspace.CurrentCamera.CameraSubject = currentBall
end

player.CharacterAdded:Connect(setupNewBall)
if player.Character then 
    setupNewBall(player.Character) 
end

RunService.Heartbeat:Connect(function()
    if not currentBall or not linearVel or not currentBall.Parent then return end 

    -- Calculate movement direction relative to camera perspective
    local moveDirection = Vector3.new(0, 0, 0)
    local camera = workspace.CurrentCamera

    -- Flatten camera vectors to prevent vertical bias
    local cameraLook = camera.CFrame.LookVector
    cameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit

    local cameraRight = camera.CFrame.RightVector
    cameraRight = Vector3.new(cameraRight.X, 0, cameraRight.Z).Unit

    -- Map inputs to direction vectors
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cameraLook end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cameraLook end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cameraRight end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cameraRight end

    -- Apply physics forces based on character mass
    linearVel.MaxForce = currentBall.Mass * ACCELERATION 

    if moveDirection.Magnitude > 0 then
        linearVel.VectorVelocity = moveDirection.Unit * MAX_SPEED
    else
        linearVel.VectorVelocity = Vector3.new(0, 0, 0)
    end
end)