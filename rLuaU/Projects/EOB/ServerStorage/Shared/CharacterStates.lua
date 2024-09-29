local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterStatesService = Knit.CreateService{
    Name = "CharacterStates",
    Client = {
        States = Knit.CreateProperty({}),
        Effectors = Knit.CreateProperty({})
    }
}

function CharacterStatesService.Client:AddState(...)
    return self.Server:AddState(...)
end

function CharacterStatesService.Client:RemoveState(...)
    return self.Server:RemoveState(...)
end

function CharacterStatesService:AddState(Player, State, Duration)
    local CurrentTime = tick()
    local playerStates = self.Client.States:Get() or {}
    playerStates[Player.UserId] = playerStates[Player.UserId] or {}
    playerStates[Player.UserId][State] = CurrentTime + (Duration or math.huge)
    self.Client.States:SetFor(Player, playerStates)

    if self.EventHandlers[State] and self.EventHandlers[State].OnAdd then
        self.EventHandlers[State].OnAdd(Player)
    end
end

function CharacterStatesService:RemoveState(Player, State)
    local playerStates = self.Client.States:Get() or {}
    if playerStates[Player.UserId] then
        playerStates[Player.UserId][State] = nil
        self.Client.States:SetFor(Player, playerStates)

        if self.EventHandlers[State] and self.EventHandlers[State].OnRemove then
            self.EventHandlers[State].OnRemove(Player)
        end
    end
end

function CharacterStatesService:IsStateActive(Player, State)
    local CurrentTime = tick()
    local playerStates = self.Client.States:Get() or {}
    if playerStates[Player.UserId] and playerStates[Player.UserId][State] and playerStates[Player.UserId][State] > CurrentTime then
        return true
    end

    if playerStates[Player.UserId] then
        playerStates[Player.UserId][State] = nil
        self.Client.States:SetFor(Player, playerStates)
    end
    return false
end

function CharacterStatesService:AddStateEffectors(State, Effectors)
    local currentEffectors = self.Client.Effectors:Get() or {}
    currentEffectors[State] = Effectors
    self.Client.Effectors:Set(currentEffectors)  -- This is for all clients
end

function CharacterStatesService:IsEffectorActive(Player, Effectors)
    local effectors = self.Client.Effectors:Get() or {}
    for State, States in pairs(effectors) do
        for _, Effector in ipairs(States) do
            if (typeof(Effector) == "string" and Effector == Effectors or table.find(States, Effector)) and self:IsStateActive(Player, State) then
                return true
            end
        end
    end
    return false
end

function CharacterStatesService:GetActiveStateEffects(Player)
    local EffectorsList = {}
    local effectors = self.Client.Effectors:Get() or {}
    for State, States in pairs(effectors) do
        if not self:IsStateActive(Player, State) then continue end
        EffectorsList[State] = {}
        for _, Effector in ipairs(States) do
            table.insert(EffectorsList[State], Effector)
        end
    end
    return EffectorsList
end

function CharacterStatesService:OnState(State, Events)
    self.EventHandlers[State] = Events
end

function CharacterStatesService:Render()
    RunService.Heartbeat:Connect(function()
        for UserId, States in pairs(self.Client.States:Get() or {}) do
            local Player = Players:GetPlayerByUserId(UserId)
            if not Player then continue end
            for State, _ in pairs(States) do
                if not self.EventHandlers[State] or not self.EventHandlers[State]["Update"] then continue end
                self.EventHandlers[State].Update(Player, self:IsStateActive(Player, State))
            end
        end
    end)
end

function CharacterStatesService:PlayerAdded(Player)
    local playerStates = self.Client.States:Get() or {}
    playerStates[Player.UserId] = {}
    self.Client.States:SetFor(Player, playerStates)
end

function CharacterStatesService:PlayerRemoving(Player)
    local playerStates = self.Client.States:Get() or {}
    playerStates[Player.UserId] = nil
    self.Client.States:SetFor(Player, playerStates)
end

function CharacterStatesService:KnitInit()
    self.EventHandlers = {}
end

function CharacterStatesService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        self:PlayerAdded(Player)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        self:PlayerRemoving(Player)
    end)

    for _, Player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(Player)
    end
end

return CharacterStatesService
