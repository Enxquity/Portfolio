local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Player = game:GetService("Players").LocalPlayer;

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddControllersDeep(ReplicatedStorage.Source)

Knit.Start():andThen(function()
    --// Controllers
    local CameraController = Knit.GetController("Camera")
    local ReplicateVFX = Knit.GetController("ReplicateVFX")
    local Cutscenes = Knit.GetController("Cutscenes")
    local Compass = Knit.GetController("Compass")
    local Interaction = Knit.GetController("Interactions")
    local Inventory = Knit.GetController("Inventory")
    local States = Knit.GetController("CharacterStates")
    local Cooldown = Knit.GetController("Cooldown")

    --// Loaders
    local ExternalLoader = Knit.GetController("External")

    --// Cooldowns
    local DashCooldown = Cooldown:NewCooldown()
    
    --// External helpers
    local Input = ExternalLoader:Load("Input")

    --// Info holders
    local Keybinds = require(ReplicatedStorage.Source.Keybinds)

    --// Ermmm, just add a marker
    if MarketplaceService:GetProductInfo(game.PlaceId).Name == "Era of Blades: Combat Testing" then
        --// Equip a sword as an example
        --Inventory:Equip("Sword", "Katana")
    else
        Compass:AddMarker(
            "TutorialQuest",
            workspace:WaitForChild("Roomate").PrimaryPart
        )
    
        repeat task.wait() until Player.Character
    
        Cutscenes:RunScene("NewPlayer")
    end

    --// Inputs
    Input:CreateInput({Keybinds.Interact}, function()
        Interaction:Interact()
    end)

    Input:CreateInput({Keybinds.Rotate}, function()
        local RotationIndex = CameraController.RotationIndex
        
        if RotationIndex == 4 then
            CameraController.RotationIndex = 1
        else
            CameraController.RotationIndex += 1
        end
    end)

    Input:CreateInput({Keybinds.Zoom}, function()
        CameraController.Values.Zoomed = not CameraController.Values.Zoomed
    end)
    
    Input:CreateInput({Keybinds.Dash}, function()
        local CooldownState = DashCooldown.Enabled

        if States:IsEffectorActive({"Movement", "All"}) == false and CooldownState == false then
            local DashDirections = {
                Forwards = true,
                Backwards = UserInputService:IsKeyDown(Enum.KeyCode.S)
            }
            ReplicateVFX:SendPacket("Dash", DashDirections, game.Players.LocalPlayer)
            DashCooldown:Set(1)
        end
    end)

    --// Camera
    RunService.RenderStepped:Connect(function(dt)
        CameraController:Render(dt)
    end)
end):catch(warn)
