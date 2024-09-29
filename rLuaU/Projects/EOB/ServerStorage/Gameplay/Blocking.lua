local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Blocking = Knit.CreateService {
    Name = "Blocking",
    Client = {},
    Services = {
        ["HealthService"] = "None";
    };
}

function Blocking.Client:Start(Player)
    local Services = self.Server.Services
    Services.HealthService:CreateHealthObject(Player, "Block", 2)
end

function Blocking.Client:Stop(Player)
    local Services = self.Server.Services
    Services.HealthService:DeleteHealthObject(Player, "Block")
end

function Blocking:KnitStart()
    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end
end


function Blocking:KnitInit()
    
end


return Blocking
