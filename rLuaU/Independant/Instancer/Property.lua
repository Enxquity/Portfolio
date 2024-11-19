--!strict
--[[ //

	Name: Property.lua
	Author: Enxquity
	D&T: 10/08/2024 : 21:04 (GMT+1)
	Type: ModuleScript
	Path: /StarterPlayer/StarterPlayerScripts/Initialise/UI/Fluent

//]]

	--[[
	
		A descendant module for the Fluent library
			- Can be used standalone
		
	]]


    export type Property = {
        Value: 	string | 
                number | 
                ValueBase | 
                {any} | 
                () -> ();
        Listeners: {
            {
                Callback: (...any) -> ();
                Arguments: {any};
            }
        };
        ID: string;
    }
    
    type IndexableValueBase = ValueBase & {Value: any}
    
    local Property = {
        Properties = {}
    }
    Property.__index = Property
    
    function Property.New(Identifier: string, InitialValue: any)
        local self = setmetatable({
            Value = InitialValue,
            Listeners = {},
            ID = Identifier
        } :: Property, Property)
        Property.Properties[Identifier] = self
        
        if typeof(self.Value) == "Instance" and self.Value:IsA("ValueBase") then
            self.Value:GetPropertyChangedSignal("Value"):Connect(function()
                self:Notify()
            end)
        end
        
        return self
    end
    
    function Property:Get()
        return (
            typeof(self.Value) == "function" and self.Value() 
                or
            (typeof(self.Value) == "Instance" and self.Value:IsA("ValueBase")) and (self.Value :: IndexableValueBase).Value 
                or 
            (typeof(self.Value) ~= "function" and typeof(self.Value) ~= "Instance") and self.Value
        )
    end
    
    function Property:Set(NewValue: any)
        if (typeof(self.Value) == "Instance" and self.Value:IsA("ValueBase")) then
            local ValueBase = self.Value :: IndexableValueBase
            if ValueBase.Value ~= NewValue then
                ValueBase.Value = NewValue
                return
            end
        end
        if self.Value ~= NewValue then
            self.Value = NewValue
            self:Notify()
        end
    end
    
    function Property:Notify()
        for _, Listener in ipairs(self.Listeners) do
            Listener.Callback(
                unpack(Listener.Arguments),
                self:Get()
            )
        end
    end
    
    function Property:Subscribe(Callback: (...any) -> (), ...)
        table.insert(
            self.Listeners,
            {
                Callback = Callback,
                Arguments = {...}
            }
        )
    end
    
    function Property:Observe(Callback: (...any) -> (), ...)
        return self:Subscribe(Callback, ...)
    end
    
    function Property:GetProperty(Identifier: string)
        return Property.Properties[Identifier]
    end
    
    return Property
    