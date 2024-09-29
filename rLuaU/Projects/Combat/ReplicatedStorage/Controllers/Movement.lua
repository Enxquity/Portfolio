local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Animations = require(ReplicatedStorage.Source.Controllers.Classes.Animations)

local Movement = Knit.CreateController{
    Name = "Movement";
    CharacterUtils = nil;
    SFXService = nil;
    MovesManager = nil;

    Animator = nil;
    Animators = {};

    Sprinting = false;
    Jumping = false;
    JumpingDelay = false;

    Dashing = false;
    DashingAnim = false;

    Leaping = false;

    CanSprint = true;
    CanDash = true;
    UIS = game:GetService("UserInputService")
}

function Movement:GetDirection()
    local Async, Character = self.CharacterUtils:GetCharacter():await()

    if Character and Character.PrimaryPart then
        if self.UIS:IsKeyDown(Enum.KeyCode.W) then
            return Character.PrimaryPart.CFrame.LookVector, Character, self.Animators["DashForward"], true
        elseif self.UIS:IsKeyDown(Enum.KeyCode.S) then
            return -Character.PrimaryPart.CFrame.LookVector, Character, self.Animators["DashBackward"]
        elseif self.UIS:IsKeyDown(Enum.KeyCode.D) then
            return Character.PrimaryPart.CFrame.RightVector, Character, self.Animators["DashRight"]
        elseif self.UIS:IsKeyDown(Enum.KeyCode.A) then
            return -Character.PrimaryPart.CFrame.RightVector, Character, self.Animators["DashLeft"]
        end
    end
    return
end

function Movement:Dash()
    local DashDirection, Char, Anim, Forward = self:GetDirection()

    if DashDirection and not Char.PrimaryPart:FindFirstChildWhichIsA("BodyVelocity") and self.Dashing == false and self.CanDash == true and not Char:GetAttributes()["Stunned"] and not self.JumpingDelay then
        self.Dashing = true
        self.DashingAnim = true

        local BodyVelocity = Instance.new("BodyVelocity", Char.PrimaryPart)
        BodyVelocity.MaxForce = Vector3.new(10000, 0, 10000)
        BodyVelocity.P = 200
        BodyVelocity.Velocity = DashDirection * 50
        
        local FollowMotion
        if Forward then
            FollowMotion = game:GetService("RunService").RenderStepped:Connect(function()
                BodyVelocity.Velocity = Char.PrimaryPart.CFrame.LookVector * 50
            end)
        end

        Anim:Play():OnEnd(function()
            self.DashingAnim = false;
        end)
        task.delay(.5, function()
            if FollowMotion then
                FollowMotion:Disconnect()
            end
            BodyVelocity:Destroy()
            task.wait(.5)
            self.Dashing = false
        end)
    end
end

function Movement:Leap(ChargeKey)
    local Char = Player.Character
    if not self.Dashing and not self.JumpingDelay and Char and not Char:GetAttributes()["Stunned"] and not self.Leaping then
        self.Leaping = true
        self.CanDash = false
        self:SlowStart(4)
        self.Animators["LeapCharge"]:Play()

        local ChargeHeight = 25
        while UserInputService:IsKeyDown(ChargeKey) == true do
            ChargeHeight += 1.5
            if ChargeHeight >= 100 then
                break
            end
            task.wait(0.01)
        end
        self.Animators["LeapCharge"]:Stop()

        local BodyVelocity = Instance.new("BodyVelocity", Char.PrimaryPart)
        BodyVelocity.MaxForce = Vector3.new(0, 10000, 0)
        BodyVelocity.P = 350
        BodyVelocity.Velocity = Vector3.new(0, 1, 0) * ChargeHeight
        self:SlowEnd()

        local C = Char.PrimaryPart:GetPropertyChangedSignal("Anchored"):Connect(function()
            if Char.PrimaryPart.Anchored == true then
                BodyVelocity:Destroy()
                Char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
            end
        end)

        local Shockwave = ReplicatedStorage.GameAssets.VFX.Parts.Shockwave:Clone()
        Shockwave.Parent = workspace.Visuals
        Shockwave.Size = Vector3.new(0, 3.5, 0)
        Shockwave.Position = Char.PrimaryPart.Position - Vector3.new(0, Shockwave.Size.Y/2, 0)
        TweenService:Create(Shockwave, TweenInfo.new(1) ,{Size = Vector3.new(ChargeHeight/2, 3.5, ChargeHeight/2), Transparency = 1}):Play()

        local WaitForFall = Char.Humanoid.StateChanged:Connect(function(OldState, NewState)
            if OldState == Enum.HumanoidStateType.Freefall and NewState == Enum.HumanoidStateType.Landed then
                if not Char:GetAttributes()["Stunned"] then
                    task.wait(0.5)
                    self.CanDash = true;
                end
                task.wait(1)
                self.Leaping = false
            end
        end)

        task.delay(.5, function()
            C:Disconnect()
            if BodyVelocity then
                BodyVelocity:Destroy()
            end
            task.wait(0.5)
            Shockwave:Destroy()
        end)
    end
end

function Movement:Slow(Speed, Time)
    self.CharacterUtils:GetHumanoid():andThen(function(Humanoid)
        self.CanSprint = false
        Humanoid.WalkSpeed = Speed
        task.wait(Time)
        Humanoid.WalkSpeed = (self.Sprinting == true and 20 or 8)
        self.CanSprint = true
    end)
end

function Movement:SlowStart(Speed)
    self.CharacterUtils:GetHumanoid():andThen(function(Humanoid)
        self.CanSprint = false
        Humanoid.WalkSpeed = Speed
        Humanoid.JumpPower = 0
    end)
end

function Movement:SlowEnd()
    self.CharacterUtils:GetHumanoid():andThen(function(Humanoid)
        Humanoid.WalkSpeed = (self.Sprinting == true and 20 or 8)
        Humanoid.JumpPower = 50
        self.CanSprint = true
    end)
end

function Movement:Sprint()
    self.Sprinting = not self.Sprinting

    self.CharacterUtils:GetHumanoid():andThen(function(Humanoid)
        if Humanoid.Parent:GetAttributes()["Stunned"] then return end
        if self.CanSprint == true then
            if self.Sprinting == true then
                Humanoid.WalkSpeed = 20
                while self.Sprinting == true do
                    if Humanoid.MoveDirection.Magnitude > 0 and self.CanSprint == true and not Humanoid.Parent:GetAttributes()["Stunned"] then
                        if self.Animators["Sprint"]:IsPlaying() == false then
                            self.Animators["Sprint"]:Play()
                        end
                    else
                        self.Animators["Sprint"]:Stop()
                    end
                    task.wait()
                end
                self.Animators["Sprint"]:Stop()
            else
                if not Humanoid.Parent:GetAttributes()["Stunned"] then
                    Humanoid.WalkSpeed = 8
                end
                self.Animators["Sprint"]:Stop()
            end
        end
    end):catch(warn)
end

function Movement:Init()
    self.CharacterUtils:GetHumanoid():andThen(function(Humanoid)
        self.Animators["Sprint"] = self.Animator:CreateAnimation(Humanoid, 12894913579)
        self.Animators["DashForward"] = self.Animator:CreateAnimation(Humanoid, 12884885107)
        self.Animators["DashBackward"] = self.Animator:CreateAnimation(Humanoid, 12884868426)
        self.Animators["DashRight"] = self.Animator:CreateAnimation(Humanoid, 12884880237)
        self.Animators["DashLeft"] = self.Animator:CreateAnimation(Humanoid, 12884874413)
        self.Animators["Land"] = self.Animator:CreateAnimation(Humanoid, 12899092060)
        self.Animators["LeapCharge"] = self.Animator:CreateAnimation(Humanoid, 13119219912)

        Humanoid.StateChanged:Connect(function(OldState, NewState)
            if OldState == Enum.HumanoidStateType.Freefall and NewState == Enum.HumanoidStateType.Landed then
                repeat task.wait() until self.DashingAnim == false
                Humanoid.JumpPower = 0
                Humanoid.WalkSpeed = 6
                self.Animators["Land"]:Play():OnEnd(function()
                    Humanoid.WalkSpeed = (self.Sprinting == true and 20 or 8)
                    self.CanSprint = true
                    self.Jumping = false
                    task.wait(0.5)
                    Humanoid.JumpPower = 50
                    self.JumpingDelay = false
                end)
            end
        end)
        Humanoid.StateChanged:Connect(function(OldState, NewState)
            if NewState == Enum.HumanoidStateType.Jumping then
                self.Jumping = true
                self.JumpingDelay = true
                self.CanSprint = false
            end
        end)
    end)
end

function Movement:InitAnims()
    self:Init()
    Player.CharacterAdded:Connect(function(Char)
        self:Init()
    end)
end

function Movement:KnitInit()
    print("[Knit] Movement controller initialised!")
end 

function Movement:KnitStart()
    self.CharacterUtils = Knit.GetService("CharacterUtils")
    self.SFXService = Knit.GetService("SFXService")
    self.Animator = Animations.AnimationClass()

    self.MovesManager = Knit.GetService("MovesManager")
    self.MovesManager.Sprint:Connect(function(Bool, DisableTime)
        if DisableTime then
            self.CanSprint = false
            self.Sprinting = Bool
            task.wait(DisableTime)
            self.CanSprint = true
        else
            self.Sprinting = Bool
        end
    end)
    self.MovesManager.ChangeValues:Connect(function(Values)
        for i,v in pairs(Values) do
            self[i] = v
        end
    end)
end

return Movement