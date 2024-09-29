local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local MovesManagerClient = Knit.CreateController { 
    Name = "MovesManagerClient" 
}

function MovesManagerClient:KnitStart()
    local MovesManagerServer = Knit.GetService("MovesManager")
    MovesManagerServer.Knockback:Connect(function(Attacker, Power, Length, FaceDirection, ExtraSettings)
        local Char = Players.LocalPlayer.Character
        if not Char then return end

        if not Char.PrimaryPart:FindFirstChildWhichIsA("BodyPosition") then
            Char:FindFirstChildWhichIsA("Humanoid").AutoRotate = false

            local BodyPosition = Instance.new("BodyPosition", Char.PrimaryPart)
            BodyPosition.MaxForce = Vector3.new(20000, 0, 20000)
            BodyPosition.D = 50
            BodyPosition.P = 350
            BodyPosition.Position = (Char.PrimaryPart.Position + ExtraSettings.LookDirection * Power)
    
            if FaceDirection and FaceDirection == true then
                --print("Good")
                --Tween:Create(Target.PrimaryPart, TweenInfo.new(0.2), {CFrame = CFrame.new(Target.PrimaryPart.Position, Attacker.PrimaryPart.Position) * CFrame.new(0, 1, 0)}):Play()
                Char.PrimaryPart.CFrame = CFrame.new(Char.PrimaryPart.Position, Attacker.PrimaryPart.Position)
            end
    
            task.delay(Length, function()
                Char:FindFirstChildWhichIsA("Humanoid").AutoRotate = true
                BodyPosition:Destroy()
            end)
        end
    end)
end


function MovesManagerClient:KnitInit()
    
end


return MovesManagerClient
