local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local BoatTween = require(ReplicatedStorage.Packages.BoatTween)

local Boundary = Knit.CreateController{
    Name = "Boundary";
    Controllers = {
        ["External"] = "None";
        ["Player"] = "None";
        ["Loading"] = "None";
        ["UI"] = "None";
        ["Sound"] = "None";
    };
    Boundaries = {

    };
    CurrentBoundary = "None";
    Enabled = true;
}

function Boundary:Disable()
    self.Enabled = false
end

function Boundary:Enable()
    self.Enabled = true
end

function Boundary:PromptAreaNotification(Area)
    local Interface = self.Controllers.UI:GetInterface("Notification")

    Interface.Area.Label.UIGradient.Transparency = NumberSequence.new(1)
    Interface.Area.Label.Text = Area
    Interface.Area.Position -= UDim2.fromScale(0, 0.1)
    Interface.Area.ImageTransparency = 1

    local TweenSettings = {
        Time = 0.75;
        EasingStyle = "Quint";
        EasingDirection = "Out";

        Reverses = false;
        DelayTime = 0;
        RepeatCount = 0;

        StepType = "RenderStepped";

        Goal = {}
    }

    TweenSettings.Goal = {
        Position = Interface.Area.Position + UDim2.fromScale(0, 0.1);
        ImageTransparency = 0;
    }

    local DropTween = BoatTween:Create(Interface.Area, TweenSettings)
    DropTween:Play()
    DropTween.Completed:Wait()


    TweenSettings.Goal = {
        Transparency = NumberSequence.new(0)
    }
    local Tween = BoatTween:Create(Interface.Area.Label.UIGradient, TweenSettings)
    Tween:Play()
    Tween.Completed:Wait()

    task.wait(4)

    --// In
    TweenSettings.EasingDirection = "In"
    TweenSettings.Goal = {
        Transparency = NumberSequence.new(1)
    }

    local Inverse = BoatTween:Create(Interface.Area.Label.UIGradient, TweenSettings)
    Inverse:Play()
    Inverse.Completed:Wait()

    TweenSettings.Goal = {
        Position = Interface.Area.Position - UDim2.fromScale(0, 0.1);
        ImageTransparency = 1;
    }
    DropTween = BoatTween:Create(Interface.Area, TweenSettings):Play()
    task.wait(1)

    Interface.Area.Position += UDim2.fromScale(0, 0.1)
end

function Boundary:CreateBoundary(P1, P2)
    local Pos1 = P1.Position
    local Pos2 = P2.Position

    local BoundarySize = Vector3.new(
        math.abs(Pos1.X - Pos2.X),
        1000,
        math.abs(Pos1.Z - Pos2.Z)
    )
    local Center = (Pos1 + Pos2) / 2

    local Boundary = self.Instancer:CreateInstance(
        "Part", 
        P1.Parent or P2.Parent,
        {
            Size = BoundarySize;
            CFrame = CFrame.new(Center);
            Anchored = true;
            CanCollide = false;
            Transparency = 0.8;
            Name = P1.Parent.Name or P2.Parent.Name;
        }
    )

    return Boundary
end

function Boundary:Enter(Area)
    self.Controllers.Sound:PlaySoundTrack(
        Area.Name
    )
    self:PromptAreaNotification(
        Area.Name
    )
end

function Boundary:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    --// Make instancer
    self.Instancer = self.Controllers.External:Load("Instancer").new()

    --// Make the real boundaries
    for _, Boundary in self.Controllers.Loading:GetChildrenAsync(workspace:WaitForChild("Boundaries")) do
        local P1, P2 = Boundary:FindFirstChild("P1"), Boundary:FindFirstChild("P2")

        if P1 and P2 then
            table.insert(
                self.Boundaries, 
                self:CreateBoundary(P1, P2)
            )
        end
    end

    --// Check every second whether the player overlaps within boudnaries
    while task.wait(1) do
        for _, Boundary in self.Boundaries do
            local Character = self.Controllers.Player:GetCharacter()
            if Boundary:OverlapsWith(Character.PrimaryPart) and self.CurrentBoundary ~= Boundary.Name then
                self.CurrentBoundary = Boundary.Name
                print(`Character overlaps with {Boundary:GetFullName()}`)
                self:Enter(Boundary)
                break
            end
        end
    end
end


function Boundary:KnitInit()
    
end


return Boundary
