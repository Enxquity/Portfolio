local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Object = Knit.CreateController{
    Name = "Object";
    Controllers = {
        ["Player"] = "None";
        ["UI"] = "None";
        ["TaskScheduler"] = "None";
        ["Boundary"] = "None";
    };
}

function Object:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    local Scheduler = self.Controllers.TaskScheduler:New()
    local Fader = self.Controllers.UI:NewFader(1, {
        Object = ReplicatedStorage.Assets.UI.CustomFade,
        Init = function(Object)
            self.Controllers.UI:AddSpriteMap(
                Object.Holder.Bar,
                {
                    "rbxassetid://18684689934",
                    "rbxassetid://18686157507",
                    "rbxassetid://18686159623",
                    "rbxassetid://18686160949",
                    "rbxassetid://18686162953",
                    "rbxassetid://18686164691",
                    "rbxassetid://18686166386",
                    "rbxassetid://18686168545",
                    "rbxassetid://18686170337"
                },
                3
            )
        end
    })

    task.wait(3)

    --// Door Objects
    for _, Object in CollectionService:GetTagged("Door") do
        local Point = Object:FindFirstChildWhichIsA("ObjectValue")
        local Prompt = Object:FindFirstChildWhichIsA("ProximityPrompt")

        Prompt.Triggered:Connect(function()
            Fader:Out():Await()
            self.Controllers.Boundary:Disable()
            self.Controllers.Player:PivotTo(Point.Value.CFrame)

            Scheduler:ScheduleFor(4, function()
                Fader:In()
                self.Controllers.Boundary:Enable()
            end)
        end)
    end
end


function Object:KnitInit()
    
end


return Object
