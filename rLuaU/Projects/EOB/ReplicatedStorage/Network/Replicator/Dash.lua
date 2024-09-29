local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)

local Dash = {
    Services = {};
    Instancer = "None";
    Animator = "None";

    Animations = {

    };
}

function Dash.__init()
    Dash.Services["Instancer"] = Knit.GetController("External"):Load("Instancer")
    Dash.Services["Animator"] = Knit.GetController("External"):Load("Animations")
    Dash.Services["Player"] = Knit.GetController("Player")
    Dash.Services["CharacterStates"] = Knit.GetController("CharacterStates")
    Dash.Instancer = Dash.Services["Instancer"].new()
    Dash.Animator = Dash.Services["Animator"].AnimationClass()
end

function Dash:Run(DashDirections, DashPlayer)
    local VFX = ReplicatedStorage:FindFirstChild("VFX").Dash
    local Character = DashPlayer and DashPlayer.Character or Dash.Services.Player:GetCharacter()

    --// Apply VFX facing opposite to the players Torso LookVector
    local NewPart = Dash.Instancer:CreateInstance("Part", workspace.Debris, {
        --Anchored = true;
        CanCollide = true;
        Size = Vector3.one;

        CFrame = CFrame.lookAlong(Character.PrimaryPart.Position, -Character.PrimaryPart.CFrame.LookVector) + Character.PrimaryPart.CFrame.LookVector * 2
    })
    --NewPart:AddDebris(1)
    NewPart:Attach(Character.PrimaryPart)

    local VFX = NewPart:QuickClone(VFX)
    for _, Visual in VFX do
        Visual:Emit(125)
    end

    if DashPlayer ~= Player then
        NewPart:AddDebris(1)
        return
    end

    self.Services.CharacterStates:AddState("Dash")
    local DashDirection = DashDirections.Backwards == true and "Backwards" or "Forwards"

    --// Apply Impulse
    local NewVelocity = Dash.Instancer:CreateInstance("BodyVelocity", Character.PrimaryPart)
    NewVelocity.MaxForce = Vector3.new(1, 0.02, 1) * 50000
    
    NewPart:RenderOnExistance(function()
            local DashVector = DashDirection == "Backwards" and -Character.PrimaryPart.CFrame.LookVector or Character.PrimaryPart.CFrame.LookVector 
            NewVelocity.Velocity = DashVector
            * 
            (40 * ( (NewPart:Life() + 1) ^ -1 ))
            - Vector3.new(0, workspace.Gravity, 0)
    end).OnDestroy(function()
            NewVelocity:Destroy()
    end)

    --// Play animation
    local Anim = Dash.Animations[DashDirection] 

    if not Anim then
        Dash.Animations["Forwards"], Dash.Animations["Backwards"] = Dash.Animator:CreateAnimation(Character.Humanoid, 18301700787), 
        Dash.Animator:CreateAnimation(Character.Humanoid, 18788870945)
    end

    Dash.Animations[DashDirection]:Play():OnEnd(function()
        NewPart:Destroy()
        self.Services.CharacterStates:RemoveState("Dash")
    end)
    SoundService.SFX.Dash:Play()
    end

return Dash