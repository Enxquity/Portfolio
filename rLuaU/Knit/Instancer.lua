local Debris = game:GetService("Debris")
--[[ //

	Name: Instancer.lua
	Author: Enxquity
	D&T: 05/06/2024 : 19:52 (GMT+1)
	Type: ModuleScript
	Path: /StarterPlayer/StarterPlayerScripts/Initialise

//]]

--// This took me a while to get working but might use in future projects

local InstanceWrapper = {}
InstanceWrapper.__index = InstanceWrapper

function InstanceWrapper:AddDebris(Time)
	--[[task.delay(
		Time, 
		self.Object.Destroy, 
		self.Object
	)--]] --// Should be faster than using Debris service
	Debris:AddItem(self.Object, Time)
end

function InstanceWrapper:QuickClone(Ancestor)
    local CloneList = {}
    for _, Child in Ancestor:GetChildren() do
        local NewChild = Child:Clone()
        NewChild.Parent = self.Object

        table.insert(CloneList, NewChild)
    end
    return CloneList
end

function InstanceWrapper:RenderOnExistance(Func)
    local OnLeave = nil
    coroutine.wrap(function()
        while self.Object:IsDescendantOf(workspace) do
            Func()
            task.wait()
        end
        if OnLeave then
            OnLeave()
        end
    end)()

    return {
        OnDestroy = function(NewFunc)
            OnLeave = NewFunc
        end
    }
end

function InstanceWrapper:GetChildrenWhichAre(Type)
	local ParsedList = {}
	for _, Object in self.Object:GetChildren() do
		if Object:IsA(Type) then
			table.insert(
				ParsedList,
				Object 
			)
		end
	end
	return ParsedList
end

function InstanceWrapper:GetDescendantsWhichAre(Type)
	local ParsedList = {}
	for _, Object in self.Object:GetDescendants() do
		if Object:IsA(Type) then
			table.insert(
				ParsedList,
				Object 
			)
		end
	end
	return ParsedList
end

function InstanceWrapper:Life()
    return (tick()-self.ObjectCreation)
end

function InstanceWrapper:GetRawObject()
	return self.Object
end --// In cases where you want to add the object into a table, not sure if i can use metamethods to do this automatically

--// Type dependant functions

	--// Sounds
function InstanceWrapper:GetSoundLength()
	assert(self.Object:IsA("Sound"), "This method is only callable on class type: Sound")

	if self.Object:IsA("Sound") and self.Object.SoundId ~= "" then
		local StartTime = tick()
		repeat 
			task.wait()
		until self.Object.TimeLength > 0 or (tick() - StartTime) > 5
		if (tick() - StartTime) > 5 then
			warn("Sound failed to load within the timeout period.")
		end
		return self.Object.TimeLength
	end
end

	--// Base Parts
function InstanceWrapper:Attach(Part)
	assert(self.Object:IsA("BasePart"), "This method is only callable on class type: BasePart")

    local NewWeld = Instance.new("WeldConstraint")
    NewWeld.Parent = self.Object
    NewWeld.Part0 = Part
    NewWeld.Part1 = self.Object
end


function InstanceWrapper:OverlapsWith(Part, Filter)
	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = Filter or {Part}
	Params.FilterType = Enum.RaycastFilterType.Include

	local OverlapList = workspace:GetPartsInPart(self.Object, Params)

	return #OverlapList > 0, OverlapList
end

	--// GuiObjects
function InstanceWrapper:Link(UI, LinkX, LinkY, OtherLinks)
	assert(self.Object:IsA("GuiObject"), "This method is only callable on class type: GuiObject")

	UI:GetPropertyChangedSignal("Position"):Connect(function()
		self.Object.Position = UDim2.fromScale(
			LinkX and UI.Position.X.Scale or self.Object.Position.X.Scale,
			LinkY and UI.Position.Y.Scale or self.Object.Position.Y.Scale
		)
	end)

	for LinkProp, ObjectProp in OtherLinks do
		UI:GetPropertyChangedSignal(LinkProp):Connect(function()
			self.Object[ObjectProp] = UI[LinkProp]
		end)
	end
end

function InstanceWrapper:New(Inst)
	local Proxy = { 
		Object = Inst; 
		ObjectCreation = tick() 
	}
	setmetatable(Proxy, self)
	return Proxy
end

function InstanceWrapper:__index(Key)
	local Object = rawget(self, "Object") --// We use rawget because we dont want to call the index method again which would lead to a stack overflow error
	
	--// We use this workaround to see if a property exists
	local Exists = pcall(function()
		return Object[Key] ~= nil
	end)
	
	if Object and Exists then --// Check if the property in the instance exists
		if typeof(Object[Key]) == "function" then --// Check whether it's a method or a property
			return function(self, ...)
				return Object[Key](Object, ...)
			end
		else
			return Object[Key]
		end
	else
		return rawget(getmetatable(self), Key)
	end
end

function InstanceWrapper:__newindex(Key, NewValue)
	local Object = rawget(self, "Object")
	Object[Key] = NewValue
end

local Instancer = {}
Instancer.__index = Instancer

function Instancer.new()
	return setmetatable({
		Cache = {};
	}, Instancer)
end

function Instancer:CreateInstance(Type: string | Instance, Parent: Instance, Properties: {string: any}, ...)
	assert(Type and Parent, "Failed to provide a required argument")

	--// Create the instance
	local NewInstance = (typeof(Type) == "string" and Instance.new(Type) or Type:Clone())
	NewInstance.Parent = Parent

	--// Add it to the classes cache
	table.insert(self.Cache, NewInstance)

	if Properties then
		for Property, Value in pairs(Properties) do
			if Property == "Attributes" then
				for AttributeName, AttributeValue in Value do
					NewInstance:SetAttribute(AttributeName, AttributeValue)
				end
				continue
			end
			local Success, Fail = pcall(function()
				NewInstance[Property] = Value
			end)
			if not Success then
				warn("Failed to set property of instance:", Fail)
			end
		end
	end

	for _, Child in {...} do
		self:CreateInstance(Child[1], NewInstance, Child[2])
	end

	return InstanceWrapper:New(NewInstance)
end

function Instancer:Wrap(Inst)
	return InstanceWrapper:New(Inst)
end

function Instancer:FindAndDestroy(Instance, Name)
	assert(Instance and Name, "Failed to provide a reqired argument")

	local Descendant = Instance:FindFirstChild(Name, true)

	if Descendant then
		Descendant:Destroy()

		return true --// Resolve for completed successfully
	end

	return false
end

function Instancer:ClearCache()
	for _, CachedAsset in self.Cache do
		CachedAsset:Destroy()
	end
	self.Cache = {}
end

return Instancer