local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerManager = Knit.CreateService {
    Name = "PlayerManager",
    Client = {},
}

function PlayerManager:KnitStart()
    
end


function PlayerManager:KnitInit()
    Players.PlayerAdded:Connect(function(Player)
        local Leaderstats = Instance.new("Folder")
        local Money = Instance.new("IntValue")

        Leaderstats.Name = "leaderstats"
        Money.Name = "Money"
        Money.Value = 100

        Leaderstats.Parent = Player
        Money.Parent = Leaderstats
    end)
end


return PlayerManager
