local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)

local SwordHit = {
    Services = {};
    Instancer = "None";
    Animator = "None";

    Animations = {

    };
}

function SwordHit.__init()
    SwordHit.Services["Instancer"] = Knit.GetController("External"):Load("Instancer")
    SwordHit.Instancer = SwordHit.Services["Instancer"].new()
end

function SwordHit:Run(Position)
    local VFX = ReplicatedStorage:FindFirstChild("VFX").Sword.Blood

    local HitPart = SwordHit.Instancer:CreateInstance("Part", workspace.Debris, {
        Anchored = true;
        CanCollide = false;
        Size = Vector3.one;
        Transparency = 0.7;

        Position = Position; 
    })
    
    local ClonedVFX = HitPart:QuickClone(VFX)
    for _, Visual in ClonedVFX do
        Visual:Emit(150)
    end
    HitPart:AddDebris(1)

    SoundService.SFX.Slice:Play()
end

return SwordHit