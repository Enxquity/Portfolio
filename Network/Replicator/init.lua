local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ReplicateVFX = Knit.CreateController { 
    Name = "ReplicateVFX";
    ServerReplicator = "None";

    VFXModules = {};
}

function ReplicateVFX:FirePacket(VFXType, ...)
    self.VFXModules[VFXType]:Run(...)
end

--// This should be called for when trying to insert new packets
function ReplicateVFX:SendPacket(VFXType, ...)
    self:FirePacket(VFXType, ...)
    self.ServerReplicator:FirePacket(VFXType, ...):andThen(function()
        --print("Fired packet for other users.")
    end)
end

function ReplicateVFX:KnitStart()
    for _, Module in script:GetChildren() do
        self.VFXModules[Module.Name] = require(Module)
        self.VFXModules[Module.Name].__init()
    end
    self.ServerReplicator = Knit.GetService("VFXPacket")

    self.ServerReplicator.SendPacket:Connect(function(VFXType, ...)
        self:FirePacket(VFXType, ...)
    end)
end


function ReplicateVFX:KnitInit()
    
end


return ReplicateVFX
