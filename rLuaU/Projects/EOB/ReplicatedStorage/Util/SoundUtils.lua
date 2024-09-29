local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Sound = Knit.CreateController { 
    Name = "Sound";
    CachedVolumes = {} 
}

function Sound:Silence()
    for _, SoundGroup in SoundService:GetChildren() do
        TweenService:Create(
            SoundGroup,
            TweenInfo.new(0.5),
            {
                Volume = SoundGroup.Volume / 3
            }
        ):Play()
    end
end

function Sound:Reverse()
    for _, SoundGroup in SoundService:GetChildren() do
        TweenService:Create(
            SoundGroup,
            TweenInfo.new(0.5),
            {
                Volume = self.CachedVolumes[SoundGroup.Name]
            }
        ):Play()
    end
end

function Sound:PlaySoundTrack(Area)
    for _, SoundTrack in SoundService.Music:GetChildren() do
        local Music = SoundTrack:FindFirstChildWhichIsA("Sound")

        if Music then
            --// Slowly fade it out
            local Fade = TweenService:Create(
                Music,
                TweenInfo.new(2),
                {
                    Volume = 0;
                }
            )
            Fade:Play()
            Fade.Completed:Wait()
        end
    end

    --// Fade in new music
    local Music = SoundService.Music:FindFirstChild(Area):FindFirstChildWhichIsA("Sound")
    TweenService:Create(
        Music,
        TweenInfo.new(5),
        {
            Volume = 1;
        }
    ):Play()
end

function Sound:KnitStart()
    for _, SoundGroup in SoundService:GetChildren() do
        self.CachedVolumes[SoundGroup.Name] = SoundGroup.Volume
    end
end


function Sound:KnitInit()
    
end


return Sound
