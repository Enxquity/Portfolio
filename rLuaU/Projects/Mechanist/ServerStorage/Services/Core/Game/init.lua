local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Game = Knit.CreateService {
    Name = "Game",
    Client = {},
}


function Game:KnitStart()
    require(script.Machines).Init()
end


function Game:KnitInit()
    
end


return Game
