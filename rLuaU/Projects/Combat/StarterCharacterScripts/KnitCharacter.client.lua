local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Player = game:GetService("Players").LocalPlayer;

local Knit = require(ReplicatedStorage.Packages.Knit)
local Keybinds = require(ReplicatedStorage.Source.Keybinds)
local Key = require(ReplicatedStorage.ExternalModules.Key)
Knit.AddControllersDeep(ReplicatedStorage.Source.Controllers)

--// Controllers
local CameraController = Knit.GetController("Camera")
local UIController = Knit.GetController("UI")
local Customisation = Knit.GetController("Customisation")
local Movement = Knit.GetController("Movement")
local LoadingScreen = Knit.GetController("LoadingScreen")
local TeleportClient = Knit.GetController("TeleportClient")
local Inventory = Knit.GetController("Inventory")

--// On death
repeat task.wait() until Player.Character
Player.Character.Humanoid.Died:Connect(function()
    local Camera = workspace.CurrentCamera
    CameraController.CameraToggled = false
    Camera.CameraType = Enum.CameraType.Scriptable

    task.wait(0.25)

    local i = 0.001
    local StartPos = Camera.CFrame
    while task.wait() do
        i += 0.0025
        local Pos = Player.Character.Torso.Position + Vector3.new(0, 20, 0)
        Camera.CFrame = StartPos:Lerp(CFrame.lookAt(Pos, Player.Character.Torso.Position) * CFrame.Angles(0, 0, -math.pi/2), TweenService:GetValue(i, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut))
        if i >= 1 then
            break
        end
    end
    
    local Particles = {}
    for i,v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("Decal") then
            TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Transparency = 1}):Play()
            continue
        end
        if not v:IsA("BasePart") then continue end
        local CloneParticle = ReplicatedStorage.GameAssets.VFX.Particles.Death:Clone()
        CloneParticle.Parent = v

        table.insert(Particles, CloneParticle)

        --task.delay(0.5, function()
            TweenService:Create(v, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Transparency = 1}):Play()
        --end)
    end

    task.wait(3)
    for i,v in pairs(Particles) do
        v.Enabled = false
    end
    task.wait(Particles[1].Lifetime.Max)
    Particles = nil

    TweenService:Create(Player.PlayerGui.HUD.Death.Black, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    Camera.CameraType = Enum.CameraType.Custom
    
    
    TweenService:Create(Player.PlayerGui.HUD.Death.Black, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
end)
