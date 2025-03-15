local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Auto Kill Settings
getgenv().autoKillEnemies = {
    enabled = false,
    questNPC = "Bandit Quest Giver",  -- Adjust NPC name as necessary
    targetEnemy = "Bandit",           -- Adjust enemy name as necessary
}

-- Equip Combat from Hotbar Slot 1
local function equipCombat()
    local backpack = player.Backpack
    local combatTool = backpack:FindFirstChild("Combat")  -- Slot 1 tool should be called "Combat"
    
    if combatTool then
        -- Equip Combat by activating it directly in the hotbar
        player.Character.Humanoid:EquipTool(combatTool)
    else
        warn("Combat tool not found in hotbar.")
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
        -- Simulate a Melee Attack using the Combat tool (Main melee)
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())  -- Simulating the mouse click (attack)
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

        equipCombat()  -- Equip the Combat tool from slot 1

        local enemy = findClosestEnemy()  -- Find the closest enemy
        if enemy then
            attackEnemy(enemy)  -- Teleport above and attack the enemy
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
