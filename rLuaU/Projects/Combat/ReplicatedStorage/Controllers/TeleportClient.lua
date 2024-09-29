local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local Player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Animations = require(ReplicatedStorage.Source.Controllers.Classes.Animations)

local Teleport = Knit.CreateController{
    Name = "TeleportClient";
}

function Teleport:Init()
    local LoadingScreen = game:GetService("TeleportService"):GetArrivingTeleportGui()

    if LoadingScreen then
        LoadingScreen.Parent = Player.PlayerGui
        game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()

        local ContentService = game:GetService("ContentProvider")
        repeat task.wait() until ContentService.RequestQueueSize == 0
        local TweenService = game:GetService("TweenService")

        task.wait(4)

        TweenService:Create(LoadingScreen.Teleport, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LoadingScreen.Teleport.Rotating, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        TweenService:Create(LoadingScreen.Teleport.Dots, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(LoadingScreen.Teleport.Hint, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    end
end

function Teleport:KnitInit()
    print("[Knit] Teleport controller initialised!")
end

return Teleport