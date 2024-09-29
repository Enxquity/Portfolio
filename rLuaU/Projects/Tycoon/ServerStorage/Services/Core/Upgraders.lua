local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Upgraders = Knit.CreateService {
    Name = "Upgraders",
    Client = {},
}


function Upgraders:KnitStart()
    
end


function Upgraders:KnitInit()
    for Index, Upgrader in pairs(CollectionService:GetTagged("Upgrader")) do
        Upgrader:SetAttribute("ID", Index)
        Upgrader.Touched:Connect(function(Ore)
            if Upgrader.Transparency == 1 then return end
            if Ore.Parent == workspace.Ores and not Ore:GetAttributes()[tostring(Index)] then
                local Multiplier: number = Upgrader:GetAttribute("Multiplier")
                local ValueAddition: number = Upgrader:GetAttribute("ValueAddition")
                Ore:SetAttribute("Value", math.round((Ore:GetAttribute("Value") * Multiplier) + ValueAddition))
                Ore:SetAttribute(Index, true)
            end
        end)
    end
end


return Upgraders
