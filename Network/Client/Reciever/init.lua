local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Reciever = Knit.CreateController{
    Name = "Reciever";
    Controllers = {
        
    };
}

type Event = {
    Dependencies: {
        string
    },
    Run: (Dependencies: {[string]: {}}) -> ()
}

function Reciever:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    self.Sender = Knit.GetService("Sender")

    self.Sender.Packet:Connect(function(EventName, ...)
        local Event: Event = require(
            script:FindFirstChild(EventName)
        )

        local LoadedDependencies: {[string]: {}} = {}
        for _, Dependency in Event.Dependencies do
            LoadedDependencies[Dependency] = Knit.GetController(Dependency)
        end

        return Event.Run(
            LoadedDependencies,
            ...
        )
    end)
end


function Reciever:KnitInit()
    
end


return Reciever
