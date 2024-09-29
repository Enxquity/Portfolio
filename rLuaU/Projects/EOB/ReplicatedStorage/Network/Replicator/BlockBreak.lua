local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)

local BlockBreak = {
    Services = {};
    Instancer = "None";
    Animator = "None";

    Animations = {

    };
}

function BlockBreak.__init()
    BlockBreak.Services["Instancer"] = Knit.GetController("External"):Load("Instancer")
    BlockBreak.Instancer = BlockBreak.Services["Instancer"].new()
end

function BlockBreak:Run(Position)
    local VFX = ReplicatedStorage:FindFirstChild("VFX").Sword.BlockBreak

    local HitPart = BlockBreak.Instancer:CreateInstance("Part", workspace.Debris, {
        Anchored = true;
        CanCollide = false;
        Size = Vector3.one;
        Transparency = 0.7;

        Position = Position; 
    })
    
    local ClonedVFX = HitPart:QuickClone(VFX)
    for _, Visual in ClonedVFX do
        Visual:Emit(1)
    end
    HitPart:AddDebris(1)

    SoundService.SFX.Shatter:Play()
end

return BlockBreak