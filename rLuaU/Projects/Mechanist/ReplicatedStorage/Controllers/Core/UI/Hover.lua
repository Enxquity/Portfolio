local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Build
Build = {

    Cache = {Power={}};
    Abreviate = function(Num)
        local AbbreviationList = {
            [1000] = "mW";
            [1000000] = "gW"
        }
        for i,v in pairs(AbbreviationList) do
            local Abbreviation = "kW"
            local Divider = 1
            if Num > i then
                Abbreviation = v
                Divider = i
            end
            return Divider, Abbreviation
        end
    end;
    init = function(Library)
        task.wait(2) --// init delay
        local Mouse = Players.LocalPlayer:GetMouse()
        
        while task.wait() do
            local Target = Mouse.Target
            if not Target then task.wait() continue end
            Target = Target.Parent

            for _, B in pairs(Build.Cache.Power) do
                B:Destroy()
            end
            if Target:HasTag("Power") then
                local NewUI = ReplicatedStorage.Game.UI.Power:Clone()
                NewUI.Parent = Target
                NewUI.Adornee = Target
                NewUI.Name = "PowerDisplayUI"

                local Divider, Abbreviator = Build.Abreviate(Target.PowerInfo.PowerMax.Value) 
                NewUI.Holder.Label.Text = Target.PowerInfo.Power.Value/Divider .. "/" .. Target.PowerInfo.PowerMax.Value/Divider .. Abbreviator
                NewUI.Holder.Info.Text = (Target:HasTag("Output") and "Output" or "Input") .. "<br/>" .. ("Flowrate: %.2fkW/s"):format(Target.PowerInfo.RealFlowrate.Value)
                table.insert(Build.Cache.Power, NewUI)
            end
            if Target:HasTag("Pipe") then
                local NewUI = ReplicatedStorage.Game.UI.Pipe:Clone()
                NewUI.Parent = Target
                NewUI.Adornee = Target
                NewUI.Name = "PipeDisplayUI"

                NewUI.Holder.Label.Text = Target.PipeInfo.CurrentStorage.Value .. "/" .. Target.PipeInfo.Storage.Value

                local Data = HttpService:JSONDecode(Target.PipeInfo.Item.Value)
                if Target.Name:find("Liquid") then
                    NewUI.Holder.Info.Text = ("%s<br/>Temp: %.2f degrees"):format(Data[1] or "None", Data[2] or 0.00)
                else
                    NewUI.Holder.Info.Text = ("%s<br/>Volume: %.2f"):format(Data[1] or "None", Data[2] or 0.00)
                end

                table.insert(Build.Cache.Power, NewUI)
            end
        end

    end;

}

return Build