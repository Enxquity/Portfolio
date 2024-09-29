local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Iris = require(ReplicatedStorage.Packages.Iris)

local DebugController = Knit.CreateController{
    Name = "DebugController";
    Controllers = {
        ["CharacterStates"] = "None"
    };
}

function DebugController:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    Iris.Init():Connect(function()
        Iris.Window({"Debug Window"}, {size = Iris.State(Vector2.new(300, 400))})
            local RollingDelta = Iris.State(0)
            local LastTime = Iris.State(os.clock())
            
            Iris.SeparatorText{"Runtime Info"}

            local Time = os.clock()
            local DeltaTime = Time - LastTime.value
            RollingDelta.value += (DeltaTime - RollingDelta.value) * 0.2
            LastTime.value = Time
            Iris.Text({ string.format("Average %.3f ms/frame (%.1f FPS)", RollingDelta.value * 1000, 1 / RollingDelta.value) })

            --// States
            Iris.SeparatorText{"States"}

            Iris.Text{`Stun: {self.Controllers.CharacterStates:IsStateActive("Stun")}`}
            
            Iris.Tree({"State Effectors Active:"})
                do
                    local EffectorsList = self.Controllers.CharacterStates:GetActiveStateEffects()
                    for State, States in EffectorsList do
                        Iris.SeparatorText{State}
                        for _, Effector in States do
                            Iris.Text{Effector}
                        end
                    end
                end
            Iris.End()

            --// Debug lines
            Iris.SeparatorText{"Debug Lines"}
            
            local VisionDistance = Iris.State(15)

            local VisionLines = Iris.Checkbox{"Display Vision"}
            Iris.SliderNum({"Vision Length", 1, 15, 100}, {number = VisionDistance})

            --if VisionLines.isChecked.value then
            task.spawn(function()
                local Character = Players.LocalPlayer.Character
                if Character then
                    local AngleA = Character.PrimaryPart:FindFirstChild("AngleA")
                    local AngleB = Character.PrimaryPart:FindFirstChild("AngleB")
                    local BeamA = Character:FindFirstChild("BeamA")
                    local BeamB = Character:FindFirstChild("BeamB")

                    if not AngleA or not AngleB then
                        AngleA = Instance.new("Attachment", Character.PrimaryPart)
                        AngleB = Instance.new("Attachment", Character.PrimaryPart)

                        AngleA.Name = "AngleA"
                        AngleB.Name = "AngleB"
                    end

                    if not BeamA or not BeamB then
                        BeamA = Instance.new("Beam", Character)
                        BeamB = Instance.new("Beam", Character)
                        
                        BeamA.Name = "BeamA"
                        BeamB.Name = "BeamB"

                        BeamA.Width0 = 0.1
                        BeamA.Width1 = 0.1
                        BeamA.LightEmission = 1
                        BeamA.Color = ColorSequence.new(Color3.new(1, 0, 0))
                        BeamA.FaceCamera = true
                        BeamA.Attachment0 = Character.PrimaryPart.RootAttachment

                        BeamB.Width0 = 0.1
                        BeamB.Width1 = 0.1
                        BeamB.LightEmission = 1
                        BeamB.Color = ColorSequence.new(Color3.new(1, 0, 0))
                        BeamB.FaceCamera = true
                        BeamB.Attachment0 = Character.PrimaryPart.RootAttachment
                    end

                    AngleA.WorldCFrame = Character.PrimaryPart.CFrame + ((Character.PrimaryPart.CFrame.LookVector + Character.PrimaryPart.CFrame.RightVector * 1.7).Unit * VisionDistance:get())
                    AngleB.WorldCFrame = Character.PrimaryPart.CFrame + ((Character.PrimaryPart.CFrame.LookVector - Character.PrimaryPart.CFrame.RightVector * 1.7).Unit * VisionDistance:get())

                    BeamA.Attachment1 = AngleA
                    BeamB.Attachment1 = AngleB

                    BeamA.Enabled = VisionLines.isChecked.value
                    BeamB.Enabled = VisionLines.isChecked.value
                end
            end)
            --end
        Iris.End()
    end)
end


function DebugController:KnitInit()
    
end


return DebugController
