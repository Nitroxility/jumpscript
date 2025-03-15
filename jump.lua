local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Auto Kill Settings
getgenv().autoKillEnemies = {
    enabled = false,
    questNPC = "Bandit Quest Giver",  -- Adjust NPC name as necessary
    targetEnemy = "Bandit",           -- Adjust enemy name as necessary
    weaponSlot = 1                    -- Weapon slot to equip
}

-- Equip Weapon Function
local function equipWeapon(slot)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local weapon = backpack:FindFirstChildOfClass("Tool")
        if weapon and weapon.Parent ~= character then
            character.Humanoid:EquipTool(weapon)
        end
    end
end

-- Get Quest from NPC
local function getQuest()
    local questNPC = workspace:FindFirstChild(getgenv().autoKillEnemies.questNPC, true)
    if questNPC then
        player.Character.HumanoidRootPart.CFrame = questNPC.HumanoidRootPart.CFrame
        wait(0.5)
        fireproximityprompt(questNPC:FindFirstChild("ProximityPrompt"), 0)
    end
end

-- Attack Enemy Function
local function attackEnemy(enemy)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and enemy and enemy:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
        wait(0.1)
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
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
        equipWeapon(getgenv().autoKillEnemies.weaponSlot)
        local enemy = findEnemy()
        if enemy then
            attackEnemy(enemy)
        end
        wait(0.1)
    end
end
