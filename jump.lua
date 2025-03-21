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
-- Get Quest from NPC and accept it with options
-- Get Quest from NPC and accept it with options
local function getQuest()
    local questNPC = workspace:FindFirstChild(getgenv().autoKillEnemies.questNPC, true)
    
    if questNPC then
        print("Found quest NPC: " .. getgenv().autoKillEnemies.questNPC)  -- Debugging output
        -- Teleport player to NPC
        player.Character.HumanoidRootPart.CFrame = questNPC.HumanoidRootPart.CFrame
        wait(1)  -- Give some time for teleporting to the NPC

        -- First ProximityPrompt: Interact with the NPC
        local prompt1 = questNPC:FindFirstChild("ProximityPrompt")
        if prompt1 then
            print("Firing the first ProximityPrompt (Interact with NPC).")
            fireproximityprompt(prompt1, 0)  -- Interact with the NPC
            wait(2)  -- Wait for interaction to complete
        else
            warn("No ProximityPrompt found on NPC for initial interaction.")
            return
        end

        -- Ensure the NPC interaction has been processed
        wait(2)

        -- Second ProximityPrompt: Select the "Bandits" quest option
        local option1 = workspace:FindFirstChild("Option1")  -- Adjust to the actual path of "Bandits" option
        if option1 then
            local prompt2 = option1:FindFirstChild("ProximityPrompt")
            if prompt2 then
                print("Firing the second ProximityPrompt (Select 'Bandits' quest option).")
                fireproximityprompt(prompt2, 0)  -- Select the Bandits quest option
                wait(2)  -- Wait to ensure the quest is selected
            else
                warn("No ProximityPrompt found for 'Bandits' option.")
                return
            end
        else
            warn("Option 1 'Bandits' not found.")
            return
        end

        -- Ensure the quest option has been selected
        wait(1)

        -- Third ProximityPrompt: Confirm the quest
        local confirmButton = workspace:FindFirstChild("ConfirmButton")  -- Adjust to the actual path of Confirm button
        if confirmButton then
            local prompt3 = confirmButton:FindFirstChild("ProximityPrompt")
            if prompt3 then
                print("Firing the third ProximityPrompt (Confirm the quest).")
                fireproximityprompt(prompt3, 0)  -- Confirm the quest
                getgenv().autoKillEnemies.questAccepted = true  -- Mark quest as accepted
                print("Quest accepted!")  -- Debugging output
                return  -- Exit the function once the quest is accepted
            else
                warn("No ProximityPrompt found for Confirm button.")
                return
            end
        else
            warn("Confirm button not found.")
            return
        end
    else
        warn("Quest NPC not found: " .. getgenv().autoKillEnemies.questNPC)
    end
end

        
        -- Third ProximityPrompt (Confirm the quest)
        local confirmButton = workspace:FindFirstChild("ConfirmButton")  -- Replace with actual path to the confirm button
        if confirmButton then
            local prompt3 = confirmButton:FindFirstChild("ProximityPrompt")
            if prompt3 then
                fireproximityprompt(prompt3, 0)  -- Confirm the quest
                getgenv().autoKillEnemies.questAccepted = true  -- Mark quest as accepted
                print("Quest accepted!")  -- Debugging output
            else
                warn("No ProximityPrompt found for Confirm button.")
            end
        else
            warn("Confirm button not found.")
            return
        end
    else
        warn("Quest NPC not found: " .. getgenv().autoKillEnemies.questNPC)
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
