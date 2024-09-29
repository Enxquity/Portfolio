local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer

local Cursor = Knit.CreateController { 
    Name = "Cursor";
    Util = {
        UI = "None";
        Mouse = "None";
    };
    HoverStates = {};
    HoverStateClicks = {};
    HoverStatesEnabled = true;
}

function Cursor:Enable()
    local Interface = self.Util.UI:WaitForInterface("Cursor")
    Interface.Enabled = true
end

function Cursor:Disable()
    local Interface = self.Util.UI:WaitForInterface("Cursor")
    Interface.Enabled = false
end

function Cursor:GetEnabledState()
    local Interface = self.Util.UI:WaitForInterface("Cursor")
    return Interface.Enabled
end

function Cursor:EnableHover()
    self.HoverStatesEnabled = true
end

function Cursor:DisableHover()
    self.HoverStatesEnabled = false
end

function Cursor:AddHoverState(Icon, Items, OnClick)
    self.HoverStates[Icon] = Items
    
    if OnClick then
        self.HoverStateClicks[Icon] = OnClick
    end
end

function Cursor:KnitStart()
    for UtilName, UtilValue in self.Util do
        self.Util[UtilName] = Knit.GetController(UtilName)
    end

    local Mouse = Player:GetMouse()

    --// Disable mouse cursor
    UserInputService.MouseIconEnabled = false

    --// Bind on render
    RunService.RenderStepped:Connect(function(Delta)
        local Interface = self.Util.UI:WaitForInterface("Cursor")
        Interface.Icon.Position = UDim2.fromOffset(
            Mouse.X,
            Mouse.Y
        )

        --// Implement hover states
        local MouseHover = self.Util.Mouse:GetMouseTarget()

        local ExistsMouseState = false
        for MouseIcon, HoverList in self.HoverStates do
            for _, HoverItem in HoverList do
                if (MouseHover ~= nil and HoverItem ~= nil) and (MouseHover == HoverItem or MouseHover:IsDescendantOf(HoverItem)) and self.HoverStatesEnabled == true then
                    Interface.Icon.Image = "rbxassetid://" .. MouseIcon
                    ExistsMouseState = true
                    
                    break
                end
            end
        end

        if not ExistsMouseState then
            Interface.Icon.Image = "rbxassetid://18225500912" --// Static because there's no point of dynamically setting it to use up more memory/performance
        end
    end)

    --// Bind to click
    UserInputService.InputBegan:Connect(function(Input, IsTyping)
        if IsTyping then return end
        local Interface = self.Util.UI:WaitForInterface("Cursor")

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local Id = Interface.Icon.Image:match("%d+")
            if self.HoverStateClicks[Id] then
                self.HoverStateClicks[Id](self.Util.Mouse:GetMouseTarget().Parent)
            end
        end
    end)
end


function Cursor:KnitInit()
    
end


return Cursor
