local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ExternalLoader = Knit.CreateController { Name = "External"; Loaded = {}; }

function ExternalLoader:Load(ModuleName)
    return self.Loaded[ModuleName]
end

function ExternalLoader:KnitStart()
end

function ExternalLoader:KnitInit()
    local Iterator = 0
    for _, Module in ReplicatedStorage.Source.External:GetChildren() do
        self.Loaded[Module.Name] = require(Module)
        Iterator += 1
    end

    warn(("Loaded %d external modules."):format(Iterator))
end

return ExternalLoader
