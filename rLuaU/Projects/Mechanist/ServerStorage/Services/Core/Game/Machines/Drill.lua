local HttpService = game:GetService("HttpService")
local Drill = {
    task_time = function(power)
        return 1 * (power^-0.5)
    end
}

Drill.power = function(Power, Machine)
    
end

Drill.task = function(Power, Machine)
    Machine.Solid.PipeInfo.Item.Value = HttpService:JSONEncode({
        "Low Quality Rock";
        2;
    })
    Machine.Solid.PipeInfo.CurrentStorage.Value += 1
    if Machine.Solid.PipeInfo.CurrentStorage.Value == Machine.Solid.PipeInfo.Storage.Value then
        Machine:SetAttribute("RestrictPower", true)
        task.spawn(function()
            repeat 
                task.wait()
            until Machine.Solid.PipeInfo.CurrentStorage.Value < Machine.Solid.PipeInfo.Storage.Value
            Machine:SetAttribute("RestrictPower", false)
        end)
    end
end

return Drill