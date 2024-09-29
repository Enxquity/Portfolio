local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DatastoreService = require(ReplicatedStorage.Modules.Data.DatastoreService)
local ItemList = require(ReplicatedStorage:WaitForChild("Source").ItemList)

local Instancer = require(ReplicatedStorage.Source.External.Instancer)

Knit.AddServicesDeep(game:GetService("ServerStorage").Source)

Knit.Start():andThen(function()
    Players.PlayerAdded:Connect(function(Player)
        --// On character add we need to load in their profile avatar
        local JoinData = (RunService:IsStudio() and {Profile = 1} or Player:GetJoinData().TeleportData)
        local PlayerInstancer = Instancer.new()

        local LoadoutService = Knit.GetService("LoadoutService")

        Player.CharacterAdded:Connect(function(Character)
            local LoadedData = DatastoreService[Player]:Load()
            local ProfileSlot = DatastoreService[Player].Profiles[JoinData.Profile]

            if not ProfileSlot then
                Player:Kick("Failed to load profile slot")
                return
            end

            --// Add inventory data
            LoadoutService:LoadProfile(Player, ProfileSlot)

            --// Set head collision to false to make dashing look smoother
            local Head = Character:WaitForChild("Head")
            Head.CanCollide = false

            local ProfileCharacter = ItemList[ProfileSlot]
            local Shirt, Pants,
                  Eyes, Mouth,
                  Hair = ProfileCharacter.Shirt, ProfileCharacter.Pants, ProfileCharacter.Eyes, ProfileCharacter.Mouth, ProfileCharacter.Hair

            --// Destroy current face
            PlayerInstancer:FindAndDestroy(
                Character,
                "face"
            )

            --// Now apply these to the character
            local HairInstance = PlayerInstancer:CreateInstance(
                Hair,
                Character
            )
            HairInstance:FindFirstChild("Handle").Color = ProfileCharacter.Colors.Hair

            local ShirtInstance = PlayerInstancer:CreateInstance(
                "Shirt",
                Character,
                {
                    ShirtTemplate = Shirt;
                    Color3 = ProfileCharacter.Colors.Shirt
                }
            )

            local PantsInstance = PlayerInstancer:CreateInstance(
                "Pants",
                Character,
                {
                    PantsTemplate = Pants;
                    Color3 = ProfileCharacter.Colors.Pants
                }
            )

            local EyesInstance = PlayerInstancer:CreateInstance(
                "Decal",
                Character.Head,
                {
                    Texture = Eyes
                }
            )

            local MouthInstance = PlayerInstancer:CreateInstance(
                "Decal",
                Character.Head,
                {
                    Texture = Mouth
                }
            )

            --// Under roof detector
            local Params = RaycastParams.new()
            Params.FilterDescendantsInstances = {Character, workspace.Debris}
            Params.RespectCanCollide = true

            RunService.Heartbeat:Connect(function()
                local SunDirection = Lighting:GetSunDirection()

                local RayResult = workspace:Raycast(Character:GetPivot().Position, Vector3.yAxis * 2^16, Params)

                if RayResult then
                    Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
                else
                    Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                end
            end)
        end)
    end)

end):catch(warn)
