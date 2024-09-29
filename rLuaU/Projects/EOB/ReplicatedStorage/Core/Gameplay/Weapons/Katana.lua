type Animations = {
    [string]: AnimationTrack
}

return {

    M1 = function(self)
        local AnimList: Animations = self.Animations

        local CurrentCombo = self.Combo:Get()
        local Anim = AnimList[`Attack{CurrentCombo}`]


        if Anim then
            self.States:AddState("Combat")
            self.Hitbox:Enable()
            Anim:Play()

            self.Cache:Push("Attack", Anim)

            Anim.Stopped:Wait()
            self.Hitbox:Disable()
            self.States:RemoveState("Combat")

            --// Increase combo counter
            self.Combo:Next()
        end
    end;

    Block = function(self, InputState)
        local AnimList: Animations = self.Animations
        local Anim = AnimList["Block"]

        if Anim then
            if InputState == true then
                Anim:Play()
            else
                Anim:Stop()
            end
        end
    end;


    Hit = function(self, Hit: Instance, Humanoid: Humanoid, HitPosition: Vector3)
        self.Hitbox:Disable()
        self.States:RemoveState("Combat")

        local Character = self.Player:GetCharacter(false)

        if not Humanoid then
            --Clash with an object
            local Attack = self.Cache:Get("Attack")
            if Attack then
                Attack:Stop()
            end
            
            self.Cooldown:Set(1)
            self.Network:SendPacket("Clash", HitPosition)
        else
            if Character then
                local HitDirection = (Character.PrimaryPart.Position - Humanoid.Parent.PrimaryPart.Position).Unit
                local LookVector = Humanoid.Parent.PrimaryPart.CFrame.LookVector
                local LookDirection = HitDirection:Dot(LookVector) > 0.5 and "Front" or "Back" 
                --self.Network:SendPacket("SwordHit", HitPosition, Humanoid)
                self.HitService:Hit(Humanoid.Parent, LookDirection, HitPosition)
            end
        end
    end
}