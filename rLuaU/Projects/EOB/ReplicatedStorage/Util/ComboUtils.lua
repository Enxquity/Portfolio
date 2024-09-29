local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Combo = Knit.CreateController{
    Name = "Combo";
    Controllers = {
        
    };
}

type Combo = {
    CurrentCombo: number;
    Max: number;
    Timeout: number;
}

function Combo:NewCombo(Max, Timeout)
    local Class = {
        CurrentCombo = 1;
        Max = Max;
        Timeout = Timeout or 1;

        LastIncreased = tick();
    }

    function Class.Get(self)
        if tick() - self.LastIncreased >= self.Timeout then
            self.CurrentCombo = 1
        end
        return self.CurrentCombo
    end

    function Class.Next(self)
        self.CurrentCombo = (self.CurrentCombo % self.Max) + 1
        self.LastIncreased = tick()
    end

    return Class
end

function Combo:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
end


function Combo:KnitInit()
    
end


return Combo
