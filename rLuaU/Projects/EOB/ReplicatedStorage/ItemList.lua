local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clothes = {
    Male = {
        Shirts = {
            7119154510;
            18369697692;
            18369904010;
            18369960975;
            18370194143;
            18370236841;
            18401483340;
            18401526770;
            18401602040;
        };
        Pants = {
            18371534108;
            18371587059;
            18371639826;
        };
    };
    Female = {
        Shirts = {
            
        };
        Pants = {
            
        };
    }
};
Face = {
    Eyes = {
        18430823572;
        18430830628;
        18430834666;
        18430840012;
        18430845836;
        18430854061;
        18430862968;
        18430867857;
        18430876714;
    };
    Mouths = {
        18430819650;
        18430827068;
        18430837054;
        18430865529;
        18430848477;
        18430860376;
        18430869880;
        18430878716;
    }
};

--// Gonna make some type of system where you can index the profile and then simply do .HairIndex, etc..

local Parser = {}

Parser.__index = function(self, Profile)
    assert(typeof(Profile) == "table", "Profile was not of table class.")

    local ParsedTable = {}

    --// Static parser
    local Gender = Profile.Gender
    local Character = Profile.Character

    ParsedTable["Shirt"] = "rbxassetid://" .. Clothes[Gender].Shirts[Character.Shirt.Index]
    ParsedTable["Pants"] = "rbxassetid://" .. Clothes[Gender].Pants[Character.Pants.Index]

    ParsedTable["Eyes"] = "rbxassetid://" .. Face.Eyes[Character.Eyes.Index]
    ParsedTable["Mouth"] = "rbxassetid://" .. Face.Mouths[Character.Mouth.Index]

    ParsedTable["Hair"] = ReplicatedStorage.Hair:FindFirstChild(Gender):FindFirstChild(("Hair%d"):format(Character.Hair.Index))

    ParsedTable["Colors"] = {
        Hair = Character.Hair.Color;
        Shirt = Character.Shirt.Color;
        Pants = Character.Pants.Color;
        Skin = Character.SkinColor;
    }

    return ParsedTable
end

return setmetatable(Parser, Parser)