local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit)
local Datastore = require(ReplicatedStorage.ExternalModules.DatastoreService)

local CharacterInfo = Knit.CreateService{
    Name = "CharacterInfo";
    Client = {};
}

function CharacterInfo.Client:LoadData(Player)
    return self.Server:LoadData(Player)
end

function CharacterInfo.Client:HasCharacter(Player)
    return self.Server:HasCharacter(Player)
end

function CharacterInfo.Client:MakeCharacter(Player, CustomisationTable)
    return self.Server:MakeCharacter(Player, CustomisationTable)
end

function CharacterInfo.Client:MainGame(Player)
    return self.Server:MainGame(Player)
end

function CharacterInfo:GetCharacterData(Player)
    return Datastore[Player]:GetRawTable()["Character"]
end

function CharacterInfo:LoadData(Player)
    return Datastore[Player]:Load()
end

function CharacterInfo:HasCharacter(Player)
    local RawData = Datastore[Player]:GetRawTable()
    if RawData["Character"] then
        return true
    else
        return false
    end
end

function CharacterInfo:MakeCharacter(Player, CustomisationTable)
    Datastore[Player]:AddValue("Character", CustomisationTable)
    Datastore[Player]:Save()
end

function CharacterInfo:MainGame(Player)
    game:GetService("TeleportService"):TeleportAsync(12897540411, {Player}) 
end

function CharacterInfo:KnitInit()
    print("[Knit] CharacterInfo service initialised!")
end

return CharacterInfo;