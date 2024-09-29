local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Buttons = Knit.CreateService {
    Name = "Buttons";
    Client = {}
}

function Buttons:Build(Button: Instance)
    local Building: Model = Button:FindFirstChildWhichIsA("Model")
    if Building then
        local EntityList: {Instance} = Building:GetChildren()
        table.sort(EntityList, function(A: Instance, B: Instance)
            return A.Position.Y < B.Position.Y
        end)
        for Iteration = 1, #EntityList do
            local Inst = EntityList[Iteration]
            Inst.Position += Vector3.yAxis * 2

            TweenService:Create(Inst, TweenInfo.new(0.5), {Position = Inst.Position - Vector3.yAxis*2, Transparency = Inst:GetAttribute("Transparency")}):Play()
            Inst.CanCollide = Inst:GetAttribute("CanCollide")
            task.wait(0.1)
        end
    end
end

function Buttons:OnStep(Player: Player, Button: Instance)
    if Button:GetAttribute("Purchased") == true then return end
    local Price: number = Button:GetAttribute("Price")
    local Money: IntValue = Player:FindFirstChild("leaderstats").Money

    if Money.Value >= Price then
        Money.Value -= Price
        Button:SetAttribute("Purchased", true)
        Button.PrimaryPart:FindFirstChildWhichIsA("BillboardGui"):Destroy()
        TweenService:Create(Button.PrimaryPart, TweenInfo.new(0.5), {Transparency = 1}):Play()

        local Building: Model = Button:FindFirstChildWhichIsA("Model")
        if Building and Building:FindFirstChild("Booster") then
            local Booster: Instance = Building:FindFirstChild("Booster")
            local BoosterButton: number = Booster:GetAttribute("Button")
            local BoosterStrictName: string = Booster:GetAttribute("StrictName")
            local BoosterChanges: {any} = Booster:GetAttributes()

            BoosterChanges["StrictName"] = nil
            BoosterChanges["Button"] = nil
            local BButton: Instance = Button.Parent:FindFirstChild("Button" .. BoosterButton)
            if BButton then
                for _, Inst in pairs(BButton:GetDescendants()) do
                    if not Inst:IsA("BasePart") then continue end
                    if BoosterStrictName ~= nil and BoosterStrictName ~= "" and Inst.Name ~= BoosterStrictName then continue end
                    for Change, NewValue in pairs(BoosterChanges) do
                        if Inst:GetAttributes()[Change] then
                            Inst:SetAttribute(Change, NewValue)
                        end
                    end
                end
            end
        end

        self:LoadButtons(Button.Parent.Parent)
        self:Build(Button)
    end
end

function Buttons:LoadButtons(Tycoon: Instance)
    for i = 1, #Tycoon.Buttons:GetChildren() do
        local Button:Instance = Tycoon.Buttons:FindFirstChild("Button" .. i)
        if Button then
            if Button:GetAttribute("Purchased") == true then
                continue
            end
            
            local HasRequired: boolean = true
            for _, RButton in pairs(Button:GetAttribute("RequiredButtons"):split(",")) do
                if RButton == "" then continue end
                local FoundButton: Instance = Tycoon.Buttons:FindFirstChild("Button" .. RButton)
                if FoundButton then
                    if FoundButton:GetAttribute("Purchased") == true then
                        HasRequired = true
                    else
                        HasRequired = false
                        break
                    end
                else
                    HasRequired = false
                    break
                end
            end
            if HasRequired == false then
                continue
            end

            TweenService:Create(Button.PrimaryPart, TweenInfo.new(0.5), {Transparency = 0}):Play()
            if not Button.PrimaryPart:FindFirstChildWhichIsA("BillboardGui") then
                local BGui: BillboardGui = ReplicatedStorage.GameAssets.UI.Button:Clone()
                BGui.BName.Text = Button:GetAttribute("Name")
                BGui.BPrice.Text = '<font color="#3eff34">$</font>' .. Button:GetAttribute("Price")

                BGui.Parent = Button.PrimaryPart
            end
            Button.PrimaryPart.Touched:Connect(function(Hit)
                local TouchPlayer: Player = Players:GetPlayerFromCharacter(Hit.Parent)

                if TouchPlayer and TouchPlayer == Players:FindFirstChild(Tycoon:GetAttribute("Owner")) then
                    self:OnStep(Players:FindFirstChild(Tycoon:GetAttribute("Owner")), Button)
                end
            end)
        else
            break   
        end
    end
end 

function Buttons:KnitStart()
    
end


function Buttons:KnitInit()
    
end


return Buttons
