local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HealthService = Knit.CreateService {
    Name = "HealthService",
    Client = {
        Health = Knit.CreateProperty({});
    },
}

function HealthService:CreateHealthObject(Player, HealthName, HealthValue)
    local Current = self.Client.Health:GetFor(Player)
    Current[HealthName] = HealthValue

    self.Client.Health:SetFor(
        Player,
        Current
    )
end

function HealthService:DeleteHealthObject(Player, HealthName)
    local Current = self.Client.Health:GetFor(Player)
    Current[HealthName] = nil

    self.Client.Health:SetFor(
        Player,
        Current
    )
end

function HealthService:GetHealth(Player, HealthName)
    return self.Client.Health:GetFor(
        Player
    )[HealthName]
end

function HealthService:TakeDamage(Player, HealthName, Damage)
    local Current = self.Client.Health:GetFor(Player)

    if Current[HealthName] ~= nil then
        Current[HealthName] = math.max(
            Current[HealthName] - Damage,
            0
        )

        self.Client.Health:SetFor(Player, Current)
        return Current[HealthName]
    end
    
    return nil
end

function HealthService:KnitStart()
    
end


function HealthService:KnitInit()
    
end


return HealthService
