local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local Cutscene1 = Knit.CreateController{
    Name = "Cutscene1";
}

function Cutscene1:Lerp(a, b, t)
    return a + (b - a) * t
end

function Cutscene1:Init()
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    local Camera = workspace.CurrentCamera

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = workspace.P1.CFrame

    local Start = tick()
    while true do
        if tick()-Start < 9 then
            Camera.CFrame = Camera.CFrame:Lerp(workspace.P2.CFrame, 0.0005)
        else
            game.Lighting.ColorCorrection.Saturation = self:Lerp(game.Lighting.ColorCorrection.Saturation, -1, 0.01)
            ReplicatedStorage.SFX.Ambience.PlaybackSpeed = self:Lerp(ReplicatedStorage.SFX.Ambience.PlaybackSpeed, 0.1, 0.01)
            ReplicatedStorage.SFX.Crash.PlaybackSpeed = self:Lerp(ReplicatedStorage.SFX.Crash.PlaybackSpeed, 0.1, 0.01)
            ReplicatedStorage.SFX.Horn.PlaybackSpeed = self:Lerp(ReplicatedStorage.SFX.Horn.PlaybackSpeed, 0.1, 0.0025)
            Camera.CFrame = Camera.CFrame:Lerp(workspace.P2.CFrame, 0.0001)
            if tick()-Start > 17 then
                ReplicatedStorage.SFX.Ambience:Stop()
                ReplicatedStorage.SFX.Pulse:Play()
                Player.PlayerGui.CutsceneBackground.Enabled = true
                break
            end

        end
        task.wait(0.001)
    end
    
end

return Cutscene1