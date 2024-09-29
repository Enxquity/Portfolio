local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local Tween = game:GetService("TweenService");

local Knit = require(ReplicatedStorage.Packages.Knit)
local Animation = require(ReplicatedStorage.Source.Controllers.Classes.Animations)
local RayHitbox = require(ReplicatedStorage.ExternalModules.RayHitbox)
local Zone = require(ReplicatedStorage.ExternalModules.Zone)

local MovesManager = Knit.CreateService{
    Name = "MovesManager";
    Client = {
        Sprint = Knit.CreateSignal();
        ChangeValues = Knit.CreateSignal();
        Shake = Knit.CreateSignal();

        Knockback = Knit.CreateSignal();
    };

    Services = {
        ["VFXService"] = nil;
        ["SFXService"] = nil;
        ["VisualiseService"] = nil;
    };

    External = {
        Modules = {
            Rocks = require(ReplicatedStorage.ExternalModules.Rocks);
            RocksGround = require(ReplicatedStorage.ExternalModules.RocksGround);
        };
    };

    HitIndexes = {};
    StunData = {};
    ImmuneData = {};
    AnimClass = Animation.AnimationClass()
}

function MovesManager.Client:BlockStart(Player)
    self.Server:BlockStart(Player)
end

function MovesManager.Client:BlockStop(Player)
    self.Server:BlockStop(Player)
end

function MovesManager.Client:Hit(Player, Target, HitMove, HitScope, LookDir)
    self.Server:Hit(Player, Target, HitMove, HitScope, LookDir)
end

function MovesManager.Client:UseMove(Player, Move, ...)
    self.Server:UseMove(Player, Move, ...)
end

function MovesManager:GetModelMass(Model)
    local Mass = 0;
    for i,v in pairs(Model:GetDescendants()) do
        if(v:IsA("BasePart")) then
            Mass += v:GetMass();
        end
    end
    return Mass;
end

function MovesManager:Knockback(Attacker, Target, Power, Length, FaceDirection, OnEnd, ExtraSettings)
    if not Target.PrimaryPart:FindFirstChildWhichIsA("BodyPosition") then
        self.Services.VisualiseService:VisualiseRay(Target.PrimaryPart.Position, ExtraSettings.LookDirection * 20, 10, {
            Color = Color3.fromRGB(0, 255, 0)
        })
        Target:FindFirstChildWhichIsA("Humanoid").AutoRotate = false
        --local Thing = (self:GetModelMass(Target))
        --Target.PrimaryPart.AssemblyLinearVelocity = ((ExtraSettings["LookDirection"] or Attacker.PrimaryPart.CFrame.LookVector) * (Power*3))
        --print(Target.PrimaryPart.AssemblyLinearVelocity)
        local BodyPosition = Instance.new("BodyPosition", Target.PrimaryPart)
        BodyPosition.MaxForce = Vector3.new(20000, 0, 20000)
        BodyPosition.D = 50
        BodyPosition.P = 350
        BodyPosition.Position = (Target.PrimaryPart.Position + ExtraSettings.LookDirection * Power)

        if FaceDirection and FaceDirection == true then
            --print("Good")
            --Tween:Create(Target.PrimaryPart, TweenInfo.new(0.2), {CFrame = CFrame.new(Target.PrimaryPart.Position, Attacker.PrimaryPart.Position) * CFrame.new(0, 1, 0)}):Play()
            Target.PrimaryPart.CFrame = CFrame.new(Target.PrimaryPart.Position, Attacker.PrimaryPart.Position)
        end

        task.delay(Length, function()
            Target:FindFirstChildWhichIsA("Humanoid").AutoRotate = true
            BodyPosition:Destroy()
            if OnEnd then OnEnd() end
        end)
    end
end

function MovesManager:KnockbackDamage(Attacker, Target, Power, Length, ExtraSettings)
    if not Target.PrimaryPart:FindFirstChildWhichIsA("BodyPosition") then
        self.Services.VisualiseService:VisualiseRay(Attacker.PrimaryPart.Position, ExtraSettings.LookDirection * 20, 10, {
            Color = Color3.fromRGB(255, 0, 0)
        })
        local KnockbackStart = tick()

        local TargetPlayer = Players:GetPlayerFromCharacter(Target)
        if TargetPlayer then
            self.Client.Knockback:Fire(TargetPlayer, Attacker, Power, Length, true, ExtraSettings)
        end

        local Hit,Pos,Norm;
        local Params = RaycastParams.new()
        Params.FilterDescendantsInstances = {Attacker, Target, workspace.Visualise, workspace.Visuals, workspace:FindFirstChild("Debris"), workspace.Players, workspace.Dummies}
        Params.FilterType = Enum.RaycastFilterType.Exclude
        repeat
            RunService.Heartbeat:Wait()
            local RayOrigin = Target.PrimaryPart.Position
            local RayEnd = -Target.PrimaryPart.CFrame.LookVector * 3.5
            local Cast = workspace:Raycast(RayOrigin, RayEnd, Params)
            if Cast and not Cast.Instance:IsDescendantOf(workspace.Dummies) then
                Hit = Cast.Instance
                Norm = Cast.Normal
                Pos = Cast.Position
            elseif Cast and Cast.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
                Pos = RayOrigin + RayEnd
                self.Services.VisualiseService:VisualisePart(RayOrigin, Pos, 5, {
                    Color = Color3.fromRGB(225, 0, 255)
                })
            else
                Pos = RayOrigin + RayEnd
                self.Services.VisualiseService:VisualisePart(RayOrigin, Pos, 5, {
                    Color = Color3.fromRGB(0, 0, 255)
                })
            end
        until (tick()-KnockbackStart >= Length) or Hit ~= nil

        if Hit then
            self:Damage(Target, 5, true)
            self.AnimClass:StopAll()
            local Anim = self.AnimClass:CreateAnimation(Target:FindFirstChildWhichIsA("Humanoid"), "12955041212")
            Anim:Play()
            self.Services.SFXService:PlayAt("Slam", Target.PrimaryPart, false, {Volume = 3})
            Target.PrimaryPart.Anchored = true
            Target.PrimaryPart.CFrame = CFrame.new(Pos + (Norm*0.6))
            Target.PrimaryPart.CFrame = CFrame.new(Target.PrimaryPart.Position, Pos+Norm)

            local VFX = ReplicatedStorage.GameAssets.VFX.Models.RockCircle:Clone()
            VFX.Parent = workspace
            VFX:SetPrimaryPartCFrame(CFrame.new(Pos-(Norm*5)))
            VFX:SetPrimaryPartCFrame(CFrame.new(VFX.PrimaryPart.Position, Pos+Norm))

            for i,v in pairs(VFX:GetChildren()) do
                v.Color = Hit.Color
                v.Material = Hit.Material
            end
            local VFXParticle1 = self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.WallRocks, Target.PrimaryPart, 100)
            local VFXParticle2 = self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Smoke, Target.PrimaryPart, 100)
            VFXParticle1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Hit.Color), ColorSequenceKeypoint.new(1, Hit.Color)}

            local CFrameValue = Instance.new("CFrameValue")
            CFrameValue.Value = VFX:GetPivot()
        
            CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
                VFX:PivotTo(CFrameValue.Value)
            end)
            
            local CF = CFrame.new(Pos)
            CF = CFrame.new(CF.Position, Pos+Norm)
            local tween = Tween:Create(CFrameValue, TweenInfo.new(0.3), {Value = CF})
            tween:Play()
        
            task.wait(3)

            local tween2 = Tween:Create(CFrameValue, TweenInfo.new(2), {Value = (CF - Norm*5)})
            tween2:Play()

            tween2.Completed:Connect(function()
                CFrameValue:Destroy()
                VFX:Destroy()
            end)
            Target.PrimaryPart.Anchored = false
            Target:FindFirstChildWhichIsA("Humanoid").AutoRotate = true
            return true
        else
            Target:FindFirstChildWhichIsA("Humanoid").AutoRotate = true
            return false
        end
    end
end

function MovesManager:Hit(Player, Target, HitMove, HitScope, LookDir)
    if Target:GetAttributes()["Immune"] then return end
    local TargetPlayer = game:GetService("Players"):GetPlayerFromCharacter(Target)

    self:InitStun(Player)
    self:InitStun(TargetPlayer or {Character = Target})
    self:InitImmune(Player)
    self:InitImmune(TargetPlayer or {Character = Target})

    if not self.HitIndexes[Target] then
        self.HitIndexes[Target] = 0
    end
    if HitMove == "M1" then
        if Target:GetAttributes()["Blocking"] then
           if HitScope == "Kick" then
                if tick()-Target:GetAttributes()["Blocking"] > 0.5 then
                    self:BlockBreak(TargetPlayer)
                    return
                else
                    self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.PerfectBlock, Target.PrimaryPart, 1)
                    self:Stun(Player, 2)
                    return
                end
           end
           self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Block, Target.PrimaryPart, 1)
           self.Services.SFXService:PlayAt("Block", Target.PrimaryPart, false, {})
           return
        end
        local KnockbackList = {13140283101, 13140290057, 13140300580}
        local Knockback = self.AnimClass:CreateAnimation(Target:FindFirstChildWhichIsA("Humanoid"), KnockbackList[math.random(1, #KnockbackList)])
        local KnockDown = self.AnimClass:CreateAnimation(Target:FindFirstChildWhichIsA("Humanoid"), "12895191103")
        Knockback:Play()

        self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Blood, Target.PrimaryPart, 100)
        if HitScope ~= "Kick" then
            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Punch, Target.PrimaryPart, 1)
            self.Services.SFXService:PlayAt("Punch", Target.PrimaryPart, false, {})
            self:Stun(TargetPlayer or {Character = Target}, 0.5)
            if TargetPlayer then
                self.Client.Sprint:Fire(TargetPlayer, false, 1)
            end
            self:Damage(Target,  4)
            --self:Knockback(Player.Character, Target, 5, 0.2, true, function() end, {LookDirection = LookDir})
            self.Client.Knockback:Fire(TargetPlayer, Player.Character, 5, 0.2, true, {LookDirection = LookDir})
        else
            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Kick, Target.PrimaryPart, 1)
            self.Services.SFXService:PlayAt("Punch", Target.PrimaryPart, false, {Volume = 3})
            self:Damage(Target, 6)
            self:Immune(TargetPlayer or {Character = Target}, 3.5)
            self:Stun(TargetPlayer or {Character = Target}, 3)
            local WallHit = self:KnockbackDamage(Player.Character, Target, 15, 0.5, {LookDirection = LookDir})
            Knockback:Stop()
            KnockDown:Play():OnEnd(function()
                if TargetPlayer then
                    self.Client.Sprint:Fire(TargetPlayer, false, 1)
                end
                task.wait(0.2)
                if WallHit then
                    self:Immune(TargetPlayer or {Character = Target}, 2)
                else
                    self:Unstun(TargetPlayer or {Character = Target})
                end
            end)
            if WallHit and WallHit == true then
                KnockDown:Stop()
            end
        end
    end
end

function MovesManager:UseMove(Player, Move, ...)
    local Character = Player.Character
    if not Character then return end

    if Move == "GroundSlam" then
        self.External.Modules.Rocks.RockFlying(Character["Right Leg"].Position, 40, 1, 1, 1, 20)
        self.External.Modules.RocksGround.Ground(Character["Right Leg"].Position, 15, Vector3.new(4, 4, 4), {workspace.Players, workspace.Visuals, workspace.Visualise, workspace.Dummies}, 15, false, 3)

        self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Shockwave, Character["Right Leg"], 5000)
        self.Services.VFXService:Shockwave(self.Services.VFXService:GetGround(Character["Right Leg"].Position, {Character}) + Vector3.new(0, 3.5, 0), 75)

        local Plrs = workspace.Players:GetChildren()
        local Dummies = workspace.Dummies:GetChildren()
        table.move(Dummies, 1, #Dummies, #Plrs + 1, Plrs)

        for _, Char in pairs(Plrs) do
            local Plr = Players:GetPlayerFromCharacter(Char)
            if Char then
                if (Character.PrimaryPart.Position - Char.PrimaryPart.Position).Magnitude <= 17 then
                    if Plr then
                        self.Client.Shake:Fire(Plr, "Explosion")
                    end
                    if not Char:GetAttributes()["Blocking"] then
                        local Knockback = self.AnimClass:CreateAnimation(Char:FindFirstChildWhichIsA("Humanoid"), "12895181824")
                        if Plr == Player then continue end
                        self:Stun(Plr or {Character = Char}, 3)
                        Knockback:Play()
                        self:Damage(Char, 15)
                    else
                        self:BlockBreak(Plr or {Character = Char}, 3)
                        self:Damage(Char, 3)
                    end
                elseif (Character.PrimaryPart.Position - Char.PrimaryPart.Position).Magnitude <= 25 and (Character.PrimaryPart.Position - Char.PrimaryPart.Position).Magnitude > 17 then
                    if Plr then
                        self.Client.Shake:Fire(Plr, "Explosion")
                    end
                    self:Stun(Plr or {Character = Char}, 2)
                end
            end
        end


    end
    if Move == "RagingFist" then
        local Dir, HeldDuration = unpack({...})
        local VFX = self.Services.VFXService:AddVFX(ReplicatedStorage.GameAssets.VFX.Parts.RagingFist, Character["Right Arm"].VFXPoint)
        VFX.Size = Vector3.new(0, 0, 0)

        local FireParticle = self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.RagingFist, Character["Right Arm"].VFXPoint, 1, {}, Dir)

        Tween:Create(VFX, TweenInfo.new(1, Enum.EasingStyle.Quint), {Size = Vector3.new(15, 15, 50)}):Play()
        self.Services.VFXService:Projectile(VFX, Dir, 100, 0.01 * math.clamp(HeldDuration, 1, 3), Character, function(RayResult)
            Tween:Create(VFX, TweenInfo.new(0.1), {Size = Vector3.new(0, 0, 0)}):Play()
            Debris:AddItem(VFX, 0.1)

            local CF = CFrame.lookAt(RayResult.Position, RayResult.Position + RayResult.Normal) * CFrame.Angles(math.rad(90), 0, math.pi) + RayResult.Normal * 3.5
            self.Services.VFXService:Shockwave(CF, 75, 0.05)
            self.External.Modules.Rocks.RockFlying(CF.Position, 40, 1, 1, 1, 20, RayResult.Instance.Material, RayResult.Instance.Color)
            
            local EffectPart = Instance.new("Part")
            EffectPart.Parent = workspace.Visuals
            EffectPart.Anchored = true
            EffectPart.CFrame = CF - RayResult.Normal * 3.5
            EffectPart.Transparency = 1

            self.Services.SFXService:PlayBreak(self.Services.VFXService:GetMaterial(RayResult), EffectPart)
            Debris:AddItem(EffectPart, 10)

            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Rings, EffectPart, 50,{
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0,RayResult.Instance.Color),ColorSequenceKeypoint.new(1,RayResult.Instance.Color)}
            })
            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Dust, EffectPart, 35,{
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0,RayResult.Instance.Color),ColorSequenceKeypoint.new(1,RayResult.Instance.Color)}
            })
            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Burst, EffectPart, 250,{
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0,RayResult.Instance.Color),ColorSequenceKeypoint.new(1,RayResult.Instance.Color)}
            })
            self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.Crack, EffectPart, 2, {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0,RayResult.Instance.Color),ColorSequenceKeypoint.new(1,RayResult.Instance.Color)}
            })

            --local Plrs = workspace.Players:GetChildren()
            --local Dummies = workspace.Dummies:GetChildren()
            --table.move(Dummies, 1, #Dummies, #Plrs + 1, Plrs)
            local HitboxZone = Zone.new(VFX.Hitbox)
            local Parts = HitboxZone:getParts()
            local BlacklistedChars = {}

            for _, Part in pairs(Parts) do
                local Plr = Players:GetPlayerFromCharacter(Part.Parent)
                if Part.Parent:FindFirstChildWhichIsA("Humanoid") then
                    local Char = Part.Parent
                    if table.find(BlacklistedChars, Char) then continue end

                    if Plr then
                        self.Client.Shake:Fire(Plr, "Explosion")
                    end
                    if not Char:GetAttributes()["Stunned"] then
                        local Knockback = self.AnimClass:CreateAnimation(Char:FindFirstChildWhichIsA("Humanoid"), "12895181824")
                        if Plr == Player then continue end
                        self:Stun(Plr or {Character = Char}, 3)
                        Knockback:Play()
                        self:Damage(Char, 7)
                    else
                        self:Damage(Char, 3)
                        self:Stun(Plr or {Character = Char}, 1)
                    end
                    table.insert(BlacklistedChars, Char)
                end
            end
        end)
    end
end

function MovesManager:BlockStart(Player)
    local Char = Player.Character

    if Char and not Char:GetAttributes()["Stunned"] then
        local BlockAnim = self.AnimClass:CreateAnimation(Char:FindFirstChildWhichIsA("Humanoid"), "12894877397")
        BlockAnim:Play()

        self.Client.ChangeValues:Fire(Player, {
            Sprinting = false;
            CanSprint = false;
            CanDash = false;
        })
        
        Char:FindFirstChildWhichIsA("Humanoid").JumpPower = 0
        Char:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 4

        Char:SetAttribute("Blocking", tick())
    end
end

function MovesManager:BlockStop(Player)
    local Char = Player.Character

    if Char then
        self.AnimClass:StopId(12894877397)
        self.Client.ChangeValues:Fire(Player, {
            Sprinting = false;
            CanSprint = true;
            CanDash = true;
        })

        if not Char:GetAttributes()["Stunned"] then
            Char:FindFirstChildWhichIsA("Humanoid").JumpPower = 50
            Char:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 8
        end

        Char:SetAttribute("Blocking", nil)
    end
end

function MovesManager:BlockBreak(Player, Length)
    local Char = Player.Character

    if Char then
        Char:SetAttribute("Blocking", nil)
        self.AnimClass:StopId(12894877397)
        self.Services.VFXService:Emit(ReplicatedStorage.GameAssets.VFX.Particles.BlockBreak, Char.PrimaryPart, 20)
        self.Services.SFXService:PlayAt("BlockBreak", Char.PrimaryPart, false, {})
        self:Stun(Player, Length or 2)
    end
end

--Rewritten Stun
function MovesManager:Stun(Player, Length)
    --Check if player has stun data
    if typeof(Player) == "table" then
        if not self.StunData[Player.Character] then
            self.StunData[Player.Character] = Length
        else
            self.StunData[Player.Character] += Length
        end
        return
    end --// Dummies
    if not self.StunData[Player] then
        self.StunData[Player] = Length
    else
        self.StunData[Player] += Length
    end
end 

function MovesManager:Immune(Player, Length)
    if typeof(Player) == "table" then
        if not self.ImmuneData[Player.Character] then
            self.ImmuneData[Player.Character] = Length
        else
            self.ImmuneData[Player.Character] += Length
        end
        return
    end --// Dummies
    if not self.ImmuneData[Player] then
        self.ImmuneData[Player] = Length
    else
        self.ImmuneData[Player] += Length
    end
end

function MovesManager:Unstun(Player)
    if typeof(Player) == "table" then
        self.StunData[Player.Character] = 0
    end
    self.StunData[Player] = 0
end

function MovesManager:UnImmune(Player)
    if typeof(Player) == "table" then
        self.ImmuneData[Player.Character] = 0
    end
    self.ImmuneData[Player] = 0
end

function MovesManager:IsStunned(Player)
    if typeof(Player) == "table" then
        return self.StunData[Player.Character] > 0
    end
    if not self.StunData[Player] then
        self.StunData[Player] = 0
        return false
    end
    return self.StunData[Player] > 0
end

function MovesManager:IsImmune(Player)
    if typeof(Player) == "table" then
        return self.ImmuneData[Player.Character] > 0
    end
    if not self.ImmuneData[Player] then
        self.ImmuneData[Player] = 0
        return false
    end
    return self.ImmuneData[Player] > 0
end

function MovesManager:InitStun(Player)
    if typeof(Player) == "table" then
        if not self.StunData[Player.Character] then
            self.StunData[Player.Character] = 0
        end
        return
    end --// Dummies
    if not self.StunData[Player] then
        self.StunData[Player] = 0
    end
end

function MovesManager:InitImmune(Player)
    if typeof(Player) == "table" then
        if not self.ImmuneData[Player.Character] then
            self.ImmuneData[Player.Character] = 0
        end
        return
    end --// Dummies
    if not self.ImmuneData[Player] then
        self.ImmuneData[Player] = 0
    end
end

function MovesManager:SetTag(Character, Flag, Value)
    local Tags = Character.PrimaryPart:FindFirstChild("Tags")
    if not Tags then
        local TagCloned = ReplicatedStorage.GameAssets.UI.Tags:Clone()
        TagCloned.Parent = Character.PrimaryPart
        Tags = TagCloned
    end

    Tags.Holder:FindFirstChild(Flag).Visible = Value
end

function MovesManager:Damage(Character, Damage, IgnoreImmune)
    local Hum = Character:FindFirstChildWhichIsA("Humanoid")

    if Hum then
        --// New thread
        coroutine.wrap(function()
            local RandomX, RandomY = math.random(-200, 200)/100, math.random(-100, 0)/100
            local Indicator = ReplicatedStorage.GameAssets.UI.Damage:Clone()
            Indicator.DMG.Text = "IMMUNE"
            Indicator.StudsOffsetWorldSpace = Vector3.new(RandomX, RandomY, 0)
            Indicator.Parent = Character.PrimaryPart

            if (Character:GetAttributes()["Immune"] and IgnoreImmune) or (not Character:GetAttributes()["Immune"]) then
                Hum:TakeDamage(Damage)
                Indicator.DMG.Text = "-" .. tostring(Damage)
            end

            local IndicatorTween = Tween:Create(Indicator, TweenInfo.new(1), {StudsOffsetWorldSpace = Vector3.new(RandomX, RandomY+3, 0)})
            local IndicatorTween2 = Tween:Create(Indicator.DMG, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1})
            IndicatorTween:Play()
            IndicatorTween2:Play()

            IndicatorTween.Completed:Wait()
            Indicator:Destroy()
        end)()
    else
        Character:BreakJoints()
    end
end

function MovesManager:KnitInit()
    print("[Knit] MovesManager service initialised!")
end

function MovesManager:KnitStart()
    self.Services.VFXService = Knit.GetService("VFXService")
    self.Services.SFXService = Knit.GetService("SFXService")
    self.Services.VisualiseService = Knit.GetService("VisualiseService")

    --// Create the stun loop
    while task.wait(0.3) do --// Use a loop per 0.3 to not be too intense on the server
        for Player, Length in pairs(self.StunData) do
            if not Player.Parent then continue end
            local StunCharacter = (Player.Parent.Name == "Dummies" and Player or Player.Character)
            if Length > 0 and StunCharacter then
                local StunHumanoid = StunCharacter:FindFirstChildWhichIsA("Humanoid")
                if not StunHumanoid then continue end
                --// Make sure they are stunned

                if Player.Parent ~= workspace.Dummies then --// Check due to dummies
                    self.Client.ChangeValues:Fire(Player, {
                        Sprinting = false;
                        CanSprint = false;
                        CanDash = false;
                    }) --// Overwrite their client values to disable sprint and dash
                end

                StunHumanoid.JumpPower = 0
                StunHumanoid.WalkSpeed = 1 --// Overwrite their jump power and walkspeed

                --// Finally lets set their stunned attribute to allow communication between server, client and cross server scripts
                if StunCharacter:GetAttributes()["Stunned"] ~= true then
                    StunCharacter:SetAttribute("Stunned", Length) --// We set the value to length to more easily
                end

                if self.Services.VFXService:HasParticle(StunCharacter.PrimaryPart, "Stun") == nil then
                    self.Services.VFXService:Add(ReplicatedStorage.GameAssets.VFX.Particles.Stun, StunCharacter.PrimaryPart)
                end
                
                self:SetTag(StunCharacter, "Stunned", true)

                --// Last of all, let's subtract their stun time by the wait speed (just so their stun can end)
                self.StunData[Player] -= 0.3
                warn("Player:", Player.Name, " is stunned for another", self.StunData[Player] .. "s")
            end

            if Length <= 0 and StunCharacter and StunCharacter:GetAttributes()["Stunned"] and StunCharacter:GetAttributes()["Stunned"] ~= true then
                --self.StunData[Player] = 0 --// Incase they're below 0
                local StunHumanoid = StunCharacter:FindFirstChildWhichIsA("Humanoid")
                if not StunHumanoid then continue end

                if Player.Parent ~= workspace.Dummies then --// Check due to dummies
                    self.Client.ChangeValues:Fire(Player, {
                        Sprinting = false;
                        CanSprint = true;
                        CanDash = true;
                    }) --// We will essentially undo all our changes in reverse, this just allows the player to sprint and dash again by changing client values
                end

                StunHumanoid.JumpPower = 50 --// Default jumpower
                StunHumanoid.WalkSpeed = 8 --// Default walkspeed

                StunCharacter:SetAttribute("Stunned", nil) --// Set the value to nil, this gets rid of the attribute entirely
            end

            if StunCharacter:GetAttributes()["Stunned"] == true then
                self:SetTag(StunCharacter, "Stunned", true)
                if self.Services.VFXService:HasParticle(StunCharacter.PrimaryPart, "Stun") == nil then
                    self.Services.VFXService:Add(ReplicatedStorage.GameAssets.VFX.Particles.Stun, StunCharacter.PrimaryPart)
                end
            end

            if Length <= 0 and StunCharacter and not StunCharacter:GetAttributes()["Stunned"] then
                if self.Services.VFXService:HasParticle(StunCharacter.PrimaryPart, "Stun") ~= nil then
                    for i,v in pairs(StunCharacter.PrimaryPart:GetChildren()) do
                        if v:IsA("ParticleEmitter") then
                            v.Enabled = false
                            task.delay(v.Lifetime.Max, function()
                                v:Destroy()
                            end)
                        end
                    end
                    self.Services.VFXService:HasParticle(StunCharacter.PrimaryPart, "Stun"):Destroy()
                end
                self:SetTag(StunCharacter, "Stunned", false)
            end
        end
        for Player, Length in pairs(self.ImmuneData) do
            if not Player.Parent then continue end
            local ImmuneCharacter = (Player.Parent.Name == "Dummies" and Player or Player.Character)
            if Length > 0 and ImmuneCharacter then
                warn("Player:", Player.Name, " is immune for another", self.ImmuneData[Player] .. "s")
                ImmuneCharacter:SetAttribute("Immune", Length)
                self:SetTag(ImmuneCharacter, "Immune", true)
                self.ImmuneData[Player] -= 0.3
            end
            if Length <= 0 and ImmuneCharacter then
                ImmuneCharacter:SetAttribute("Immune", nil)
                self:SetTag(ImmuneCharacter, "Immune", false)
            end
        end
    end
end

return MovesManager

