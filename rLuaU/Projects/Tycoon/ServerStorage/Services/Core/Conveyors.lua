local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Conveyors = Knit.CreateService {
    Name = "Conveyors",
    Client = {},
}


function Conveyors:KnitStart()
    
end


function Conveyors:KnitInit()
    while task.wait() do
        for _, Conveyor in pairs(CollectionService:GetTagged("Conveyor")) do
            if Conveyor.Transparency == 1 then continue end
            local Speed: number = Conveyor:GetAttribute("Speed")
            Conveyor.Velocity = Conveyor.CFrame.LookVector * Speed
        end
    end
end


return Conveyors
