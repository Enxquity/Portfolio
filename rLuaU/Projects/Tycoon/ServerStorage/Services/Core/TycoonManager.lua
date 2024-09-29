--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TycoonManager = Knit.CreateService { 
    Name = "TycoonManager";
    Client = {};
    Services = {
        
    };
}

function TycoonManager:GetService(ServiceName: string): table
    if self.Services[ServiceName] then
        return self.Services[ServiceName]
    else
        local Service: table = Knit.GetService(ServiceName)
        if Service then
            self.Services[ServiceName] = Service;
            return Service
        end
    end
    return {}
end

function TycoonManager:HasTycoon(Player: string): boolean
    for i,v in pairs(CollectionService:GetTagged("Door")) do
        if v.Parent:GetAttribute("Owner") == Player then
            return true
        end
    end
    return false
end

function TycoonManager:Claim(Player: Player, Tycoon: Instance)
    local Buttons = self:GetService("Buttons")
    Tycoon:SetAttribute("Owner", Player.Name)
    Tycoon.Door.PrimaryPart.Transparency = 0.5
    Buttons:LoadButtons(Tycoon)
end

function TycoonManager:KnitStart()
    
end


function TycoonManager:KnitInit()
    for _, Door in pairs(CollectionService:GetTagged("Door")) do
        Door.PrimaryPart.Touched:Connect(function(Hit: Instance)
            local Hum : Instance = Hit.Parent:FindFirstChildWhichIsA("Humanoid")
            if Hum and self:HasTycoon(Hum.Parent.Name) == false then
                self:Claim(Players:GetPlayerFromCharacter(Hum.Parent), Door.Parent)
            end
        end)
    end

    --// Tycoon preload
    for _, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
        for _, Inst in pairs(Tycoon.Buttons:GetDescendants()) do
            if Inst:IsA("BasePart") then
                Inst:SetAttribute("Transparency", Inst.Transparency)
                Inst:SetAttribute("CanCollide", Inst.CanCollide)
                Inst.Transparency = 1
                Inst.CanCollide = false
            end
        end
    end

    --// Money handlers
    while task.wait(0.1) do
        for _, Tycoon in pairs(workspace.Tycoons:GetChildren()) do
            Tycoon.Collector.Display.Money.MoneyFrame.MoneyLabel.Text = "$" .. Tycoon:GetAttribute("Money")

            local Connection = Tycoon.Collector.Collect.Touched:Connect(function() end)
            for _, Object in pairs(Tycoon.Collector.Collect:GetTouchingParts()) do
                local Player: Player = Players:GetPlayerFromCharacter(Object.Parent)
                if Player and Player.Name == Tycoon:GetAttribute("Owner") then
                    Player.leaderstats.Money.Value += Tycoon:GetAttribute("Money")
                    Tycoon:SetAttribute("Money", 0)
                end
            end
            Connection:Disconnect()
        end
    end
end


return TycoonManager
