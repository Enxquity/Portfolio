local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleportService = Knit.CreateService{
    Name = "TeleportService";
    Client = {};
}

function TeleportService:KnitInit()
    print("[Knit] Teleport service initialised!")
end

return TeleportService

