local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interactions = Knit.CreateController{
     Name = "Interactions";
     Controllers = {
        ["External"] = "None";
        ["Mouse"] = "None";
        ["Camera"] = "None";
        ["VoiceLines"] = "None";
        ["Player"] = "None";
        ["Movement"] = "None";
        ["UI"] = "None";
        ["Quests"] = "None";
     };
     InInteraction = false;
     CachedCF = CFrame.new();
 }

function Interactions:Render(DT)
    local Target = self.Controllers.Mouse:GetMouseTarget()

    local Cache = self.Instancer.Cache
    if Target ~= nil and #Cache >= 0 then
        if Target:FindFirstChild("Interaction") and table.find(Cache, Target.Interaction) then
            return
        end
        self.Instancer:ClearCache()
    end

    if Target ~= nil and CollectionService:HasTag(Target, "Interactable") and self.InInteraction == false then
        local NewHighlight = self.Instancer:CreateInstance(
            ReplicatedStorage.VFX.Interaction,
            Target,
            {}
        )

        for _, Asset in NewHighlight:GetChildren() do
            Asset.Adornee = Target

            if Asset:FindFirstChild("Overlay") then
                Asset.Overlay.Label.Text = Target.Name
            end
        end
    end
end

function Interactions:Interact()
    local Cache = self.Instancer.Cache
    if #Cache > 0 and self.InInteraction == false then
        local Interactor = Cache[1].Parent

        self.Controllers.VoiceLines:Play("WhatsThat")

        if Interactor:GetAttribute("Type") == "Book" then
            self.InInteraction = true

            self.Controllers.Movement:Disable()
            while self.InInteraction == true do
                if self.Controllers.Player:DistanceFrom(Interactor) <= 5 then
                    break
                end

                self.Controllers.Player:MoveTo(
                    Interactor.Position, 
                    true
                )
                task.wait()
            end
            self.Controllers.Player:CancelMoveTo()

            if self.InInteraction == true then
                self.CachedCF = self.Controllers.Camera:GetCFrame()
                self.Controllers.UI:Disable()
                self.Controllers.Camera:SetType("Scriptable")
                self.Controllers.Camera:TweenCFrame(
                    CFrame.new(
                        Interactor.Position + Interactor.CFrame.UpVector * 1,
                        Interactor.Position
                    ) * CFrame.Angles(0, 0, -math.pi/2)
                )
            end
        end
    else
        self.InInteraction = false
        self.Controllers.UI:Enable()
        if self.CachedCF ~= CFrame.new() then
            self.Controllers.Camera:TweenCFrame(self.CachedCF)
        end
        if self.Controllers.Quests.InQuestDialogue == false then
            self.Controllers.Movement:Enable()
        end
        self.Controllers.Camera:SetType("Custom")
        self.CachedCF = CFrame.new()
    end
end

function Interactions:KnitStart()
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    self.Instancer = self.Controllers["External"]:Load("Instancer").new()

    RunService.RenderStepped:Connect(function(DT)
        self:Render(DT)
    end)
end


function Interactions:KnitInit()
    
end


return Interactions
