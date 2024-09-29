local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ToolTip = Knit.CreateController { 
    Name = "ToolTip"; 
    Controllers = {
        ["External"] = "None";
    }
}

function ToolTip:CreateToolTip(Text, Parent)
    local ToolTip = self.Instancer:CreateInstance(
        ReplicatedStorage.Assets.UI.ToolTip,
        Parent
    );
    ToolTip.Label.Text = Text;

    --// Text is set, we have to scale the ToolTip to fill the text now
    local TextSize = TextService:GetTextSize(
        Text, 
        ToolTip.Label.TextSize, 
        ToolTip.Label.Font, 
        Vector2.new(math.huge, ToolTip.Label.AbsoluteSize.Y)
    )
    ToolTip.Size = UDim2.new(0, TextSize.X + 20, ToolTip.Size.Y.Scale, 0) 

    return ToolTip
end

function ToolTip:Attach(GuiInstance, Text)
    local ToolTipInstance = nil
    GuiInstance.MouseEnter:Connect(function()
        ToolTipInstance = self:CreateToolTip(Text, GuiInstance)
    end)

    GuiInstance.MouseLeave:Connect(function()
        if ToolTipInstance then
            ToolTipInstance:Destroy()
            ToolTipInstance = nil
        end
    end)
end

function ToolTip:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end

    self.Instancer = self.Controllers["External"]:Load("Instancer").new()
end


function ToolTip:KnitInit()
    
end


return ToolTip
