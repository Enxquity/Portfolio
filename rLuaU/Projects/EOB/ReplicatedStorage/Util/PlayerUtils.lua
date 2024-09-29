local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalPlayer = Players.LocalPlayer

local Player = Knit.CreateController { 
    Name = "Player";
    PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
}

function Player:DisableControls()
    local Controller = self.PlayerModule:GetControls()
    Controller:Disable()
end

function Player:EnableControls()
    local Controller = self.PlayerModule:GetControls()
    Controller:Enable()
end

function Player:GetCharacter(Async)
    repeat 
        task.wait()
    until LocalPlayer.Character and LocalPlayer.Character.PrimaryPart or Async == false
    return LocalPlayer.Character
end

function Player:MoveTo(Position, DontYield)
    local Character = self:GetCharacter()
    Character.Humanoid:MoveTo(Position)

    if not DontYield then
        Character.Humanoid.MoveToFinished:Wait()
    end
end

function Player:CancelMoveTo()
    local Character = self:GetCharacter()
    Character.Humanoid:MoveTo(Character:GetPivot().Position)
end

function Player:PivotTo(CF: CFrame)
    local Character = self:GetCharacter()
    Character:PivotTo(CF)
end

function Player:DistanceFrom(Position: BasePart & Vector3)
    local NewPosition = Vector3.zero
    local Character = self:GetCharacter()

    if typeof(Position) == "Instance" then
        NewPosition =  Position.Position
    end

    return (
        NewPosition - Character:GetPivot().Position
    ).Magnitude
end

function Player:LoadAnimation(Animation)
    local Character = self:GetCharacter()
    return Character.Humanoid:LoadAnimation(Animation)
end

function Player:LoadAnimationList(AnimationList: {Instance})
    local List = {}
    for _, Animation in AnimationList do
        List[Animation.Name] = self:LoadAnimation(Animation)
    end
    return List
end

function Player:KnitStart()
    
end


function Player:KnitInit()
    
end


return Player
