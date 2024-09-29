local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Droppers = Knit.CreateService {
    Name = "Droppers",
    Client = {},
}

function Droppers:Drop(Dropper: Instance)
    local Size: Vector3 = Dropper:GetAttribute("Size")
    local Value: number = Dropper:GetAttribute("Value")
    local NewOre: Instance = Instance.new("Part")
    
    NewOre.Size = Size
    NewOre.CollisionGroup = "Ore"
    NewOre.Parent = workspace.Ores
    NewOre.CFrame = CFrame.new(Dropper.Position)

    NewOre:SetAttribute("Value", Value)


    Debris:AddItem(NewOre, 30)
end

function Droppers:KnitStart()
    
end

function Droppers:KnitInit()
    while task.wait(0.5) do
        for _, Dropper in pairs(CollectionService:GetTagged("Dropper")) do
            if Dropper.Transparency == 1 then continue end
            local LastDropped: number = Dropper:GetAttribute("LastDropped")
            local Speed: number = Dropper:GetAttribute("Speed")
            if tick()-LastDropped >= Speed then
                self:Drop(Dropper)
                Dropper:SetAttribute("LastDropped", tick())
            end
        end
    end
end


return Droppers
