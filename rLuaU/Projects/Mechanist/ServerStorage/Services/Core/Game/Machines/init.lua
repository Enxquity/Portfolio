local CollectionService = game:GetService("CollectionService")
local Machines = {}
Machines.__index = Machines

function Machines.new(Identifier)
    local Machine = {}
    Machine.init = nil;
    Machine.power = nil;
    Machine.identifier = Identifier
    return setmetatable(Machine, Machines)
end

function Machines.Init()
    local MachinesList = {}
    for i,v in pairs(script:GetChildren()) do
        local MachineFuncs = require(v)
        local NewMachine = Machines.new(v.Name)
        NewMachine.init = MachineFuncs["init"] or MachineFuncs["Init"] or nil
        NewMachine.power = MachineFuncs["power"] or MachineFuncs["Power"] or nil
        NewMachine.task_complete = MachineFuncs["task"] or MachineFuncs["Task"] or nil
        NewMachine.task_time = MachineFuncs["task_time"] or MachineFuncs["Task_Time"] or nil
        NewMachine.current_time = tick();

        if NewMachine.init then
            NewMachine.init()
        end
        table.insert(MachinesList, NewMachine)
    end

    while task.wait() do
        for i,v in pairs(MachinesList) do
            local Identifier = v.identifier
            for _, Machine in pairs(CollectionService:GetTagged(Identifier)) do
                if Machine.Parent ~= workspace then continue end
                if Machine:GetAttribute("RestrictPower") == true then v.power(0, Machine) continue end
                local Power = (Machine.Power.PowerInfo.Power.Value / Machine.Power.PowerInfo.PowerMax.Value)
                v.power(Power, Machine)
                if tick() - v.current_time  >= v.task_time(Power) then
                    v.task_complete(Power, Machine);
                    v.current_time = tick()
                end
            end
        end
    end
end

return Machines