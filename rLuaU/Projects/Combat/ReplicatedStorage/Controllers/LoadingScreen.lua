local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit)

local LoadingScreen = Knit.CreateController{
    Name = "LoadingScreen";
    Customisation = nil;
    CharacterInfo = nil;
}

function LoadingScreen:Init()
    repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainMenu")
    local UI = game.Players.LocalPlayer.PlayerGui.MainMenu.Background
    UI.Parent.Enabled = true

    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    self.Customisation = Knit.GetController("Customisation")
    self.CharacterInfo = Knit.GetService("CharacterInfo")

    local i = 0
    while true do
        i += 0.08
        UI.One.Position = UDim2.fromScale(UI.One.Position.X.Scale, 0.954 + math.sin(i)/80)
        UI.Two.Position = UDim2.fromScale(UI.Two.Position.X.Scale, 0.954 + math.sin(i+1)/80)
        UI.Three.Position = UDim2.fromScale(UI.Three.Position.X.Scale, 0.954 + math.sin(i+2)/80)
        UI.Four.Position = UDim2.fromScale(UI.Four.Position.X.Scale, 0.954 + math.sin(i+3)/80)
        UI.Five.Position = UDim2.fromScale(UI.Five.Position.X.Scale, 0.954 + math.sin(i+4)/80)

        UI.One.BackgroundColor3 = Color3.fromRGB(111, 255, 123):Lerp(Color3.fromRGB(35, 80, 39), math.sin(i))
        UI.Two.BackgroundColor3 = Color3.fromRGB(111, 255, 123):Lerp(Color3.fromRGB(35, 80, 39), math.sin(i+1))
        UI.Three.BackgroundColor3 = Color3.fromRGB(111, 255, 123):Lerp(Color3.fromRGB(35, 80, 39), math.sin(i+2))
        UI.Four.BackgroundColor3 = Color3.fromRGB(111, 255, 123):Lerp(Color3.fromRGB(35, 80, 39), math.sin(i+3))
        UI.Five.BackgroundColor3 = Color3.fromRGB(111, 255, 123):Lerp(Color3.fromRGB(35, 80, 39), math.sin(i+4))

        if game:GetService("ContentProvider").RequestQueueSize == 0 then
            break 
        end

        task.wait(0.006)
    end
    task.wait(1)

    for i,v in pairs(UI:GetChildren()) do
        if v:IsA("Frame") then
            game:GetService("TweenService"):Create(
                v,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 1}
            ):Play()
        else
            game:GetService("TweenService"):Create(
                v,
                TweenInfo.new(0.5),
                {TextTransparency = 1}
            ):Play()
        end
    end
    task.wait(0.5)

    game:GetService("TweenService"):Create(
        UI.AEL,
        TweenInfo.new(1),
        {TextTransparency = 0}
    ):Play()
    game:GetService("TweenService"):Create(
        UI.AEL.UIScale,
        TweenInfo.new(1),
        {Scale = 1}
    ):Play()

    task.wait(1)


    local Circle = Instance.new("Frame", UI)
    Circle.AnchorPoint = Vector2.new(0.5, 0.5)
    Circle.Position = UDim2.fromScale(0.5, 0.5)
    Circle.Size = UDim2.fromOffset(5, 5)
    local UICorner = Instance.new("UICorner", Circle)
    UICorner.CornerRadius = UDim.new(1, 0)
    local Circle2 = Instance.new("Frame", UI)
    Circle2.AnchorPoint = Vector2.new(0.5, 0.5)
    Circle2.Position = UDim2.fromScale(0.5, 0.5)
    Circle2.Size = UDim2.fromOffset(5, 5)
    local UICorner2 = Instance.new("UICorner", Circle2)
    UICorner2.CornerRadius = UDim.new(1, 0)

    for i = 1, math.pi*1.5, 0.05 do
        local P = math.cos(i)
        local P2 = math.sin(i)
        local Radius = 150

        Circle.Position = UDim2.new(0.5, P*Radius, 0.5, P2*Radius)
        Circle2.Position = UDim2.new(0.5, -P*Radius, 0.5, -P2*Radius)

        local C1 = Circle:Clone()
        local C2 = Circle2:Clone()
        C1.Parent = UI C2.Parent = UI

        game:GetService("TweenService"):Create(C1, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        game:GetService("TweenService"):Create(C2, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        game:GetService("Debris"):AddItem(C1, 0.25)
        game:GetService("Debris"):AddItem(C2, 0.25)

        task.wait(0.008)
    end
    game:GetService("TweenService"):Create(Circle, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    game:GetService("TweenService"):Create(Circle2, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    game:GetService("TweenService"):Create(UI.AEL, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
    game:GetService("TweenService"):Create(
        UI.AEL.UIScale,
        TweenInfo.new(0.5),
        {Scale = 10}
    ):Play()
    task.wait(2)

    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    workspace.CurrentCamera.CFrame = workspace.P1.CFrame
    game.Lighting.MenuBlur.Enabled = true
    local Camera = game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(100), {CFrame = workspace.P2.CFrame})
    Camera:Play()

    game:GetService("TweenService"):Create(UI, TweenInfo.new(1), {ImageTransparency = 1}):Play()

    task.wait(1.5)
    local MainScreen = game.Players.LocalPlayer.PlayerGui.MainScreen
    game:GetService("TweenService"):Create(MainScreen.GameName, TweenInfo.new(1), {TextTransparency = 0}):Play()
    game:GetService("TweenService"):Create(MainScreen.GameName.UIScale, TweenInfo.new(1), {Scale = 1}):Play()

    task.wait(1)
    game:GetService("TweenService"):Create(MainScreen.AEL, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    game:GetService("TweenService"):Create(MainScreen.PressAnyKey, TweenInfo.new(1), {TextTransparency = 0}):Play()
    game:GetService("TweenService"):Create(MainScreen.Left, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    game:GetService("TweenService"):Create(MainScreen.Right, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    local StartRight = MainScreen.Right.Position.X.Scale
    local StartLeft = MainScreen.Left.Position.X.Scale

    local EndLoop = false
    local InputCatcher = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode.EnumType == Enum.KeyCode then
            EndLoop = true
        end
    end)

    local a = 0
    while true do
        task.wait(0.008)
        a+=0.08
        local sine = math.sin(a)
        MainScreen.Left.Position = UDim2.fromScale(StartLeft + sine/200 ,MainScreen.Left.Position.Y.Scale)
        MainScreen.Right.Position = UDim2.fromScale(StartRight - sine/200 ,MainScreen.Right.Position.Y.Scale)
        if EndLoop == true then
            InputCatcher:Disconnect();
            break
        end
    end

    self.CharacterInfo:HasCharacter():andThen(function(Value)
        if Value == false then
            task.wait(0.5)
            game:GetService("TweenService"):Create(MainScreen.Cover, TweenInfo.new(0.5), {Size = UDim2.fromScale(1, 1)}):Play()
            task.wait(1)
            self.Customisation:Start()
            MainScreen.Cover.AnchorPoint = Vector2.new(0, 0)
            MainScreen.Cover.Position = UDim2.fromScale(0, 0)
            game.Lighting.MenuBlur.Enabled = false
            game.Lighting.DepthOfField.Enabled = true
            Camera:Cancel()
            for i,v in pairs(MainScreen:GetChildren()) do
                if v.Name ~= "Cover" then
                    v.Visible = false
                end
            end
            MainScreen.Parent.Customisation.Enabled = true
            
            game:GetService("TweenService"):Create(MainScreen.Cover, TweenInfo.new(0.5), {Size = UDim2.fromScale(1, 0)}):Play()
        else
            game.Players.LocalPlayer.PlayerGui.Teleporting.Enabled = true
            game.Players.LocalPlayer.PlayerGui.MainScreen.Enabled = false
            game:GetService("TeleportService"):SetTeleportGui(game.Players.LocalPlayer.PlayerGui.Teleporting)
            self.CharacterInfo:MainGame()
        end
    end)
end

function LoadingScreen:KnitInit()
    print("[Knit] LoadingScreen controller initialised!")
end

return LoadingScreen