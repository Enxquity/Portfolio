local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Cutscenes = Knit.CreateController { 
    Name = "Cutscenes"; 
    Controllers = {
        ["Camera"] = "None";
        ["UI"] = "None";
        ["TaskScheduler"] = "None";
        ["Player"] = "None";
    };
}

--// Cutscene helper functions
function Cutscenes:GoTo(Point: CFrame)
    local Camera = self.Controllers["Camera"]

    Camera:SetType("Scriptable");
    Camera:SetCFrame(Point)
end

function Cutscenes:TransitionTo(Point: CFrame, Info: TweenInfo): table
    local Camera = self.Controllers["Camera"]
    local CachedCF = Camera:GetCFrame()

    local Transition = TweenService:Create(
        Camera.Camera,
        Info or TweenInfo.new(2),
        {
            CFrame = Point
        }
    )
    Transition:Play()

    return {
        Await = function(self, Offset)
            Transition.Completed:Wait()
            task.wait(Offset or 0)
            return {
                Reverse = function(self)
                    return Cutscenes:TransitionTo(CachedCF)
                end
            }
        end;
    }
end

function Cutscenes:RunAnimation(Frames: Folder)
    for Frame = 0, #Frames:GetChildren() do
        local IndexedFrame = Frames:FindFirstChild(Frame)
        if IndexedFrame then
            self:TransitionTo(
                IndexedFrame.Value,
                TweenInfo.new(
                    1/60
                )
            ):Await()
        end
    end
end

function Cutscenes:GetCamera()
    return self.Controllers["Camera"].Camera
end

function Cutscenes:RunScene(SceneName)
    require(script:FindFirstChild(SceneName)).Run(
        self
    )
end

function Cutscenes:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
end


function Cutscenes:KnitInit()
    
end


return Cutscenes
