local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HitService = Knit.CreateService {
    Name = "HitService",
    Services = {
        ["Sender"] = "None";
        ["VFXPacket"] = "None";
        ["CharacterStates"] = "None";
        ["HealthService"] = "None";
    },
    Client = {},
}

function HitService.Client:Hit(Player, Target, LookDirection, HitPosition)
    return self.Server:HandleHit(
        Player.Character, 
        Target,
        LookDirection,
        HitPosition
    )
end

function HitService:HandleHit(Attacker: Model, Target: Model, LookDirection: string, HitPosition: Vector3)
    print(`Handling a hit request between Attacker: {Attacker.Name} and the target {Target.Name}`)

    local TargetPlayer = Players:GetPlayerFromCharacter(Target)
    local Blocking = TargetPlayer and self.Services.CharacterStates:IsStateActive(
        TargetPlayer,
        "Blocking"
    ) or nil

    if LookDirection == "Front" and Blocking == true then
        local BlockHealth = self.Services.HealthService:GetHealth(TargetPlayer, "Block")
        warn(`{TargetPlayer.Name}'s block health is at: {BlockHealth}`)

        if BlockHealth == 0 then
            self.Services.CharacterStates:RemoveState(
                TargetPlayer, 
                "Blocking"
            )

            self.Services.CharacterStates:AddState(TargetPlayer,
                "Stun", 
                1
            )

            self.Services.VFXPacket:FireAllPacket("BlockBreak", HitPosition)
        else
            self.Services.HealthService:TakeDamage(
                TargetPlayer,
                 "Block",
                  1
            )

            self.Services.VFXPacket:FireAllPacket("Clash", HitPosition)
        end
    else
        --// Apply damage
        Target:FindFirstChildWhichIsA("Humanoid"):TakeDamage(
            15
        )
        
        self.Services.CharacterStates:AddState(TargetPlayer,
            "Stun", 
            1
        )

        self.Services.VFXPacket:FireAllPacket("SwordHit", HitPosition)
    end
end

function HitService:KnitStart()
    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end

end


function HitService:KnitInit()
    
end


return HitService
