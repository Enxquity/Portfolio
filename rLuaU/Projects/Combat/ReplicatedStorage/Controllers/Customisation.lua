local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit)

local Customisation = Knit.CreateController{
    Name = "Customisation";
    Camera = workspace.CurrentCamera;
    CharacterUtils = nil;
    AccessoryManager = nil;
    CharacterInfo = nil;

    Colors = {};
    Customisation = {
        Hair1Index = 0;
        Hair2Index = 0;
        ShirtIndex = 1;
        LeggingsIndex = 1;
        EyesIndex = 1;
        MouthIndex = 1;

        Hair1Color = Color3.fromRGB(0, 0, 0);
        Hair2Color = Color3.fromRGB(0, 0, 0);

        ShirtColor = Color3.fromRGB(0, 0, 0);
        LeggingColor = Color3.fromRGB(0, 0, 0);
        
        SkinColor = Color3.fromRGB(198, 134, 66);
    };
    Clothes = {
        Shirts = {
            6333138482;
            5115093881;
            7308882311;
            5444948842;
            6046573768;
            5811638217;
        };
        Leggings = {
            7774302540;
            3088722716;
            218732806;
            4790137315;
            10536619694;
            5100708909;
        }
    };
    Face = {
        Eyes = {
            2801605712;
            2801594973;
            2801594656;
            2818161566;
            2801605956;
            2801605125;
            3523957747;
        };
        Mouths = {
            176217393;
            8668685265;
            8676206056;
            8668739002;
            178503660;
            3899634124;
            4522829985;
            12726338482;
        }
    }
}

--// Client side calls (promises)

function SortHue(colorA, colorB)
	local hA, sA, vA = Color3.toHSV(colorA)
	local hB, sB, vB = Color3.toHSV(colorB)
	return hA < hB
end

function Customisation:GetColorIndex(Color)
    for i,v in pairs(self.Colors) do
        if v == Color then
            return i
        end
    end
end

function Customisation:UpdateHair()
    local Async, Character = self.CharacterUtils:GetCharacter():await()
    if Character then
        --// Clear hairs
        for i,v in pairs(Character:GetChildren()) do
            if v.Name:lower():find("hair") then
                v:Destroy()
            end
        end

        --// Add first hair
        if self.Customisation.Hair1Index > 0 then
            local Hair = ReplicatedStorage.Hair:FindFirstChild("Hair" .. self.Customisation.Hair1Index)
            if Hair then
                self.AccessoryManager:AddAccessory(Hair):andThen(function(NewHair)
                    NewHair.Handle.Color = self.Customisation.Hair1Color
                    for i,v in pairs(NewHair:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Color = self.Customisation.Hair1Color
                        end
                    end
                end):catch(warn)
                game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Hair.Hair.Text = ("Hair" .. self.Customisation.Hair1Index)
                game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Color.Color.Text = BrickColor.new(self.Customisation.Hair1Color).Name
            end
        else
            game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Hair.Hair.Text = "Bald"
        end

        --// Add second hair
        if self.Customisation.Hair2Index > 0 then
            local Hair = ReplicatedStorage.Hair:FindFirstChild("Hair" .. self.Customisation.Hair2Index)
            if Hair then
                self.AccessoryManager:AddAccessory(Hair):andThen(function(NewHair)
                    NewHair.Handle.Color = self.Customisation.Hair2Color
                    for i,v in pairs(NewHair:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Color = self.Customisation.Hair2Color
                        end
                    end
                end):catch(warn)
                game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Hair.Hair.Text = ("Hair " .. self.Customisation.Hair2Index)
                game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Color.Color.Text = BrickColor.new(self.Customisation.Hair2Color).Name
            end
        else
            game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Hair.Hair.Text = "Bald"
        end
    end
end

function Customisation:UpdateSkin()
    local Async, Character = self.CharacterUtils:GetCharacter():await()
    if Character then
        for i,v in pairs(Character:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Color = self.Customisation.SkinColor
            end
        end
    end
end

function Customisation:UpdateClothes()
    local Async, Character = self.CharacterUtils:GetCharacter():await()
    local Shirt = self.Clothes.Shirts[self.Customisation.ShirtIndex]
    local Leggings = self.Clothes.Leggings[self.Customisation.LeggingsIndex]

    if Character then
        local ShirtInstance = Character:FindFirstChildWhichIsA("Shirt")
        local LeggingsInstance = Character:FindFirstChildWhichIsA("Pants")
        if not ShirtInstance then
            ShirtInstance = Instance.new("Shirt", Character)
        end
        if not LeggingsInstance then
            LeggingsInstance = Instance.new("Pants", Character)
        end

        if Shirt then
            ShirtInstance.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. Shirt
            ShirtInstance.Color3 = self.Customisation.ShirtColor
            game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Shirt.Shirt.Shirt.Text = "Shirt " .. self.Customisation.ShirtIndex
        end
        if Leggings then
            LeggingsInstance.PantsTemplate = "http://www.roblox.com/asset/?id=" .. Leggings
            LeggingsInstance.Color3 = self.Customisation.LeggingColor
            game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Leggings.Leggings.Leggings.Text = "Leggings " .. self.Customisation.LeggingsIndex
        end
    end
end

function Customisation:UpdateFace()
    local Async, Character = self.CharacterUtils:GetCharacter():await()
    local Eyes = self.Face.Eyes[self.Customisation.EyesIndex]
    local Mouth = self.Face.Mouths[self.Customisation.MouthIndex]

    if Character and Character:FindFirstChild("Head") then
        local Head = Character:FindFirstChild("Head")
        for i,v in pairs(Head:GetChildren()) do
            if v:IsA("Decal") then
                v:Destroy()
            end
        end
        
        local EyesDecal = Instance.new("Decal", Head)
        local MouthDecal = Instance.new("Decal", Head)

        EyesDecal.Texture = "rbxassetid://" .. Eyes
        MouthDecal.Texture = "rbxassetid://" .. Mouth
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Mouth.Mouth.Text = "Mouth " .. self.Customisation.MouthIndex
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Eyes.Eyes.Text = "Eyes " .. self.Customisation.EyesIndex
    end
end

function Customisation:Start()
    local Async, Character = self.CharacterUtils:GetCharacter():await()
    
    --// Adding colors to list
    repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation")
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Colors.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        table.insert(self.Colors, v.BackgroundColor3)
    end

    --// Sorting colors
    table.sort(self.Colors, SortHue)

    --// Setting sorted colors
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Colors.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        v.LayoutOrder = self:GetColorIndex(v.BackgroundColor3)
        v.MouseButton1Click:Connect(function()
            self.Customisation.Hair1Color = v.BackgroundColor3
            self:UpdateHair()
        end)
    end
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Colors.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        v.LayoutOrder = self:GetColorIndex(v.BackgroundColor3)
        v.MouseButton1Click:Connect(function()
            self.Customisation.Hair2Color = v.BackgroundColor3
            self:UpdateHair()
        end)
    end

    --// Skin color changer
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Skin.Colors.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        v.MouseButton1Click:Connect(function()
            self.Customisation.SkinColor = v.BackgroundColor3
            self:UpdateSkin()
        end)
    end

    --// Clothes color changers
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Shirt.Shirt.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        v.MouseButton1Click:Connect(function()
            self.Customisation.ShirtColor = v.BackgroundColor3
            self:UpdateClothes()
        end)
    end
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Leggings.Leggings.Holder:GetChildren()) do
        if not v:IsA("TextButton") then continue end
        v.MouseButton1Click:Connect(function()
            self.Customisation.LeggingColor = v.BackgroundColor3
            self:UpdateClothes()
        end)
    end

    --// Hair switcher
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Hair.Right.MouseButton1Click:Connect(function()
        if self.Customisation.Hair1Index == #ReplicatedStorage.Hair:GetChildren() then
            self.Customisation.Hair1Index = 0
        else
            self.Customisation.Hair1Index += 1
        end
        self:UpdateHair()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair1.Hair.Left.MouseButton1Click:Connect(function()
        if self.Customisation.Hair1Index == 0 then
            self.Customisation.Hair1Index = #ReplicatedStorage.Hair:GetChildren()
        else
            self.Customisation.Hair1Index -= 1
        end
        self:UpdateHair()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Hair.Right.MouseButton1Click:Connect(function()
        if self.Customisation.Hair2Index == #ReplicatedStorage.Hair:GetChildren() then
            self.Customisation.Hair2Index = 0
        else
            self.Customisation.Hair2Index += 1
        end
        self:UpdateHair()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Hair2.Hair.Left.MouseButton1Click:Connect(function()
        if self.Customisation.Hair2Index == 0 then
            self.Customisation.Hair2Index = #ReplicatedStorage.Hair:GetChildren()
        else
            self.Customisation.Hair2Index -= 1
        end
        self:UpdateHair()
    end)

    --// Clothes switcher
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Shirt.Shirt.Right.MouseButton1Click:Connect(function()
        if self.Customisation.ShirtIndex == #self.Clothes.Shirts then
            self.Customisation.ShirtIndex = 1
        else
            self.Customisation.ShirtIndex += 1
        end
        self:UpdateClothes()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Shirt.Shirt.Left.MouseButton1Click:Connect(function()
        if self.Customisation.ShirtIndex == 1 then
            self.Customisation.ShirtIndex = #self.Clothes.Shirts
        else
            self.Customisation.ShirtIndex -= 1
        end
        self:UpdateClothes()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Leggings.Leggings.Right.MouseButton1Click:Connect(function()
        if self.Customisation.LeggingsIndex == #self.Clothes.Leggings then
            self.Customisation.LeggingsIndex = 1
        else
            self.Customisation.LeggingsIndex += 1
        end
        self:UpdateClothes()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Clothing.Leggings.Leggings.Left.MouseButton1Click:Connect(function()
        if self.Customisation.LeggingsIndex == 1 then
            self.Customisation.LeggingsIndex = #self.Clothes.Leggings
        else
            self.Customisation.LeggingsIndex -= 1
        end
        self:UpdateClothes()
    end)

    --// Face switcher
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Eyes.Right.MouseButton1Click:Connect(function()
        if self.Customisation.EyesIndex == #self.Face.Eyes then
            self.Customisation.EyesIndex = 1
        else
            self.Customisation.EyesIndex += 1
        end
        self:UpdateFace()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Eyes.Left.MouseButton1Click:Connect(function()
        if self.Customisation.EyesIndex == 1 then
            self.Customisation.EyesIndex = #self.Face.Eyes
        else
            self.Customisation.EyesIndex -= 1
        end
        self:UpdateFace()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Mouth.Right.MouseButton1Click:Connect(function()
        if self.Customisation.MouthIndex == #self.Face.Mouths then
            self.Customisation.MouthIndex = 1
        else
            self.Customisation.MouthIndex += 1
        end
        self:UpdateFace()
    end)
    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Face.Face.Mouth.Left.MouseButton1Click:Connect(function()
        if self.Customisation.MouthIndex == 1 then
            self.Customisation.MouthIndex = #self.Face.Mouths
        else
            self.Customisation.MouthIndex -= 1
        end
        self:UpdateFace()
    end)

    self:UpdateHair()
    self:UpdateSkin()
    self:UpdateClothes()
    self:UpdateFace()

    --// Character rotation
    local TurnRight = false
    local TurnLeft = false
    local RotationSpeed = 0.01

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.TurnRight.MouseButton1Down:Connect(function()
        TurnRight = true
        while TurnRight == true do
            Character.PrimaryPart.CFrame *= CFrame.Angles(0, RotationSpeed, 0)
            RotationSpeed += 0.0002
            task.wait(0.005)
        end
    end)

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.TurnRight.MouseButton1Up:Connect(function()
        TurnRight = false
        RotationSpeed = 0.01
    end)

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.TurnLeft.MouseButton1Down:Connect(function()
        TurnRight = true
        while TurnRight == true do
            Character.PrimaryPart.CFrame *= CFrame.Angles(0, -RotationSpeed, 0)
            RotationSpeed += 0.0002
            task.wait(0.005)
        end
    end)

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.TurnLeft.MouseButton1Up:Connect(function()
        TurnRight = false
        RotationSpeed = 0.01
    end)

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Undo.MouseButton1Click:Connect(function()
        game:GetService("TweenService"):Create(
            Character.PrimaryPart,
            TweenInfo.new(0.3),
            {CFrame = workspace.Customisation.StandPart.CFrame + Vector3.new(0, Character.PrimaryPart.Size.Y + 1, 0)}
        ):Play()
    end)

    --// Finish

    game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Background.Finish.MouseButton1Click:Connect(function()
        game.Players.LocalPlayer.PlayerGui:FindFirstChild("Customisation").Enabled = false
		self.CharacterInfo:MakeCharacter({
			Shirt = self.Clothes.Shirts[self.Customisation.ShirtIndex];
			ShirtColor = {
				R = self.Customisation.ShirtColor.r;
				G = self.Customisation.ShirtColor.g;
				B = self.Customisation.ShirtColor.b;
			};

			Leggings = self.Clothes.Leggings[self.Customisation.LeggingsIndex];
			LeggingsColor = {
				R = self.Customisation.LeggingColor.r;
				G = self.Customisation.LeggingColor.g;
				B = self.Customisation.LeggingColor.b;
			};

			Eyes = self.Face.Eyes[self.Customisation.EyesIndex];
			Mouth = self.Face.Mouths[self.Customisation.MouthIndex];

			Hair1 = self.Customisation.Hair1Index;
			Hair1Color = {
				R = self.Customisation.Hair1Color.r;
				G = self.Customisation.Hair1Color.g;
				B = self.Customisation.Hair1Color.b;
			};

			Hair2 = self.Customisation.Hair2Index;
			Hair2Color = {
				R = self.Customisation.Hair2Color.r;
				G = self.Customisation.Hair2Color.g;
				B = self.Customisation.Hair2Color.b;
			};

			SkinColor = {
				R = self.Customisation.SkinColor.r;
				G = self.Customisation.SkinColor.g;
				B = self.Customisation.SkinColor.b;
			};
		}):await()
        self.CharacterInfo:MainGame()
        game.Players.LocalPlayer.PlayerGui.Teleporting.Enabled = true
        game.Players.LocalPlayer.PlayerGui.MainScreen.Enabled = false
        game:GetService("TeleportService"):SetTeleportGui(game.Players.LocalPlayer.PlayerGui.Teleporting)
    end)

    --// Init
    Character.PrimaryPart.CFrame = workspace.Customisation.StandPart.CFrame + Vector3.new(0, Character.PrimaryPart.Size.Y + 1, 0)
    Character.PrimaryPart.Anchored = true

    self.Camera.CameraType = Enum.CameraType.Scriptable
    self.Camera.CFrame = workspace.Customisation.CameraPart.CFrame
end


function Customisation:KnitInit()
    print("[Knit] Customisation controller initialised!")
end

function Customisation:KnitStart()
    self.CharacterUtils = Knit.GetService("CharacterUtils")
    self.AccessoryManager = Knit.GetService("AccessoryManager")
    self.CharacterInfo = Knit.GetService("CharacterInfo")
end

return Customisation