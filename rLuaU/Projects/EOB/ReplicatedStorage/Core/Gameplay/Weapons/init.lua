local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local RaycastHitboxes = require(ReplicatedStorage.Packages.RaycastHitbox)

--// This whole script will need a rework eventually it's scuffed

local WeaponClass = {}
WeaponClass.__index = WeaponClass

WeaponClass.Controllers = {
    ["Player"] = "None";
    ["External"] = "None";
    ["Combo"] = "None";
    ["Cache"] = "None";
    ["Cooldown"] = "None";
    ["ReplicateVFX"] = "None";
    ["CharacterStates"] = "None";
    ["Hitbox"] = "None";
}
WeaponClass.Services = {
    ["HitService"] = "None";
    ["Blocking"] = "None";
}
WeaponClass.Initialized = false

function WeaponClass:Initialize()
    if not WeaponClass.Initialized then
        for ControllerName, _ in pairs(WeaponClass.Controllers) do
            WeaponClass.Controllers[ControllerName] = Knit.GetController(ControllerName)
        end
        for ServiceName, _ in pairs(WeaponClass.Services) do
            WeaponClass.Services[ServiceName] = Knit.GetService(ServiceName)
        end
        WeaponClass.Cache = WeaponClass.Controllers.Cache:NewCache()
        WeaponClass.Initialized = true
    end
end

function WeaponClass.new(Weapon)
    local self = setmetatable({Controllers = WeaponClass.Controllers, Services = WeaponClass.Services}, WeaponClass)
    WeaponClass:Initialize()
    
    local OriginalSword = ReplicatedStorage.Assets.Swords:FindFirstChild(Weapon.Name)
    if not OriginalSword then
        error("Original sword not found in ReplicatedStorage.Assets.Swords")
    end

    --// General
    self.Weapon = Weapon
    self.IsEquipped = false
    self.Module = require(script:FindFirstChild(Weapon.Name))

    --// Utils
    self.Player = self.Controllers.Player

    --// Animations
    self.Animations = self.Controllers.Player:LoadAnimationList(OriginalSword.Info.Animations:GetChildren())

    --// Services
    self.HitService = self.Services.HitService
    self.BlockService = self.Services.Blocking

    --// Caches
    self.Cache = self.Cache:Make(Weapon.Name, true)

    --// Combos
    self.Combo = self.Controllers.Combo:NewCombo(OriginalSword.Info.Combo.Value)

    --// Cooldowns
    self.Cooldown = self.Controllers.Cooldown:NewCooldown()
    self.BlockCooldown = self.Controllers.Cooldown:NewCooldown()

    --// Networker
    self.Network = self.Controllers.ReplicateVFX
    
    --// Tool events
    self.EquippedEvent = Weapon.Equipped:Connect(function()
        self:Equipped()
        self.IsEquipped = true
    end)
    self.UnequippedEvent = Weapon.Unequipped:Connect(function()
        self:Unequipped()
        self.IsEquipped = false
    end)
 
    --// Hitbox
    self.Hitbox = WeaponClass.Controllers.Hitbox:New(
        Vector3.new(
            5,
            4,
            5
        ),
        2
    )
    self.Hitbox.OnHit = function(...)
        self.Module.Hit(self, ...)
    end

    --// Character states
    self.States = self.Controllers.CharacterStates
    self.BlacklistedEffectors = {
        ["All"] = {"M1", "Block"};
        ["Combat"] = {"M1"};
        ["Block"] = {"Block"};
    }
    self.CanAttack = function(Attack)
        for Effector, Effected in self.BlacklistedEffectors do
            local IsEffectorApplied = self.States:IsEffectorActive({Effector})
            if IsEffectorApplied == true and table.find(Effected, Attack) then
                return false
            end
        end
        return true
    end
    

    --// Moves
    self.M1 = self.Controllers.External:Load("Input"):CreateInput(
        {Enum.UserInputType.MouseButton1},
        function()
            if self.CanAttack("M1") == false or self.Cooldown.Enabled == true or self.IsEquipped == false then return end

            self.Cooldown:Enable()
            self.Module.M1(
                self
            )
            
            if self.Cooldown:Get() < 2^8 then
                self.Cooldown:Append(0.3)
            else
                self.Cooldown:Set(0.3)
            end
        end
    )

    self.Block = self.Controllers.External:Load("Input"):CreateInput(
        {Enum.KeyCode.F},
        function()
            if self.BlockCooldown.Enabled == true or self.IsEquipped == false or self.CanAttack("Block") == false then return end
            self.Module.Block(
                self,
                true
            )

            self.BlockService:Start()
            self.States:AddState("Blocking")
        end,
        function()
            if self.BlockCooldown.Enabled == true then return end
            self.BlockCooldown:Set(0.6)
            self.Module.Block(
                self,
                false
            )
            self.States:RemoveState("Blocking")
            self.BlockService:Stop()
        end
    )

    self.Render = RunService.Heartbeat:Connect(function()
        debug.profilebegin("WeaponRender")
        if self.CanAttack("Block") == false and self.States:IsStateActive("Blocking") then
            self.Module.Block(
                self,
                false
            )
            self.Controllers.CharacterStates:RemoveState("Blocking")
        end
        debug.profileend()
    end) 

    --// Hitbox extras
    --[[
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Players.LocalPlayer.Character, Weapon, workspace.Baseplate, workspace.Debris}

    self.Hitbox.RaycastParams = Params
    self.Hitbox.DetectionMode = RaycastHitboxes.DetectionMode.PartMode--]]

    return self
end

function WeaponClass:Equipped()
    if self.Animations and self.Animations["Unsheathe"] then
        local Unsheathe: AnimationTrack = self.Animations["Unsheathe"]

        self.Animations["Idle"]:Play()
        Unsheathe:Play()
    else
        warn("Unsheathe animation not found")
    end
end

function WeaponClass:Unequipped()
    self.Animations["Unsheathe"]:Stop()
    self.Animations["Idle"]:Stop()
end

return WeaponClass
