local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Auto Kill Settings
getgenv().autoKillEnemies = {
    enabled = false,
    questNPC = "Bandit Quest Giver",  -- Adjust NPC name as necessary
    targetEnemy = "Bandit",           -- Adjust enemy name as necessary
    weaponSlot = 1                    -- This can be used if you have a specific weapon slot, but not needed for Combat
}

-- Equip Combat Tool (Melee)
local function equipCombat()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local combat = backpack:FindFirstChild("Combat")  -- The name of the main combat tool
        if combat then
            -- Equip Combat Tool (this simulates the melee combat)
            player.Character.Humanoid:EquipTool(combat)
        else
            warn("Combat tool not found in Backpack.")
        end
    else
        warn("Backpack not found.")
    end
end

-- Get Quest from NPC
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

-- Teleport to the Enemy and Attack
local function attackEnemy(enemy)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and enemy and enemy:FindFirstChild("HumanoidRootPart") then
        -- Teleport above the enemy
        humanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0)
        wait(0.5)  -- Give it a moment to teleport
        -- Simulate a Melee Attack by clicking
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
    else
        warn("Enemy does not have a HumanoidRootPart.")
    end
end

-- Find the Closest Target Enemy
local function findClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge  -- Set to a large number to ensure we find the closest enemy
    
    -- Iterate through all enemies in the workspace
    for _, enemy in ipairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy.Name == getgenv().autoKillEnemies.targetEnemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local distance = (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                closestEnemy = enemy
                shortestDistance = distance
            end
        end
    end
    
    return closestEnemy
end

-- Auto Kill Function
local function autoKill()
    while getgenv().autoKillEnemies.enabled do
        getQuest()  -- Get the quest from the NPC first
        equipCombat()  -- Equip the Combat tool (melee)

        local enemy = findClosestEnemy()  -- Find the closest enemy
        if enemy then
            attackEnemy(enemy)  -- Attack the enemy
        else
            warn("No enemies found nearby.")
        end
        wait(0.1)  -- Add a small delay to avoid high CPU usage
    end
end

-- Toggle the auto kill function when enabled
if getgenv().autoKillEnemies.enabled then
    autoKill()
end
