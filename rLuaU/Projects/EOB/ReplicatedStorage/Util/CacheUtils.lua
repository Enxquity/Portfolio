local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Cache = Knit.CreateController{
    Name = "Cache";
    Controllers = {
        
    };
}

function Cache:NewCache()
    local Class = {
        Caches = {};
    }

    function Class.Make(self, CacheName)
        local ChildClass = {}

        if not self.Caches[CacheName] then
            self.Caches[CacheName] = {}
            ChildClass["Cache"] = self.Caches[CacheName]
        else
            return
        end
        
        function ChildClass.Push(self, IndexName, IndexValue)
            local Cache = self.Cache
            Cache[IndexName] = IndexValue
        end
    
        function ChildClass.Pop(self, IndexName)
            local Cache = self.Cache
            Cache[IndexName] = nil
        end
    
        function ChildClass.Get(self, IndexName)
            local Cache = self.Cache
            return Cache[IndexName]
        end

        function ChildClass.Clean(self)
            self.Cache = {}
        end

        return ChildClass
    end

    return Class
end

function Cache:KnitStart()
    --// Add controllers
    for i, _ in pairs(self.Controllers) do
        self.Controllers[i] = Knit.GetController(i)
    end
    
end


function Cache:KnitInit()
    
end


return Cache
