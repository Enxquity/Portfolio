local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VFXPacket = Knit.CreateService {
    Name = "VFXPacket",
    Client = {
        SendPacket = Knit.CreateSignal();
    },
}

function VFXPacket.Client:FirePacket(Player, VFXType, ...)
    return self.Server:FirePacket(Player, VFXType, ...)
end

function VFXPacket:FirePacket(Player, VFXType, ...)
    local PlayerList = Players:GetPlayers()
    table.remove(
        PlayerList,
        table.find(PlayerList, Player)
    )

    for _, ReplicationPlayer in PlayerList do
        self.Client.SendPacket:Fire(ReplicationPlayer, VFXType, ...)
    end
end

function VFXPacket:FireAllPacket(VFXType, ...)
    local PlayerList = Players:GetPlayers()

    for _, ReplicationPlayer in PlayerList do
        self.Client.SendPacket:Fire(ReplicationPlayer, VFXType, ...)
    end
end

function VFXPacket:KnitStart()

end


function VFXPacket:KnitInit()
    
end


return VFXPacket
