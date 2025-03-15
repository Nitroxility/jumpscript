getgenv().jump = {
    enabled = false,
    power = 50,
    keybind = Enum.KeyCode.KeypadMultiply 
}

local function setJumpPower(player, power)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = power
    end
end

local function applyJumpBoost(player)
    local character = player.Character or player.CharacterAdded:Wait()

    if jump.enabled then
        setJumpPower(player, jump.power)
    else
        setJumpPower(player, 50) 
    end
end

local function toggleJumpBoost()
    jump.enabled = not jump.enabled
    print("Jump boost enabled:", jump.enabled)
    applyJumpBoost(game.Players.LocalPlayer)
end

local player = game.Players.LocalPlayer

if player.Character then
    applyJumpBoost(player)
end

player.CharacterAdded:Connect(function()
    applyJumpBoost(player)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == jump.keybind then
        toggleJumpBoost()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if jump.enabled then
        setJumpPower(player, jump.power)
    end
end)
