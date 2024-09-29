local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Weapons = require(ReplicatedStorage.Source.Core.Gameplay.Weapons)

local Inventory = Knit.CreateController{
    Name = "Inventory";
    Controllers = {
        ["Player"] = "None";
    };
    Services = {
        ["LoadoutService"] = "None";
    };
    Assets = ReplicatedStorage:WaitForChild("Assets");
}

function Inventory:Equip(ItemType, Item)
    --// Call server manager to refresh loadout
    self.Services.LoadoutService:Equip(
        ItemType,
        Item
    ):await()
end

function Inventory:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end

    --// Sword equipping
    self.Services.LoadoutService.WeaponCreated:Connect(function(Weapon)
        --[[Weapon.Equipped:Connect(function()
            local WeaponAnimations = self.Assets.Swords:FindFirstChild(Weapon.Name).Info.Animations

            print(Weapon.Name)

            --// First destroy fake swords
            self.Controllers.Player:GetCharacter().Torso:FindFirstChild(Weapon.Name):Destroy()

            self.Controllers.Player:LoadAnimation(WeaponAnimations.Unsheathe):Play()
        end)--]]
        local Sword = Weapons.new(Weapon)
    end)

end


function Inventory:KnitInit()
    
end


return Inventory
