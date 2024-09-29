local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Player = Players.LocalPlayer
local Knit = require(ReplicatedStorage.Packages.Knit)

local Clash = {
    Services = {};
    Instancer = "None";
    Animator = "None";

    Animations = {

    };
}

function Clash.__init()
    Clash.Services["Instancer"] = Knit.GetController("External"):Load("Instancer")
    Clash.Instancer = Clash.Services["Instancer"].new()
end

function Clash:Run(Position)
    local VFX = ReplicatedStorage:FindFirstChild("VFX").Sword.Clash

    local ClashPart = Clash.Instancer:CreateInstance("Part", workspace.Debris, {
        Anchored = true;
        CanCollide = false;
        Size = Vector3.one;
        Transparency = 0.9;

        Position = Position; 
    })
    
    local ClonedVFX = ClashPart:QuickClone(VFX)
    for _, Visual in ClonedVFX do
        Visual:Emit(150)
    end
    ClashPart:AddDebris(1)

    SoundService.SFX.Clash:Play()
end

return Clash