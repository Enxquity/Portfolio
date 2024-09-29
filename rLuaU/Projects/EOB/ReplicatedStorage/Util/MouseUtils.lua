local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalPlayer = Players.LocalPlayer

local Mouse = Knit.CreateController { 
    Name = "Mouse" 
}

function Mouse:GetDirectionIn3DSpace()
    local MouseLocation = UserInputService:GetMouseLocation()
    local Cast = Workspace.CurrentCamera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

    return Cast.Direction
end

function Mouse:GetPositionIn3DSpace()
    local Character = LocalPlayer.Character

    if Character then
        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Include
        Params.FilterDescendantsInstances = {Workspace.Terrain, Workspace.Cutscene, Workspace.Baseplate}

        local MouseLocation = UserInputService:GetMouseLocation()
        local Cast = Workspace.CurrentCamera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

        local Ray = Workspace:Raycast(Cast.Origin, Cast.Direction * 2^16, Params)
        
        return (Ray and Ray.Position or Cast.Origin + Cast.Direction * 25)
    end
end

function Mouse:GetHitPosition()
    local Mouse = LocalPlayer:GetMouse()
    Mouse.TargetFilter = workspace.Terrain
    return Mouse.Hit.Position
end

function Mouse:GetMouseTarget()
    local Character = LocalPlayer.Character

    if Character then
        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Exclude
        Params.FilterDescendantsInstances = {Character, workspace.Debris}

        local Mouse = LocalPlayer:GetMouse()
        local MouseLocation = UserInputService:GetMouseLocation()
        local Cast = Workspace.CurrentCamera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

        local Ray = Workspace:Raycast(Cast.Origin, Mouse.UnitRay.Direction * 2^16, Params)

        return Ray and Ray.Instance or nil
    end
end

function Mouse:KnitStart()
    
end


function Mouse:KnitInit()
    
end


return Mouse
