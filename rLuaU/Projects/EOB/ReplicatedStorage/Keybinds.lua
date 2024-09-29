local GuiService = game:GetService("GuiService")
local Keybinds = {
    ["Dash"] = {
        ["PC"] = Enum.KeyCode.LeftAlt;
        ["Xbox"] = Enum.KeyCode.DPadRight;
    };
    ["Zoom"] = {
        ["PC"] = Enum.KeyCode.C;
        ["Xbox"] = Enum.KeyCode.DPadUp;
    };
    ["Interact"] = {
        ["PC"] = Enum.UserInputType.MouseButton1;
        ["Xbox"] = Enum.KeyCode.DPadLeft; --// idk placeholder?
    };
    ["M1"] = {
        ["PC"] = Enum.UserInputType.MouseButton1;
        ["Xbox"] = Enum.KeyCode.ButtonX;
    }
}

local IndexTable = {}
IndexTable.__index = function(self, index)
    if Keybinds[index] then
        if GuiService:IsTenFootInterface() == true then --// Xbox user
            return Keybinds[index].Xbox
        else --// Else is pc or mobile (however mobile is bad and we DO NOT CARE) (now we slightly do) (another update, we dont really care that much anymore)
            return Keybinds[index].PC
        end
    end
    return nil
end;

return setmetatable(IndexTable, IndexTable)