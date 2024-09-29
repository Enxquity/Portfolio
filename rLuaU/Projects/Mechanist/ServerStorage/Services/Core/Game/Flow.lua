local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Flow = Knit.CreateService {
    Name = "Flow",
    Client = {},
}


function Flow:KnitStart()
    while task.wait(0.2) do
        --// Electricity flow
        for _, Power in pairs(CollectionService:GetTagged("Power")) do
            if Power:HasTag("Output") then
                for _, ConnectionA in pairs(Power.PowerInfo.Outputs:GetChildren()) do
                    if Power.PowerInfo.Power.Value > 0 and not ConnectionA.Value.Parent:GetAttribute("RestrictPower") then
                        local Connection = ConnectionA.Value
                        local PowerChange = math.min(Power.PowerInfo.Flowrate.Value, Connection.PowerInfo.Flowrate.Value)
                        if PowerChange >= Power.PowerInfo.Power.Value then
                            PowerChange = Power.PowerInfo.Power.Value
                        end
                        if Connection.PowerInfo.Power.Value + PowerChange >= Connection.PowerInfo.PowerMax.Value then
                            PowerChange = Connection.PowerInfo.PowerMax.Value-Connection.PowerInfo.Power.Value
                        end
                        
                        Power.PowerInfo.Power.Value = math.clamp(Power.PowerInfo.Power.Value - PowerChange, 0, Power.PowerInfo.PowerMax.Value)
                        Connection.PowerInfo.Power.Value = math.clamp(Connection.PowerInfo.Power.Value + PowerChange, 0, Connection.PowerInfo.PowerMax.Value)
                        
                        --// Flowrate
                        Power.PowerInfo.RealFlowrate.Value = (Power.PowerInfo.Power.Value - Power.PowerInfo.LastPower.Value)
                        Connection.PowerInfo.RealFlowrate.Value = (Connection.PowerInfo.Power.Value - Connection.PowerInfo.LastPower.Value)
                        
                        Power.PowerInfo.LastPower.Value = Power.PowerInfo.Power.Value
                        Connection.PowerInfo.LastPower.Value = Connection.PowerInfo.Power.Value
                    end
                end
            end
            if Power:HasTag("Input") and not Power.Parent:GetAttribute("RestrictPower") then
                if Power.PowerInfo.Power.Value > 0 then
                    Power.PowerInfo.Power.Value = math.clamp(Power.PowerInfo.Power.Value - Power.PowerInfo.Usage.Value, 0, Power.PowerInfo.PowerMax.Value)
                end
            end
        end

        --// Item flow
        for _, Pipe in pairs(CollectionService:GetTagged("Pipe")) do
            if (Pipe:HasTag("Machine") and Pipe:HasTag("Output")) or (not Pipe:HasTag("Machine")) then
                for _, ConnectorA in pairs(Pipe.PipeInfo.Connections:GetChildren()) do
                    local Connection = ConnectorA.Value
                    if Connection then
                        Connection = Connection.Parent
                        
                        local ConnectionItem = HttpService:JSONDecode(Connection.PipeInfo.Item.Value)
                        local PipeItem = HttpService:JSONDecode(Pipe.PipeInfo.Item.Value)

                        if Pipe.PipeInfo.CurrentStorage.Value > 0 and Connection.PipeInfo.CurrentStorage.Value < Connection.PipeInfo.Storage.Value and (PipeItem[1]) and ((not ConnectionItem[1]) or (ConnectionItem[1] == PipeItem[1])) then
                            Connection.PipeInfo.Item.Value = Pipe.PipeInfo.Item.Value
                            Connection.PipeInfo.CurrentStorage.Value += 1
                            Pipe.PipeInfo.CurrentStorage.Value -= 1
                        end
                    end
                end
            end
            if 
        end
    end
end


function Flow:KnitInit()
    
end


return Flow
