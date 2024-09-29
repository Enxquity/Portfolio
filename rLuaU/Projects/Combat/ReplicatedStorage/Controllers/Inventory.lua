local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local Inventory = Knit.CreateController{
    Name = "Inventory";
    Inventory = {};
    Inputs = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine};
    Conversion = {One = 1, Two = 2, Three = 3, Four = 4, Five = 5, Six = 6, Seven = 7, Eight = 8, Nine = 9}
}

function Inventory:Update()
    local Inv = Player.PlayerGui.Inventory.Inventory
    
    --// Clear inventory
    for i,v in pairs(Inv.ItemHolder:GetChildren()) do
        if not v:IsA("Frame") then continue end
        v:Destroy()
    end

    for i = 1, #self.Inventory do
        if i > 9 then break end
        if Inv.ItemHolder:FindFirstChild(self.Inventory[i].Name) then
            local Item = Inv.ItemHolder:FindFirstChild(self.Inventory[i].Name)
            local Quantity = tonumber(Item.Quantity.Text:split("x")[2])
            Item.Quantity.Text = "x" .. tostring(Quantity + 1)
            continue
        end
        local ClonedTemplate = ReplicatedStorage.GameAssets.UI.Item:Clone()
        ClonedTemplate.Parent = Inv.ItemHolder
        ClonedTemplate.Icon.Image = self.Inventory[i].TextureId
        ClonedTemplate.BackgroundTransparency = (self.Inventory[i].Parent:IsA("Model") and 0 or 0.5)
        ClonedTemplate.Name = self.Inventory[i].Name
    end
end

function Inventory:Init()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    for i,v in pairs(Player.Backpack:GetChildren()) do
        table.insert(self.Inventory, v)
    end

    Player.Backpack.ChildAdded:Connect(function(Child)
        if table.find(self.Inventory, Child) then
            return self:Update()
        end
        table.insert(self.Inventory, Child)
        self:Update()
    end)

    Player.Backpack.ChildRemoved:Connect(function(Child)
        if Child.Parent and Child.Parent:IsA("Model") then
            return self:Update()
        end
        table.remove(self.Inventory, table.find(self.Inventory, Child))
        self:Update()
    end)

    UserInputService.InputBegan:Connect(function(Input, IsTyping)
        if IsTyping then return end
        if table.find(self.Inputs, Input.KeyCode) then
            local Index = self.Conversion[tostring(Input.KeyCode):split(".")[3]]
            
            local Character = Player.Character
            if Index and Character and Character:FindFirstChild("Humanoid") then
                local Hum = Character:FindFirstChild("Humanoid")
                if self.Inventory[Index].Parent ~= Character then
                    Hum:UnequipTools()
                    Hum:EquipTool(self.Inventory[Index])
                else
                    Hum:UnequipTools()
                end
            end
        end
    end)

    self:Update()
end

function Inventory:KnitInit()
    print("[Knit] Inventory controller initialised!")
end


return Inventory