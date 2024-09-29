local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StatesController = Knit.CreateController{
    Name = "StatesController";
    Controllers = {
        ["CharacterStates"] = "None";
        ["Player"] = "None";
    };
}

function StatesController:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    self.Controllers.CharacterStates:OnState("Stun", {
        Update = function(IsEnabled)
            local Char = self.Controllers.Player:GetCharacter(false)
            if Char then
                local Humanoid = Char:FindFirstChild("Humanoid")

                if Humanoid then
                    Humanoid.WalkSpeed = (IsEnabled and 4 or 8)
                end
            end
        end
    })
end

function StatesController:KnitInit()
    
end


return StatesController
