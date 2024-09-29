local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local HitboxController = Knit.CreateController{
    Name = "Hitbox";
    Controllers = {
        ["Player"] = "None";
        ["External"] = "None";
    };
}

function HitboxController:New(Size, Reach)
    local HitboxClass = {Controller = self}
    HitboxClass.Hitbox = nil
    HitboxClass.Blacklist = {}
    HitboxClass.OnHit = nil
    HitboxClass.Enabled = false

    function HitboxClass.Enable(self)
        self.Enabled = true

        local Character = self.Controller.Controllers.Player:GetCharacter()
        local PrimaryPart = Character.PrimaryPart

        self.Hitbox = self.Controller.Instancer:CreateInstance(
            "Part",
            Character,
            {
                Size = Size;
                CFrame = PrimaryPart.CFrame + PrimaryPart.CFrame.LookVector * (Size.Z / 2 + (Reach or 1));
                CanCollide = false;
                Transparency = 0.7;
                Color = Color3.new(1, 0, 0)
            }
        )
        self.Hitbox:Attach(PrimaryPart)

        self.Hitbox:RenderOnExistance(function()
            if self.Enabled == false then return end
            
            local IsOverlap, OverlapList = self.Hitbox:OverlapsWith(nil, {workspace}) 

            if IsOverlap and self.OnHit then
                for _, Part in OverlapList do
                    if self.Enabled == false then break end
                    if Part:IsDescendantOf(Players.LocalPlayer.Character) or Part:IsDescendantOf(workspace.Debris) then continue end

                    local Hum = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")

                    if Part.Parent:IsA("Tool") then
                        continue
                    end

                    if Hum and not table.find(self.Blacklist, Hum) then
                        table.insert(self.Blacklist, Hum)
                        self.OnHit(
                            Part,
                            Hum,
                            self.Hitbox.Position
                        )
                    elseif not Hum and not table.find(self.Blacklist, Part) then
                        table.insert(self.Blacklist, Part)
                        self.OnHit(
                            Part,
                            nil,
                            self.Hitbox.Position
                        )
                    end
                end
            end
        end)
    end

    function HitboxClass.Disable(self)
        self.Enabled = false
        self.Controller.Instancer:ClearCache()
        self.Blacklist = {}
    end

    return HitboxClass
end

function HitboxController:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    self.Instancer = self.Controllers.External:Load("Instancer").new()
end


function HitboxController:KnitInit()
    
end


return HitboxController
