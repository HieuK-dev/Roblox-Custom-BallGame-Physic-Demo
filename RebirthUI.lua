-- File: StarterGui > ScreenGui > Frame > LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local frame = script.Parent
frame.Visible = false

local showEvent = ReplicatedStorage:WaitForChild("ShowRebirthUI")
local confirmEvent = ReplicatedStorage:WaitForChild("ConfirmRebirth")

-- Listen for UI prompt from Server
showEvent.OnClientEvent:Connect(function(requiredSize)
    frame.Visible = true

    local infoLabel = frame:FindFirstChild("InfoLabel")
    if infoLabel then
        infoLabel.Text = "Need " .. tostring(requiredSize) .. " Size to Rebirth!"
    end
end)

-- Handle button interactions gracefully
local btnAccept = frame:FindFirstChild("Yes") or frame:FindFirstChildOfClass("TextButton")
local btnCancel = frame:FindFirstChild("No")

if btnAccept then
    btnAccept.MouseButton1Click:Connect(function()
        confirmEvent:FireServer()
        frame.Visible = false
    end)
else
    warn("Missing Accept Button in Rebirth UI Frame")
end

if btnCancel then
    btnCancel.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)
end