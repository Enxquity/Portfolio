local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Furnaces = Knit.CreateService {
    Name = "Furnaces",
    Client = {},
}

function Furnaces:GetTycoon(Furnace: Instance): Instance
    local F: Instance = Furnace
    repeat 
        F = F.Parent 
    until F.Parent == workspace.Tycoons
    return F
end

function Furnaces:GetTycoonOwner(Furnace: Instance): Player | nil
    local Tycoon = self:GetTycoon(Furnace)
    if Tycoon then
        local PlayerName: string = Tycoon:GetAttribute("Owner")
        local Player: Player = Players:FindFirstChild(PlayerName)
        if Player then
            return Player
        end
    end
    return nil
end

function Furnaces:KnitStart()
    
end

function Furnaces:KnitInit()
    while task.wait(0.5) do
        for _, Furnace: Instance in pairs(CollectionService:GetTagged("Furnace")) do
            if Furnace.Transparency == 1 then continue end
            local Multiplier: number = Furnace:GetAttribute("Multiplier")

            for _, Ore in pairs(Furnace:GetTouchingParts()) do
                if Ore.Parent == workspace.Ores then
                    TweenService:Create(Ore, TweenInfo.new(1), {Color = Color3.new(1, 0, 0), Transparency = 1}):Play()

                    local Tycoon: Instance = self:GetTycoon(Furnace)
                    Tycoon:SetAttribute("Money", Tycoon:GetAttribute("Money") + Ore:GetAttribute("Value") * Multiplier)
                    Ore.Parent = workspace.Debris
                    Ore.CanCollide = false
                end
            end
        end
    end
end


return Furnaces
