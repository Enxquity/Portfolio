local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Camera = Knit.CreateController{
    Name = "Camera";
    Camera = workspace.CurrentCamera;
    UIS = game:GetService("UserInputService");
    Controllers = {
        ["External"] = "None";
        ["Interactions"] = "None";
        ["Player"] = "None";
    };
    Tweens = {
        Fov = {}
    };

    Values = {
        Zoomed = false;
        CameraPositionSpring = "None";
        FinalTargetSpring = "None";

        CameraDepth = 0.7;
        HeightOffset = 2;

        Target = "None";
        AuxTarget = "None";
    };

    CameraXDeg = 0;
    CameraYDeg = 0;
    RotationIndex = 1;
}

function Camera:SetType(Type)
    self.Camera.CameraType = Enum.CameraType[Type];
end

function Camera:SetMouseBehavior(Behavior)
    self.UIS.MouseBehavior = Enum.MouseBehavior[Behavior]
end

function Camera:GetCFrame()
    return self.Camera.CFrame
end

function Camera:SetCFrame(CF)
    self.Camera.CFrame = CF
end

function Camera:SetBounds(Min, Max)
    local Player = Players.LocalPlayer

    Player.CameraMinZoomDistance = Min;
    Player.CameraMaxZoomDistance = Max;
end

function Camera:GetOffset()
    local Humanoid = self:GetHumanoid():await()
    return Humanoid.CameraOffset
end

function Camera:SetOffset(Offset)
    --print(Offset)
    self:GetHumanoid():andThen(function(Humanoid)
        Humanoid.CameraOffset = Offset
        --Humanoid.AutoRotate = false
    end)
end

function Camera:LerpOffset(Offset, LerpPoint)
    self:GetHumanoid():andThen(function(Humanoid)
        Humanoid.CameraOffset:Lerp(Offset, LerpPoint)
    end)
end

function Camera:Lerp(a, b, t)
    return a + (b - a) * t
end

function Camera:SetFov(Fov)
    self.Camera.FieldOfView = Fov;
end

function Camera:LerpFov(Fov, DT)
    self.Camera.FieldOfView = self:Lerp(self.Camera.FieldOfView, Fov, 3*DT)
end

function Camera:TweenFov(Fov)
    for i,v in self.Tweens.Fov do
        v:Cancel()
    end
    self.Tweens.Fov = {}

    table.insert(self.Tweens.Fov, TweenService:Create(self.Camera, TweenInfo.new(0.2), {FieldOfView = Fov}))
    self.Tweens.Fov[1]:Play()

    return {
        ClearOnEnd = function()
            self.Tweens.Fov[1].Completed:Wait()
            self.Tweens.Fov = {}
        end
    }
end

function Camera:TweenCFrame(CF)
    local Tween = TweenService:Create(
        self.Camera,
        TweenInfo.new(1),
        {
            CFrame = CF;
        }
    )
    Tween:Play()
    Tween.Completed:Wait()
end

function Camera:AngleToPart(Part)
    local CameraCFrame = self.Camera.CFrame
    local CameraLookVector = CameraCFrame.LookVector
    local CameraForwardXZ = Vector3.new(CameraLookVector.X, 0, CameraLookVector.Z).Unit

    local PartPosition = Part.Position
    local CameraPosition = self.Camera.CFrame.Position
    local ToPartVector = (PartPosition - CameraPosition)
    local ToPartVectorXZ = Vector3.new(ToPartVector.X, 0, ToPartVector.Z).Unit

    local DotProduct = CameraForwardXZ:Dot(ToPartVectorXZ)
    local CrossProduct = CameraForwardXZ:Cross(ToPartVectorXZ).Y

    local Angle = math.atan2(CrossProduct, DotProduct)
    local AngleInDegrees = math.deg(Angle)

    return AngleInDegrees
end

function Camera:Bobble()
    local T = tick()
    local BobbleX = math.cos(T * 10) * 0.25
    local BobbleY = math.abs(math.sin(T * 10)) * 0.25
    local Bobble = Vector3.new(BobbleX, BobbleY, 0)
    return Bobble
end

function Camera:GetCharacter()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local tbl = {}
    function tbl:andThen(f)
        return f(Character)
    end
    return tbl
end

function Camera:GetSpeed()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local Speed = nil
    if Character and Character:FindFirstChildWhichIsA("Humanoid") then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        Speed = Humanoid.MoveDirection.Magnitude
    end
    local tbl = {}
    function tbl:andThen(f)
        return f(Speed)
    end
    return tbl
end

function Camera:GetWalkSpeed()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    if Character and Character:FindFirstChildWhichIsA("Humanoid") then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        return Humanoid.WalkSpeed
    end
end

function Camera:GetHumanoid()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local Hum = nil 
    if Character and Character:FindFirstChildWhichIsA("Humanoid") then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        Hum = Humanoid
    end
    local tbl = {}
    function tbl:andThen(f)
        return f(Hum)
    end
    function tbl:await()
        return Hum
    end
    return tbl
end

function Camera:SetTarget(Target)
    if not Target then
        self.Values.AuxTarget = "None"
    else
        self.Values.AuxTarget = Target
    end
end

function Camera:DisableZoom()
    Players.LocalPlayer.CameraMaxZoomDistance = 64;
    Players.LocalPlayer.CameraMinZoomDistance = 64;
end

function Camera:EnableZoom()
    Players.LocalPlayer.CameraMaxZoomDistance = 128;
    Players.LocalPlayer.CameraMinZoomDistance = 64;
end

function Camera:Render(dt)
    self:GetCharacter():andThen(function(Char)
        if Players.LocalPlayer.DevCameraOcclusionMode == Enum.DevCameraOcclusionMode.Zoom then
            if self.Controllers.Interactions.InInteraction == true then
                return
            end
            self:SetFov(70)
            self:SetBounds(
                8, 
                8
            )
            self:SetType("Custom")
            self.Camera.CameraSubject = Char.Humanoid
            return 
        end

        local HumanoidRootPart = Char.PrimaryPart

        self:SetFov(20)
        self.Values.Target = (self.Values.AuxTarget == "None" and HumanoidRootPart or self.Values.AuxTarget.PrimaryPart)
        self.Camera.CameraSubject = self.Values.Target

        if self.Values.Zoomed == true then
            self.Values.CameraDepth = 0.4;
        else
            self.Values.CameraDepth = 0.7;
        end

        local CameraPosition = self.Values.Target.Position + Vector3.new(0, self.Values.HeightOffset)
        local Magnitude = (self.Values.Target.Position - self:GetCFrame().Position).Magnitude

        local X, Y = math.cos(self.CameraXDeg), math.sin(self.CameraXDeg)
        
        if self.Values.AuxTarget ~= "None" then
            self:DisableZoom()
            X, Y = 1, 1
        else
            self:EnableZoom()
        end

        self.Values.CameraPositionSpring.Target = CameraPosition + Vector3.new(
            Magnitude * self.Values.CameraDepth * X,
            math.clamp((Magnitude*2) ^ 2 / 360 - 10, 35, 150) - self.CameraYDeg,
            Magnitude * self.Values.CameraDepth * Y
        )
        self.Values.FinalTargetSpring.Target = CameraPosition

        self:SetCFrame(
            CFrame.lookAt(
                self.Values.CameraPositionSpring.Position,
                self.Values.FinalTargetSpring.Position
            )
        )
    end)
end 

function Camera:KnitStart()
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    local Spring = self.Controllers["External"]:Load("Spring")
    self.Values.CameraPositionSpring = Spring.new(Vector3.new(0,0,0))
    self.Values.CameraPositionSpring.Target = self:GetCFrame().Position
    self.Values.CameraPositionSpring.Position = Vector3.new(0,0,0)
    self.Values.CameraPositionSpring.Velocity = Vector3.new(0,0,0)
    self.Values.CameraPositionSpring.Speed = 10

    self.Values.FinalTargetSpring = Spring.new(Vector3.new(0,0,0))
    self.Values.FinalTargetSpring.Target = Vector3.new(0,0,0)
    self.Values.FinalTargetSpring.Position = Vector3.new(0,0,0)
    self.Values.FinalTargetSpring.Velocity = Vector3.new(0,0,0)
    self.Values.FinalTargetSpring.Speed = 20
    self.Values.FinalTargetSpring.Damper = 0.8

    self.UIS.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Diff = Input.Delta.X * 0.001
            local DiffY = Input.Delta.Y * 0.1

            self.CameraYDeg = math.clamp(self.CameraYDeg - DiffY, -30, 30)
            self.CameraXDeg += Diff
        end
    end)

    self.UIS.InputEnded:Connect(function(Input, IsTyping)
        if IsTyping then return end

        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.CameraYDeg = 0
        end
    end)

    warn("Loaded camera spring.")
end 

function Camera:KnitInit()
    print("[Knit] Camera controller initialised!")
end

return Camera