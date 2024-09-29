local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Instancer = require(ReplicatedStorage.Source.External.Instancer)

type Chestplate = {
    Health: number,
    Defense: number
}
type Leggings = {
    Health: number,
    Defense: number
}

type Sword = {
    Damage: number
}

type Accessory = {
    Health: number,
    Defense: number,
    Damage: number
}

type Loadout = {
    Sword: {
        Name: string;
        Stats: Sword
    },
    Armour: {
        Chestplate: {
            Name: string;
            Stats: Chestplate;
        },
        Leggings: {
            Name: string;
            Stats: Leggings;
        }
    },
    Accesories: {
        [string]: Accessory
    },
    Items: {
        {
            Item: string;
        } 
    }
}

type Inventory = {
    Swords: {
        [string]: Sword
    };
    Armour: {
        Chestplates: {
            [string]: Chestplate
        };
        Leggings: {
            [string]: Leggings   
        };
    };
    Accessories: {
        [string]: Accessory
    };
}

local LoadoutService = Knit.CreateService {
    Name = "LoadoutService",
    Client = {
        WeaponCreated = Knit.CreateSignal();
    },
    Services = {
        ["CharacterUtils"] = "None";
    };
    PlayerInventories = {};
    PlayerLoadouts = {};
    Assets = ReplicatedStorage:WaitForChild("Assets");
}

function LoadoutService.Client:Equip(Player, ItemType, Item)
    return self.Server:Equip(Player, ItemType, Item)
end

function LoadoutService:LoadProfile(Player, Profile)
    local Inventory: Inventory = Profile["Inventory"] or {Swords = {}, Armour = {Chestplates = {}; Leggings = {};}, Accessories = {};}
    local Loadout: Loadout = Profile["Loadout"] or {Sword = {Name = "Katana"; Damage = 50;}, Armour = {Chestplate = {}, Leggings = {};}, Accessories = {};}

    self.PlayerInventories[Player] = Inventory
    self.PlayerLoadouts[Player] = Loadout 

    self:UpdateCharacter(
        Player,
        Loadout
    )
end

function LoadoutService:Equip(Player, ItemType: string, Item: string)
    local Inventory: Inventory = self.PlayerInventories[Player]
    if Inventory then
        self.PlayerLoadouts[Player][ItemType] = Item
    else
        warn(`The inventory for {Player.Name} is not loaded!`)
    end
    self:UpdateCharacter(
        Player, 
        self.PlayerLoadouts[Player] :: Loadout
    )
end

function LoadoutService:UpdateCharacter(Player: Player, Loadout : Loadout, Equipped: boolean)
    local Character = self.Services.CharacterUtils:GetCharacter(Player)
    local Sword = self.Assets.Swords:FindFirstChild(Loadout.Sword.Name)

    if Character and Sword then
        local IsReplacement = Character.Torso:FindFirstChild(Loadout.Sword.Name)

        if Equipped then
            IsReplacement:Destroy()
            return
        end

        if not IsReplacement then
            local NewSword = self.Instancer:CreateInstance(Sword:FindFirstChild("Handle"), Character.Torso, {
                Name = Sword.Name
            })
            Character.Torso.SwordWeld.Part1 = NewSword:GetRawObject()
            Character.Torso.SwordWeld.C1 = Sword.Info.Unequipped.Value
        end
    end

    self:UpdateBackpack(Player, Loadout)
end

function LoadoutService:UpdateBackpack(Player: Player, Loadout : Loadout)
    if Loadout["Sword"] then
        local Backpack = Player.Backpack

        if not Backpack:FindFirstChild(Loadout.Sword.Name) then
            local NewSword = self.Instancer:CreateInstance(self.Assets.Swords:FindFirstChild(Loadout.Sword.Name), Backpack, {
                Name = Loadout.Sword.Name
            })
            self.Client.WeaponCreated:Fire(
                Player, 
                NewSword:GetRawObject()
            )

            --// Server equipped & unequipped listener
            NewSword.Equipped:Connect(function()
                self:UpdateCharacter(Player, Loadout, true)
            end)

            NewSword.Unequipped:Connect(function()
                self:UpdateCharacter(Player, Loadout)
            end)
        end

        return
    end
end

function LoadoutService:KnitStart()
    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end

    self.Instancer = Instancer.new()
end


function LoadoutService:KnitInit()
    
end


return LoadoutService
