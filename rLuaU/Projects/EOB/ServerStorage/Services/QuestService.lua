local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestService = Knit.CreateService {
    Name = "QuestService",
    Client = {},
}

function QuestService.Client:ClaimQuest(Player, Giver)
    return self.Server:ClaimQuest(Player, Giver)
end

function QuestService:GetQuests(Player)
    return {}
end

function QuestService:ClaimQuest(Player, Giver)
    --// No sanity checks
    local Quest = self.Instancer:CreateInstance(
        "StringValue",
         Player.Quests,
         {
            Name = "QuestName";
            Value = Giver.QuestValues.QuestName.Value;
         },
            {
                "StringValue";
                {
                    Name = "Description";
                    Value = Giver.QuestValues.QuestDescription.Value;
                }
            }
    )

    local Objectives = self.Instancer:CreateInstance(
        Giver.QuestValues.Objectives,
        Quest:GetRawObject()
    )

    for _, Object in Objectives:GetDescendantsWhichAre("ValueBase") do
        if Object:IsA("IntValue") or Object:IsA("NumberValue") then
            self.Instancer:CreateInstance(
                "IntValue",
                Object,
                {
                    Name = "Completion";
                    Value = 0;
                },
                    {
                        "IntValue",
                        {
                            Name = "Goal";
                            Value = Object.Value;
                        }
                    }
            )
        else
            self.Instancer:CreateInstance(
                "BoolValue",
                Object,
                {
                    Name = "Completion";
                    Value = false;
                }
            )
        end
    end

    return Quest
end

function QuestService:HasQuest()
    
end

function QuestService:KnitStart()
    
end


function QuestService:KnitInit()
    Players.PlayerAdded:Connect(function(Player)
        local Quests = Instance.new("Folder")
        Quests.Parent = Player
        Quests.Name = "Quests"

        --// Usually load quests here but i haven't hooked it up to the datastore
    end)
    
    self.Instancer = require(ReplicatedStorage.Source.External.Instancer).new()
end


return QuestService
