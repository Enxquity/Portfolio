local HttpService = game:GetService("HttpService")
local Mine = {
    task_time = function(power)
        return 1 * (power^-0.5)
    end
}

Mine.power = function(Power, Machine)
    Machine.Handle.Motor.HingeConstraint.TargetAngle = -160 - (35 * Power)
    Machine.Saw.Blade.HingeConstraint.AngularVelocity = 10 * Power
    Machine.Saw.Blade.HingeConstraint.MotorMaxAcceleration = 10 * Power
    Machine.Saw.Blade.HingeConstraint.MotorMaxTorque = 10 * Power
    Machine.Saw.Blade.HingeConstraint.LimitsEnabled = false
end

Mine.task = function(Power, Machine)
    Machine.Solid.PipeInfo.Item.Value = HttpService:JSONEncode({
        "Unrefined Copper";
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

return Mine