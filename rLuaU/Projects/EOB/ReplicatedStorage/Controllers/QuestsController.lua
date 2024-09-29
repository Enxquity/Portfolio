local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Quests = Knit.CreateController { 
    Name = "Quests";
    Quests = {};

    Controllers = {
        ["Cursor"] = "None";
        ["UI"] = "None";
        ["Player"] = "None";
        ["Camera"] = "None";
        ["Movement"] = "None";
        ["Sound"] = "None";
        ["External"] = "None";
        ["ToolTip"] = "None";
        ["Proximity"] = "None";
        ["VoiceLines"] = "None";
        ["Compass"] = "None";
    };

    Services = {
        ["QuestService"] = "None";
    };

    InQuestDialogue = false;
    Instancer = "None";
}
local Player = game.Players.LocalPlayer

function Quests:WriteLore(Text)
    local QuestUI = self.Controllers.UI:GetInterface("Dialogue").Holder
    local RawText = Text.Value

    --// Disable click
    QuestUI.Click.Visible = false

    --// Check whether we have voice lines
    local VoiceLine = Text:FindFirstChildWhichIsA("Sound")
    if VoiceLine then
        VoiceLine:Play()
    end

    local SmartSpeech = {
        [","] = 0.37;
        ["."] = 0.4;
    }
    for LetterIndex = 1, #RawText do
        if LetterIndex >= math.floor(#RawText/4) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            break
        end

        local CurrentLetter = RawText:sub(
            LetterIndex, 
            LetterIndex
        )
        local CurrentText = RawText:sub(
            1,
            LetterIndex
        )

        QuestUI.Label.Text = CurrentText

        if SmartSpeech[CurrentLetter] then
            task.wait(SmartSpeech[CurrentLetter])
        else
            task.wait(0.035)
        end
    end

    --// Make sure everything is voila
    QuestUI.Label.Text = RawText
    if VoiceLine then
        VoiceLine:Stop()
    end

    --// Little wait to polish things out
    task.wait(1)

    --// Once written we need to wait for mouse input
    QuestUI.Click.Visible = true
    repeat 
        task.wait()
    until UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

function Quests:RunActions(ActionFolder)
    local QuestValues = ActionFolder.Parent
    for _, Action in ActionFolder:GetChildren() do
        local ActionType = Action.Name
        local ActionValue = Action:FindFirstChildWhichIsA("ValueBase").Value

        if ActionType == "EnablePrompt" then
            self.Controllers.Proximity:GetPrompt(ActionValue).Enabled = true
        end

        if ActionType == "PlayVoiceline" then
            self.Controllers.VoiceLines:Play(ActionValue)
        end

        if ActionType == "AddMarker" then
            self.Controllers.Compass:AddMarker(
                QuestValues.QuestName.Value,
                ActionValue
            )
        end

        if ActionType == "RemoveMarker" then
            self.Controllers.Compass:RemoveMarker(
                ActionValue
            )
        end
    end
end

function Quests:HasQuest(QuestName)
    local Quests = Player:FindFirstChild("Quests")
    if Quests then
        for _, Quest in Quests:GetChildren() do
            if Quest.Value == QuestName then
                return true
            end
        end
    end
    return false
end

function Quests:Interact(Giver)
    local QuestInfo = self.Quests[Giver.Name]

    if QuestInfo and self.InQuestDialogue == false then
        local QuestUI = self.Controllers.UI:GetInterface("Dialogue").Holder
        local QuestGiverUI = self.Controllers.UI:GetInterface("QuestDialogue") 


        self.InQuestDialogue = true
        self.Controllers.Cursor:DisableHover()
        self.Controllers.Camera:SetTarget(Giver)

        self.Controllers.Movement:Disable()
        self.Controllers.Player:MoveTo(
            Giver.PrimaryPart.Position + Giver.PrimaryPart.CFrame.LookVector * 5
        )
        self.Controllers.Movement:PivotAt(Giver)

        QuestUI.Parent.Enabled = true
        QuestUI.Click.Visible = false
        QuestUI.NPC.Text = Giver.Name
        QuestUI.Label.Text = ""

        self.Controllers.UI:BringFromBottom(QuestUI)

        --// Silence
        self.Controllers.Sound:Silence()

        local HasQuest = self:HasQuest(Giver.QuestValues.QuestName.Value)
        if HasQuest then
            self:WriteLore(Giver.QuestValues.QuestIncomplete)
        else
            local Lore = Giver.QuestValues.Lore:GetChildren()
            for Index = 1, #Lore do
                local LoreInstance = Lore[Index]
                self:WriteLore(LoreInstance)
            end
        end

        --// Reverse
        self.Controllers.Sound:Reverse()

        self.Controllers.UI:BringToBottom(QuestUI)
        self.Controllers.Movement:Enable()
        self.Controllers.Camera:SetTarget()

        QuestUI.Parent.Enabled = false

        if HasQuest then
            self.Controllers.Cursor:EnableHover()
            self.InQuestDialogue = false
            return
        end

        self:UpdateGiver(Giver)

        if Giver.QuestValues.Mandatory.Value == false then
            QuestGiverUI.Enabled = true
        else
            self:RunActions(Giver.QuestValues.QuestActions)
            self.Services.QuestService:ClaimQuest(Giver)
            self.Controllers.Cursor:EnableHover()
            self.InQuestDialogue = false
        end
    end
end

function Quests:UpdateGiver(Giver)
    local QuestGiverUI = self.Controllers.UI:GetInterface("QuestDialogue").Holder

    --// Setup variables for the stats
    local GiverValues = Giver:FindFirstChild("QuestValues")

    local Description = GiverValues.QuestDescription.Value
    local QuestName = GiverValues.QuestName.Value
    local QuestType = GiverValues.QuestType.Value
    local Rewards = GiverValues.Rewards
    local Objectives = GiverValues.Objectives

    --// Clear current rewards
    for _, Reward in QuestGiverUI.Rewards:GetChildren() do
        if Reward:IsA("GuiObject") then
            Reward:Destroy()
        end
    end

    --// Clear current objectives
    for _, Objective in QuestGiverUI.Objectives:GetChildren() do
        if Objective:IsA("GuiObject") then
            Objective:Destroy()
        end
    end

    --// Update UI
        --// Info
    QuestGiverUI.Info.Objective.Text = QuestName
    QuestGiverUI.Info.Description.Text = Description

        --// Rewards
    for _, Reward in Rewards:GetChildren() do
        local UIReward = ReplicatedStorage.Assets.UI.Rewards:FindFirstChild(Reward.Name)

        if UIReward then
            UIReward = self.Instancer:CreateInstance(UIReward, QuestGiverUI.Rewards)
            UIReward:SetAttribute("Amount", Reward.Value)

            self.Controllers["ToolTip"]:Attach(UIReward:GetRawObject(), ("x%d %s"):format(Reward.Value, Reward.Name))
        end
    end

        --// Objectives
    for _, Objective in Objectives:GetChildren() do
        local UIObjective = self.Instancer:CreateInstance(
            ReplicatedStorage.Assets.UI.Objective,
            QuestGiverUI.Objectives,
            {}
        )

        if Objective.Name == "Slain" then
            UIObjective.Text = ('<font color="#473d38">0</font><font color="#6d5e56"> /%d</font>        <font color="#8b776e">%ss slained</font>'):format(
                    Objective.Amount.Value,
                    Objective.EntityType.Value
                )
        elseif Objective.Name == "Item" then
            UIObjective.Text = ('<font color="#473d38">0</font><font color="#6d5e56"> /%d</font>        <font color="#8b776e">%ss gathered</font>'):format(
                    Objective.Amount.Value,
                    Objective.ItemType.Value
                )
        end --// Use elseif's for each objective type to provide more freedom
    end
end

function Quests:UpdateObjectives()
    local Objectives: ScrollingFrame = self.Controllers.UI:WaitForInterface("Objectives").Holder.Quests
    local Quests: Folder = Player:FindFirstChild("Quests")
    
    if Quests then
        for _, Quest in Quests:GetChildren() do
            if not Objectives:FindFirstChild(Quest.Value) then
                local NewQuest = self.Instancer:CreateInstance(
                    Objectives.ExampleQuest,
                    Objectives,
                    {
                        Name = Quest.Value;
                        Text = Quest.Value;
                        Visible = true;
                    }
                )

                for _, Objective in Quest.Objectives:GetChildren() do --// Quest types: Slain, Item, SpeakTo
                    local NewObjective = self.Instancer:CreateInstance(
                        NewQuest.Scroller.Objective,
                        NewQuest.Scroller,
                        {
                            Visible = true
                        }
                    )
                    NewObjective.Label.Text = (
                        Objective.Name == "SpeakTo"
                            and `Find and speak to {Objective.Giver.Value.Name}`
                    )
                end
            end
        end
    end
end

function Quests:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    --// Add services
    for i, _ in pairs(self.Services) do
        self.Services[i] = Knit.GetService(i)
    end

    --// Load quests into the system
    task.wait(5)
    local RawGiverList = {}
    for _, QuestGiver in CollectionService:GetTagged("Quest") do
        local NewQuestion: BillboardGui = ReplicatedStorage.VFX.Quests.QuestionMark:Clone()
        NewQuestion.Parent = QuestGiver.Head
        NewQuestion.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)

        local QuestInfo = QuestGiver:FindFirstChild("QuestValues")
        self.Quests[QuestGiver.Name] = {
            QuestName = QuestInfo.QuestName.Value;
            QuestType = QuestInfo.QuestType.Value;

            Rewards = QuestInfo.Rewards:GetChildren();

            Giver = QuestGiver;
        }

        table.insert(RawGiverList, QuestGiver)
    end

    self.Controllers.Cursor:AddHoverState("18324275573", RawGiverList, function(HoverItem)
        self:Interact(HoverItem)
    end)

    --// Add UI Effects
    local QuestUI = self.Controllers.UI:GetInterface("Dialogue").Holder
    self.Controllers.UI:AddPulse(
        QuestUI.Click,
        "TextTransparency"
    )

    --// Load instancer
    self.Instancer = self.Controllers["External"]:Load("Instancer").new()

    --// Run updater
    while task.wait(1) do
        self:UpdateObjectives()
    end
end


function Quests:KnitInit()
    
end


return Quests
