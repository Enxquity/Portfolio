local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Movement = Knit.CreateController { 
    Name = "Movement";
    Controllers = {
        ["Player"] = "None";
        ["Mouse"] = "None";
        ["External"] = "None";
    };
    Instancer = "None";
    Services = {};

    Enabled = true;
}

function Movement:Enable()
    self.Enabled = true
end

function Movement:Disable()
    self.Enabled = false
end

function Movement:PivotAt(Model)
    local Character = self.Controllers.Player:GetCharacter()

    local ModelPosition = Model.PrimaryPart.Position 
    local CharacterPos = Character:GetPivot().Position
    local X, Y, Z = CFrame.new(CharacterPos,  CharacterPos + (ModelPosition - CharacterPos).Unit):ToOrientation()
    Character:PivotTo(Character:GetPivot():Lerp(CFrame.new(CharacterPos) * CFrame.Angles(0, Y, 0), 1))
    Character.Humanoid.AutoRotate = false
end

function Movement:Render(DeltaTime)
    local Character = self.Controllers.Player:GetCharacter()

    --// R6 Primary part default is head
    Character.PrimaryPart = Character:FindFirstChild("HumanoidRootPart")

    --// Character rotator
    local Mouse3D = self.Controllers.Mouse:GetPositionIn3DSpace()
    local CharacterPos = Character:GetPivot().Position
    local X, Y, Z = CFrame.new(CharacterPos,  CharacterPos + (Mouse3D - CharacterPos).Unit):ToOrientation()
    Character:PivotTo(Character:GetPivot():Lerp(CFrame.new(CharacterPos) * CFrame.Angles(0, Y, 0), 0.1))
    Character.Humanoid.AutoRotate = false

    --// Custom Movement
    local WalkSpeed = Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed * 2
    local W, A, S, D = UserInputService:IsKeyDown(Enum.KeyCode.W), UserInputService:IsKeyDown(Enum.KeyCode.A), UserInputService:IsKeyDown(Enum.KeyCode.S), UserInputService:IsKeyDown(Enum.KeyCode.D)

    local Look = Character.PrimaryPart.CFrame.LookVector
    local Right = Character.PrimaryPart.CFrame.RightVector

        --// Construct the velocity vector
    local Construct = (Vector3.zero
    + (W and Look or Vector3.zero) 
    + (A and -Right or Vector3.zero) 
    + (S and -Look or Vector3.zero)
    + (D and Right or Vector3.zero)
   )

   Construct = (
    Construct == Vector3.zero
                    and Vector3.zero + Vector3.new(0, Character.PrimaryPart.Velocity.Y, 0)
    or Construct.Unit * WalkSpeed + Vector3.new(0, Character.PrimaryPart.Velocity.Y, 0)
   )

    Character.PrimaryPart.Velocity = Construct
end

function Movement:KnitStart()
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    self.Instancer = self.Controllers.External:Load("Instancer").new() 

    --// Bind up movement render
    RunService.RenderStepped:Connect(function(Delta)
        --// Check whether the controls are enabled
        if self.Enabled == false then
            return
        end

        self:Render(Delta)
    end)
end


function Movement:KnitInit()
    
end


return Movement
