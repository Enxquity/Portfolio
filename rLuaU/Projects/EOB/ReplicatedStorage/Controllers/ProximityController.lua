local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Proximity = Knit.CreateController{
    Name = "Proximity";
    Controllers = {
        
    };
    Prompts = {};
}

function Proximity:GetPrompt(Name)
    for _, Prompt in CollectionService:GetTagged("Prompt") do
        if Prompt.Name == Name then
            return Prompt
        end
    end
    return self.Prompts[Name]
end

function Proximity:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
end


function Proximity:KnitInit()
    
end


return Proximity
