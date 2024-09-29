local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Cooldown = Knit.CreateController{
    Name = "Cooldown";
    Controllers = {
        
    };
}

function Cooldown:NewCooldown()
    local Class = {
        CooldownTime = tick();
    }

    function Class.Append(self, Length)
        if self.CooldownTime < tick() then
            self.CooldownTime = tick()
        end

        self.CooldownTime += Length
    end
    
    function Class.Set(self, Length)
        self.CooldownTime = tick() + Length
    end

    function Class.Get(self)
        return (self.CooldownTime - tick())
    end

    function Class.Enable(self)
        self.CooldownTime = tick() + 2^16
    end

    function Class.Disable(self)
        self.CooldownTime = tick()
    end

    return setmetatable(Class, {
        __index = function(self, Index)
            if Index == "Enabled" then
                return (tick() < self.CooldownTime)
            end

            return rawget(self, Index)
        end
    })
end

function Cooldown:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
end


function Cooldown:KnitInit()
    
end


return Cooldown
