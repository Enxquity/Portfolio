local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
return {
    Run = function (self)
        local Cutscene = workspace:WaitForChild("Cutscene")

        local Fader = self.Controllers["UI"]:NewFader()
        local Scheduler = self.Controllers["TaskScheduler"]:New()

        --// Disable ui
        self.Controllers["UI"]:Disable()

        --// Initialisation
        self:GoTo(Cutscene:WaitForChild("House").ViewPoint.CFrame)
        task.wait(7) --// Temporary due to game load in times

        --// Cutscene plays
        SoundService.SFX.Bell:Play()
        Scheduler:ScheduleForAsync(3, function()
            Fader:In()
        end):AndThen(function()
            Scheduler:ScheduleForAsync(1.5, function()
                self:RunAnimation(
                    Cutscene.House.Layout.Frames1
                )
                self:RunAnimation(
                    Cutscene.House.Layout.Frames2
                )
            end):AndThen(Fader.Out, Fader)
        end) --// Look right, look back up
        task.wait(1)

        --// Reset everything back to default
        self.Controllers["Player"]:PivotTo(
            self.Controllers["Camera"]:GetCFrame() + self.Controllers["Camera"]:GetCFrame().LookVector * 2
        )

        self.Controllers["UI"]:Enable()
        Scheduler:ScheduleFor(2, function()
            Fader:In()
        end)
    end
}