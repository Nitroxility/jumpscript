local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Auto Kill Settings
getgenv().autoKillEnemies = {
    enabled = false,
    questNPC = "Bandit Quest Giver",  -- Adjust NPC name as necessary
    targetEnemy = "Bandit",           -- Adjust enemy name as necessary
    questAccepted = false,            -- Track if the quest is accepted
    questComplete = false,            -- Track if the quest is complete
}

-- Equip Combat from Hotbar Slot 1
local function equipCombat()
    local backpack = player.Backpack
    local combatTool = backpack:FindFirstChild("Combat")  -- Slot 1 tool should be called "Combat"
    
    if combatTool then
        -- Equip Combat by activating it directly in the hotbar
        player.Character.Humanoid:EquipTool(combatTool)
        print("Equipped Combat tool!")  -- Debugging output
    else
        warn("Combat tool not found in hotbar.")
    end
end

-- Get Quest from NPC and accept it
local function getQuest()
    local questNPC = workspace:FindFirstChild(getgenv().autoKillEnemies.questNPC, true)
    if questNPC then
        print("Found quest NPC: " .. getgenv().autoKillEnemies.questNPC)  -- Debugging output
        player.Character.HumanoidRootPart.CFrame = questNPC.HumanoidRootPart.CFrame
        wait(0.5)
        local prompt = questNPC:FindFirstChild("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt, 0)
            getgenv().autoKillEnemies.questAccepted = true  -- Mark quest as accepted
            print("Quest accepted!")  -- Debugging output
        else
            warn("No ProximityPrompt found on NPC.")
        end
    else
        warn("Quest NPC not found: " .. getgenv().autoKillEnemies.questNPC)
    end
end

-- Check if the Quest is Complete
local function checkQuestCompletion()
    -- Example condition: The quest is complete when a specific enemy is defeated
    -- You can adjust this depending on how the quest completion is determined in the game
    local enemy = findClosestEnemy()
    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health <= 0 then
        getgenv().autoKillEnemies.questComplete = true
        print("Quest complete!")  -- Debugging output
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
        print("Attacked enemy: " .. enemy.Name)  -- Debugging output
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
    
    if closestEnemy then
        print("Found closest enemy: " .. closestEnemy.Name)  -- Debugging output
    else
        print("No valid enemy found.")  -- Debugging output
    end
    
    return closestEnemy
end

-- Auto Kill Function
local function autoKill()
    while getgenv().autoKillEnemies.enabled do
        -- If quest is not accepted, accept it
        if not getgenv().autoKillEnemies.questAccepted then
            print("Attempting to get quest...")  -- Debugging output
            getQuest()  -- Get the quest from the NPC first
        end

        -- If quest is accepted and not yet complete, keep killing enemies
        if getgenv().autoKillEnemies.questAccepted and not getgenv().autoKillEnemies.questComplete then
            print("Equipping combat...")  -- Debugging output
            equipCombat()  -- Equip the Combat tool from slot 1

            local enemy = findClosestEnemy()  -- Find the closest enemy
            if enemy then
                print("Found an enemy, attempting to attack...")  -- Debugging output
                attackEnemy(enemy)  -- Teleport above and attack the enemy
            else
                print("No enemies found nearby.")  -- Debugging output
            end
            wait(0.1)  -- Add a small delay to avoid high CPU usage
        end
        
        -- If quest is complete, return to NPC to turn it in
        if getgenv().autoKillEnemies.questComplete then
            print("Returning to quest giver to turn in quest...")  -- Debugging output
            getQuest()  -- Teleport back to the quest giver to turn in the quest (you can modify this behavior if needed)
            wait(1)  -- Add a delay before checking again
        end
    end
end

-- Toggle the auto kill function when enabled
if getgenv().autoKillEnemies.enabled then
    autoKill()
end
