local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Players.LocalPlayer

local UI = Knit.CreateController { 
    Name = "UI";
    Controllers = {
        ["External"] = "None";
    };
    Effects = {};
    LastCache = {};
}

function UI:GetPlayerGui()
    return Player:WaitForChild("PlayerGui")
end

function UI:GetInterface(InterfaceName)
    local PlayerGui = self:GetPlayerGui()
    return PlayerGui:FindFirstChild(InterfaceName)
end

function UI:WaitForInterface(InterfaceName)
    return self:GetPlayerGui():WaitForChild(InterfaceName)
end

function UI:BringFromBottom(Asset, Info)
    local CacheAssetPosition = Asset.Position

    Asset.Position = UDim2.fromScale(
        CacheAssetPosition.X.Scale,
        1.2
    )
    local Tween = TweenService:Create(
        Asset,
        Info or TweenInfo.new(0.5),
        {
            Position = CacheAssetPosition
        }
    )

    Tween:Play()
    Tween.Completed:Wait()
end

function UI:BringToBottom(Asset, Info)
    local CacheAssetPosition = Asset.Position

    local Tween = TweenService:Create(
        Asset,
        Info or TweenInfo.new(0.5),
        {
            Position = UDim2.fromScale(
                CacheAssetPosition.X.Scale,
                1.2
            );
        }
    )

    Tween:Play()
    Tween.Completed:Wait()

    Asset.Position = CacheAssetPosition
end

function UI:Enable()
    for _, Object in self.LastCache do
        Object.Enabled = true
    end
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
end

function UI:Disable()
    self.LastCache = {}
    for _, Object in Player.PlayerGui:GetChildren() do
        if Object.Enabled == false or Object:GetAttributes()["Resistance"] == true then continue end
        table.insert(
            self.LastCache,
            Object
        )
        Object.Enabled = false
    end
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

--// Fade class
function UI:NewFader(DefaultTransparency: number, CustomInterface: {Object: ScreenGui, Init: (Object: ScreenGui) -> ()})
    if self.Instancer == nil then
        repeat task.wait() until self.Instancer ~= nil
    end
    local Fader = {
        Object = CustomInterface and self.Instancer:CreateInstance(
            CustomInterface.Object,
            Player.PlayerGui,
            {
                IgnoreGuiInset = true;
                DisplayOrder = 2^16;
            }
        ):GetRawObject()
        or self.Instancer:CreateInstance(
            "ScreenGui",
            Player.PlayerGui,
            {
                IgnoreGuiInset = true;
                DisplayOrder = 2^16;
            },
                --// Children
                {
                    "Frame",
                    {
                        Size = UDim2.fromScale(1, 1);
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25);
                        BackgroundTransparency = DefaultTransparency or 0;
                    }
                }
        ):GetRawObject();
        InitFunc = CustomInterface and CustomInterface.Init or nil;

        Fade = function(self, Transparency)
            local Asset = self.Object:FindFirstChildWhichIsA("Frame") or self.Object:FindFirstChildWhichIsA("ImageLabel")
            local Argument = Asset:IsA("Frame") and "BackgroundTransparency" or "ImageTransparency"

            local Tween = TweenService:Create(
                Asset,
                TweenInfo.new(0.5),
                {
                    [Argument] = Transparency;
                }
            )
            Tween:Play()
            return {
                Await = function()
                    Tween.Completed:Wait()
                end
            }
        end;

        In = function(self)
            return self:Fade(1)
        end;

        Out = function(self)
            return self:Fade(0)
        end;

        Init = function(self)
            if self.InitFunc ~= nil then
                for _, Asset: Frame & ImageLabel & GuiButton  in self.Object:GetDescendants() do
                    local MainAsset = self.Object:FindFirstChildWhichIsA("Frame") or self.Object:FindFirstChildWhichIsA("ImageLabel")
                    local Argument = MainAsset:IsA("Frame") and "BackgroundTransparency" or "ImageTransparency"
                    local LinkerArgument = Asset:IsA("Frame") and "BackgroundTransparency" or "ImageTransparency"

                    UI.Instancer:Wrap(Asset):Link(
                        MainAsset,
                        false,
                        false,
                        {
                            [LinkerArgument] = Argument
                        }
                    )
                end
                self.InitFunc(
                    self.Object
                )
            end
        end
    }
    Fader.Object:SetAttribute("Resistance", true)
    Fader:Init()

    return Fader
end

--// Add UI Effects
function UI:AddPulse(Asset: GuiBase, Property: string)
    self.Effects[Asset] = {
        ApplicationTime = tick();
        ApplicationProperty = Property;
        ApplicationType = "Pulse";
    }
end

function UI:AddRotator(Asset: GuiBase)
    self.Effects[Asset] = {
        ApplicationTime = tick();
        ApplicationProperty = "Rotation";
        ApplicationType = "Rotator";
    }
end

function UI:AddSpriteMap(Asset: ImageLabel, Map: {string}, Speed: number)
    local NewList = {}
    for Index, Sprite in Map do
        local NewSprite = self.Instancer:CreateInstance(
            Asset,
            Asset.Parent,
            {
                Image = Sprite;
                Visible = true;
                ImageTransparency = 0.999;
            }
        )

        NewSprite:Link(Asset.Parent, false, false, {
            ImageTransparency = "ImageTransparency"
        })

        NewList[Index] = NewSprite:GetRawObject()
    end
    Asset.Visible = false

    --// Preload sprite map assets
    ContentProvider:PreloadAsync(NewList, function(...)

    end)

    self.Effects[Asset] = {
        ApplicationTime = tick();
        ApplicationCurrentFrame = 1;
        ApplicationType = "SpriteMap";
        ApplicationSprites = NewList;
        ApplicationSpeed = Speed or 1;
    }
end

--// Render UI Effects
function UI:Render()
    for EffectAsset, EffectDetails in self.Effects do
        --// Erase objects that aren't present no more since we aren't using a weak table
        if not EffectAsset:IsDescendantOf(game) then
            table.remove(
                self.Effects,
                table.find(
                    self.Effects,
                    EffectAsset
                )
            )
        end

        --// Optimisation to prevent unecessary calculations being made
        if EffectAsset.Visible == false and EffectDetails.ApplicationType ~= "SpriteMap" then
            continue
        end

        --// Pulse effect
        if EffectDetails.ApplicationType == "Pulse" then
            local Transparency = math.abs(
                math.sin(
                    tick() - EffectDetails.ApplicationTime
                ) * 0.6
            )

            EffectAsset[EffectDetails.ApplicationProperty] = Transparency
        end

        --// Rotator effect
        if EffectDetails.ApplicationType == "Rotator" then
                
        end

        --// Sprite effect
        if EffectDetails.ApplicationType == "SpriteMap" then
            if (tick() - EffectDetails.ApplicationTime) >= (2 ^ -EffectDetails.ApplicationSpeed) then
                EffectDetails.ApplicationCurrentFrame = ((EffectDetails.ApplicationCurrentFrame) % #EffectDetails.ApplicationSprites) + 1
                EffectDetails.ApplicationTime = tick()
            end

            for _, Sprite in EffectDetails.ApplicationSprites do
                Sprite.Visible = false
            end
            
            EffectDetails.ApplicationSprites[EffectDetails.ApplicationCurrentFrame].Visible = true
        end

    end
end

function UI:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    --// Create instancer
    self.Instancer = self.Controllers["External"]:Load("Instancer").new()

    RunService.RenderStepped:Connect(function()
        self:Render()
    end)
end


function UI:KnitInit()
    
end


return UI
