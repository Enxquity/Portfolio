local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Player = game:GetService("Players").LocalPlayer;

local Knit = require(ReplicatedStorage.Packages.Knit)
local Keybinds = require(ReplicatedStorage.Source.Keybinds)
local Key = require(ReplicatedStorage.ExternalModules.Key)
Knit.AddControllersDeep(ReplicatedStorage.Source.Controllers)

Knit.Start():andThen(function()
    --// Controllers
    local CameraController = Knit.GetController("Camera")
    local UIController = Knit.GetController("UI")
    local Customisation = Knit.GetController("Customisation")
    local Movement = Knit.GetController("Movement")
    local LoadingScreen = Knit.GetController("LoadingScreen")
    local TeleportClient = Knit.GetController("TeleportClient")
    local Inventory = Knit.GetController("Inventory")

    local CharacterInfo = Knit.GetService("CharacterInfo")
    local MovesManager = Knit.GetService("MovesManager")

    TeleportClient:Init()

    repeat task.wait() until Player.Character
    RunService.RenderStepped:Connect(function(dt)
        CameraController:Render(dt)
    end)
    Inventory:Init()

    --CharacterInfo:LoadData():await()
    --LoadingScreen:Init()

    Movement:InitAnims()
    Key:AddKey({Enum.KeyCode.LeftShift}, function()
        Movement:Dash()
    end)
    Key:AddKey({Enum.KeyCode.LeftControl}, function()
        Movement:Sprint()
    end)
    Key:AddKey({Enum.KeyCode.F}, function()
        if Movement.JumpingDelay == true then return end
        local Character = Player.Character
        if Character then
            MovesManager:BlockStart()
        end
    end, function()
        local Character = Player.Character
        if Character then
            MovesManager:BlockStop()
        end
    end)
    Key:AddKey({Enum.KeyCode.G}, function()
        CameraController.Lock = not CameraController.Lock
    end)
    Key:AddKey({Enum.KeyCode.T}, function()
        Movement:Leap(Enum.KeyCode.T)
    end)
    Key:AddKey({Enum.KeyCode.RightShift}, function()
        CameraController.CameraToggled = not CameraController.CameraToggled 
    end)
end):catch(warn)
