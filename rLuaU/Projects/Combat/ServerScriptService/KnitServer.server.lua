local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService('ServerStorage');

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddServices(ServerStorage.Source.Services)

Knit.Start():andThen(function()
    local CharacterInfo = Knit.GetService("CharacterInfo")

    --// Load Character on spawn
    game.Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(Character)
            --// Actually load it
            CharacterInfo:LoadData(Player);
            local CharacterData = CharacterInfo:GetCharacterData(Player)

            local Shirt = Instance.new("Shirt", Character)
            local Leggings = Instance.new("Pants", Character)
            
            Shirt.ShirtTemplate = "rbxassetid://" .. CharacterData.Shirt
            Shirt.Color3 = Color3.new(CharacterData.ShirtColor.R, CharacterData.ShirtColor.G, CharacterData.ShirtColor.B)
            Leggings.PantsTemplate = "rbxassetid://" .. CharacterData.Leggings
            Leggings.Color3 = Color3.new(CharacterData.LeggingsColor.R, CharacterData.LeggingsColor.G, CharacterData.LeggingsColor.B)

            local Hair1 = ReplicatedStorage.Hair:FindFirstChild("Hair" .. CharacterData.Hair1):Clone()
            local Hair2 = ReplicatedStorage.Hair:FindFirstChild("Hair" .. CharacterData.Hair2):Clone()
            Hair1.Parent = Character Hair2.Parent = Character
            
            for i,v in pairs(Hair1:GetDescendants()) do
                if v:IsA("BasePart") then v.Color = Color3.new(CharacterData.Hair1Color.R, CharacterData.Hair1Color.G, CharacterData.Hair1Color.B) end
            end
            for i,v in pairs(Hair2:GetDescendants()) do
                if v:IsA("BasePart") then v.Color = Color3.new(CharacterData.Hair2Color.R, CharacterData.Hair2Color.G, CharacterData.Hair2Color.B) end
            end

            local Eyes = Instance.new("Decal", Character.Head)
            local Mouth = Instance.new("Decal", Character.Head)
            Eyes.Texture = "rbxassetid://" .. CharacterData.Eyes
            Mouth.Texture = "rbxassetid://" .. CharacterData.Mouth

            for i,v in pairs(Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Color = Color3.new(CharacterData.SkinColor.R, CharacterData.SkinColor.G, CharacterData.SkinColor.B)
                end
            end

            Character.Parent = workspace.Players
            for i,v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CollisionGroup = "Characters"
                end
            end
        end)
    end)
end):catch(warn)
