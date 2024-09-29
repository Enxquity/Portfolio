local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VoiceLines = Knit.CreateController{
    Name = "VoiceLines";
    Controllers = {
        ["UI"] = "None";
        ["External"] = "None"; 
    };
}

function VoiceLines:Play(Line: string & Sound, Caption: string)
    local VoiceLine: Sound = typeof(Line) == "string" and SoundService.VoiceLines:FindFirstChild(Line) or Line
    assert(VoiceLine, `The voice line ({Line}) does not exist`)

    local CaptionText = VoiceLine:FindFirstChild("Caption") and VoiceLine.Caption.Value or Caption

    VoiceLine:Play()
    if CaptionText then
        local Interface = self.Controllers.UI:GetInterface("Captions").Holder
        local NewCaption = self.Instancer:CreateInstance(
            Interface.Caption,
            Interface,
            {
                Visible = true
            }
        )
        NewCaption.Text = CaptionText
        NewCaption:AddDebris(VoiceLine.TimeLength)
    end
end

function VoiceLines:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
   
    self.Instancer = self.Controllers.External:Load("Instancer").new()
end


function VoiceLines:KnitInit()
    
end


return VoiceLines
