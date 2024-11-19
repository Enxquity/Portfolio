--[[ //

	Name: Fluent.lua
	Author: Enxquity
	D&T: 10/08/2024 : 19:51 (GMT+1)
	Type: ModuleScript
	Path: /StarterPlayer/StarterPlayerScripts/Initialise/UI/

//]]

--[[
	What is fluent?
	Fluent is a lightweight and efficient UI utility for Roblox, designed to streamline the process of creating and managing user interfaces.
	Fluent offers a simple and intuitive API for building responsive, dynamic, and maintainable UI components.
		- Get started by wrapping fluent on a interface object
]]

export type Wrapper = {
	Object: Instance;
	Connections: {RBXScriptConnection};
	ID: number;
}

local Fluent = {
	Instances = {};
	Property = require(script.Property);
}

local Services = {
	RunService = game:GetService("RunService");
}

--// Wrapper
function Fluent:Wrap(Component: Instance)
	local FluentWrapper = {
		Object = Component;
		Connections = {};
		ID = #Fluent.Instances+1
	} :: Wrapper
	Fluent.Instances[FluentWrapper.ID] = FluentWrapper
	
	return setmetatable(FluentWrapper, {
		__index = function(self, Index)
			local Object = rawget(self, "Object")
			
			local Exists = pcall(function()
				return Object[Index] ~= nil
			end)
			
			if Object and Exists then 
				if typeof(Object[Index]) == "function" then
					return function(self, ...)
						return Object[Index](Object, ...)
					end
				else
					return Object[Index]
				end
			else
				return rawget(Fluent, Index)
			end
		end,
		__newindex = function(self, Key, Value)
			local Object = rawget(self, "Object")
			Object[Key] = Value
		end --// Allow default usage of object when wrapped (reading/writing properties to object)
	}), FluentWrapper.ID
end

--// Global functions
function Fluent:GetInstance(ID: string)
	return Fluent.Instances[ID]
end

function Fluent:CreateProperty(Identifier: string, Value: any)
	return Fluent.Property.New(Identifier, Value)
end

function Fluent:GetProperty(Identifier: string)
	return Fluent.Property:GetProperty(Identifier)
end

--// Wrapped functions
function Fluent:Observe(Property, Callback: (Object: Instance, Value: any) -> ())
	Callback(self.Object, Property:Get())
	return Property:Subscribe(
		Callback,
		self.Object
	)
end

function Fluent:Render(Callback: (Object: Instance) -> ())
	table.insert(self.Connections, Services.RunService.RenderStepped:Connect(function()
		if self.Object:IsDescendantOf(game) then
			Callback(self.Object)
		else
			for _, Connection in self.Connections do
				Connection:Disconnect()
			end
		end
	end))
end

return Fluent