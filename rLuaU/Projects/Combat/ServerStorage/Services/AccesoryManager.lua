local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit)

local Accessory = Knit.CreateService{
    Name = "AccessoryManager";
    Client = {};
}

function Accessory.Client:AddAccessory(Player, Item)
    return self.Server:AddAccessory(Player, Item)
end

function Accessory:AddAccessory(Player, AccessoryItem)
    local Char = Player.Character
    if AccessoryItem:IsA("Accessory") and Char then
        local Cloned = AccessoryItem:Clone()
        Cloned.Parent = Char
        return Cloned
    end
end

function Accessory:KnitInit()
    print("[Knit] Acessory service initialised!")
end

return Accessory