local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Configurations = ServerStorage.Source.Configs

local Config = require(Configurations.StatesConfiguation)

local Loader = {}

function Loader:Init()
    Knit.OnStart():andThen(function()
        local CharacterStates = Knit.GetService("CharacterStates")
        for State, Effectors in Config do
            CharacterStates:AddStateEffectors(
                State,
                Effectors
            )
        end
    end)
    return Loader
end

return Loader:Init()