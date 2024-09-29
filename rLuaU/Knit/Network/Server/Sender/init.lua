local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Sender = Knit.CreateService {
    Name = "Sender",
    Client = {
        Packet = Knit.CreateSignal();
    },
}

function Sender:SendEvent(Player, EventName, ...)
    if typeof(Player) ~= "Instance" or not Player:IsA("Player") then return end

    return self.Client.Packet:Fire(
        Player,
        EventName,
        ...
    )
end

function Sender:KnitStart()
    
end


function Sender:KnitInit()
    
end


return Sender
