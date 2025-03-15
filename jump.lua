local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Auto Kill Settings
getgenv().autoKillEnemies = {
    enabled = false,
    questNPC = "Bandit Quest Giver",  -- Adjust NPC name as necessary
    targetEnemy = "Bandit",           -- Adjust enemy name as necessary
    weaponSlot = 1                    -- Weapon slot to equip (for melee, this might not be needed)
}

-- Equip Melle Combat
local function equipMelee()
    -- In Blox Fruits, you don't necessarily need to equip Melee, it's usually the default combat mode
    -- However, if you need to ensure you're using Melee, you can check and equip any item like a sword.
    -- But if you're just using Melee combat, no tool equipping might be necessary. Let's assume we just use the default combat.
    
    -- Ensure that the player is using the correct combat mode (Melee)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Melle combat is usually automatically equipped, you don't need to manually equip anything for default Melee combat.
        -- So this part is optional, depending on how your game or Blox Fruits combat system works.
    else
        warn("Humanoid not found, cannot equip melee.")
    end
end

-- Get Quest from NPC (same as before)
local function getQuest()
    local questNPC = workspace:FindFirstChild(getgenv().autoKillEnemies.questNPC, true)
    if questNPC then
        player.Character.HumanoidRootPart.CFrame = questNPC.HumanoidRootPart.CFrame
        wait(0.5)
        local prompt = questNPC:FindFirstChild("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt, 0)
        else
            warn("No ProximityPrompt found on NPC.")
        end
    end
end

-- Attack Enemy Function (Melee Combat Version)
local function attackEnemy(enemy)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and enemy and enemy:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
        wait(0.1)
        -- Simulate a Melee Attack by clicking
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
    else
        warn("Enemy does not have a HumanoidRootPart.")
    end
end

-- Find Target Enemy
local function findEnemy()
    for _, enemy in ipairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy.Name == getgenv().autoKillEnemies.targetEnemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            return enemy
        end
    end
end

-- Auto Kill Function
local function autoKill()
    while getgenv().autoKillEnemies.enabled do
        getQuest()
        equipMelee()  -- Equip melee combat (if necessary)
        local enemy = findEnemy()
        if enemy then
            attackEnemy(enemy)
        end
        wait(0.1)  -- Add a small delay to avoid high CPU usage
    end
end

-- Start Auto Kill when enabled (you can toggle it via your UI)
if getgenv().autoKillEnemies.enabled then
    autoKill()
end
