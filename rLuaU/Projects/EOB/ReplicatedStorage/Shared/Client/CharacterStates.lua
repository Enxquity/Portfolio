local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterStates = Knit.CreateController{
    Name = "CharacterStates";
    Controllers = {
        
    };
    Services = {
        ["CharacterStates"] = "None";
    };
    States = {[tostring(Players.LocalPlayer.UserId)] = {}};
    Effectors = {};
    EventHandlers = {};
}

function CharacterStates:AddState(State, Duration)
    self.Services.CharacterStates:AddState(State, Duration)
end

function CharacterStates:RemoveState(State)
    self.Services.CharacterStates:RemoveState(State)
end

function CharacterStates:IsStateActive(State)
    local CurrentTime = tick()
    local States = self.States[tostring(Players.LocalPlayer.UserId)]
    if States[State] and States[State] > CurrentTime then
        return true
    end

    return false
end

function CharacterStates:IsEffectorActive(Effectors)
    for State, States in self.Effectors do
        for _, Effector in States do
            if (typeof(Effectors) == "string" and Effector == Effectors or table.find(Effectors, Effector)) and self:IsStateActive(State) then
                return true
            end
        end
    end
    return false
end

function CharacterStates:GetActiveStateEffects()
    local EffectorsList = {}
    for State, States in self.Effectors do
        if not self:IsStateActive(State) then continue end
        EffectorsList[State] = {}
        for _, Effector in States do
            table.insert(EffectorsList[State], Effector)
        end
    end
    return EffectorsList
end

function CharacterStates:OnState(State, Events)
    self.EventHandlers[State] = Events
end

function CharacterStates:Render()
    RunService.RenderStepped:Connect(function()
        for State, Value in pairs(self.EventHandlers) do
            if not self.EventHandlers[State]["Update"] then continue end
            self.EventHandlers[State].Update(
                self:IsStateActive(State)
            )
        end
    end)
end

function CharacterStates:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end

    -- Listen for changes to the States property
    self.Services.CharacterStates.States:Observe(function(PlayerStates)
        self.States = PlayerStates
    end)

    self.Services.CharacterStates.Effectors:Observe(function(Effectors)
        self.Effectors = Effectors
    end)
end


function CharacterStates:KnitInit()
    
end


return CharacterStates
