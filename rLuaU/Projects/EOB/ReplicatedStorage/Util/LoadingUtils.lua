local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LoadingUtils = Knit.CreateController{
    Name = "Loading";
    Controllers = {
        
    };
}

function LoadingUtils:GetChildrenAsync(Inst)
    local Elapsed = 0
    local Event = Inst.ChildAdded:Connect(function()
        Elapsed = 0
    end)

    while Elapsed < 2 do
        task.wait(0.1)
        Elapsed += 0.1
    end
    Event:Disconnect()

    return Inst:GetChildren()
end

function LoadingUtils:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
end


function LoadingUtils:KnitInit()
    
end


return LoadingUtils
