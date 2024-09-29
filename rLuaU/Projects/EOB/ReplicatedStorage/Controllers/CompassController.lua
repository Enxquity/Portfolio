local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CompassController = Knit.CreateController{
    Name = "Compass";
    Controllers = {
        ["External"] = "None";
        ["UI"] = "None";
        ["Camera"] = "None";
    };
    Directions = {
        [1] = "N";
        [2] = "E";
        [3] = "S";
        [4] = "W";
    };
    Needles = {};
    Tweens = {};
    Markers = {};

    Compass = nil;
    CachedRotation = 0;
}

function CompassController:Update()
    local CameraX, CameraY, CameraZ = workspace.CurrentCamera.CFrame:ToOrientation()
    local DegY = math.deg(CameraY)

    for _, Needle in self.Needles do
        local Object = Needle[1]
        local OriginalPos = Needle[2]

        --[[if math.abs(self.CachedRotation - DegY) > 350 then
            for _, Tween in self.Tweens do
                Tween:Cancel()
            end
            self.Tweens = {}

            Object.Position = OriginalPos + UDim2.fromScale(DegY / 180, 0)
        else
            local Index = #self.Tweens + 1
            self.Tweens[Index] = TweenService:Create(
                Object,
                TweenInfo.new(
                    (
                        0.1
                    )
                ),
                {
                    Position = OriginalPos + UDim2.fromScale(DegY / 180, 0)
                }
            )

            self.Tweens[Index]:Play()
        end--]]
        Object.Position = OriginalPos + UDim2.fromScale(DegY / 180, 0)

        Object.BackgroundTransparency = (
            math.abs(
                0.5 - Object.Position.X.Scale
            ) * 1.5
        ) --// Find distance between center (0.5 and the current object)
    end

    for _, Marker in self.Markers do
        local Orientation = self.Controllers.Camera:AngleToPart(Marker.Instance)

        Marker.Object.Position = UDim2.fromScale(0.5, 0.35) - UDim2.fromScale(
            math.clamp(
                (Orientation / 180) * 2,
                -0.5,
                0.5
            )
        )
    end

    --self.CachedRotation = DegY
end

function CompassController:MakeIndicator(Direction, Multi)
    local Indicator = self.Instancer:CreateInstance(
        "TextLabel",
        self.Compass,
        {
            AnchorPoint = Vector2.new(
                0.5,
                0.5
            );
            Size = UDim2.fromScale(
                0.07 / 1.5,
                0.56 / 1.5
            );
            Position = UDim2.fromScale(
                0.5 * Multi,
                0.75
            );
            BackgroundTransparency = 1;
            TextColor3 = Color3.fromRGB(194, 158, 106);
            Text = Direction;
            TextScaled = true;
        }
    )

    local Needle = self.Instancer:CreateInstance(
        "Frame",
        self.Compass,
        {
            AnchorPoint = Vector2.new(
                0.5,
                0
            );
            Size = UDim2.new(
                0,
                2, --// 2 on X offset
                0.3,
                0
            );
            Position = UDim2.fromScale(
                0.5 * Multi,
                0.225
            );
            BorderSizePixel = 0;
            BackgroundColor3 = Color3.fromRGB(194, 158, 106);
        }
    )

    Indicator:Link(
        Needle:GetRawObject(),
        true, false,
        {
            ["BackgroundTransparency"] = "TextTransparency"
        }
    )

    table.insert(
        self.Needles, 
        {
            Needle:GetRawObject(),
            Needle.Position
        }
    )

    return Indicator, Needle
end

function CompassController:MicroNeedle(Origin, Amount)
    local Position = Origin.Position

    for Index = 1, Amount do
        local MicroNeedle = self.Instancer:CreateInstance(
            "Frame",
            self.Compass,
            {
              AnchorPoint = Vector2.new(
                  0.5,
                  0
              );
              Size = UDim2.new(
                  0,
                  2, --// 2 on X offset
                  (Index == Amount / 2 and 0.25 or 0.15), --// Language server has an error but this does work for luau
                  0
              );
              Position = UDim2.fromScale(
                  Position.X.Scale + (0.45 / Amount) * Index, --// Distance between each is 0.5 so we have to split it into equal portions
                  Position.Y.Scale
              );
              BorderSizePixel = 0;
              BackgroundColor3 = Color3.fromRGB(194, 158, 106);
            }
        )

        table.insert(
            self.Needles, 
            {
                MicroNeedle:GetRawObject(),
                MicroNeedle.Position
            }
        )
    end
end

function CompassController:AddMarker(Identifier, Instance)
    self.Markers[Identifier] = {
        Object = self.Instancer:CreateInstance(
            "ImageLabel",
            self.Compass,
            {
                AnchorPoint = Vector2.new(
                    0.5,
                    0
                );
                Size = UDim2.fromScale(
                    0.05/0.75,
                    0.4/0.75
                );
                Rotation = 90;
                BackgroundTransparency = 1;
                Name = "Marker";
                Image = "rbxassetid://18627783613";
            }
        ):GetRawObject();
        Instance = Instance;
    }
end

function CompassController:RemoveMarker(Identifier)
    self.Markers[Identifier] = nil
end

function CompassController:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
    --// Create instancer
    self.Instancer = self.Controllers.External:Load("Instancer").new()

    --// Add needles
    local CompassHolder = self.Controllers.UI:WaitForInterface("Compass").Holder
    self.Compass = CompassHolder

    for Index = -#self.Directions, #self.Directions do
        if Index == 0 then continue end
        local Direction = self.Directions[Index > 0 and Index or math.abs(Index)]
        local Multi = (
            Index < 0 
                and -(Index + #self.Directions)
            or Index
        )

        local Indicator, Needle = self:MakeIndicator(Direction, Multi)
        self:MicroNeedle(Needle, 10)
    end

    --// Add first to end and last to start
    self:MakeIndicator(self.Directions[#self.Directions], -#self.Directions)
    self:MakeIndicator(self.Directions[1], #self.Directions+1)

    RunService.RenderStepped:Connect(function(DT)
        --debug.profilebegin("CompassRender")
        self:Update()
        --debug.profileend()
    end)
end


function CompassController:KnitInit()
    
end


return CompassController