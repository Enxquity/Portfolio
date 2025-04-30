local MongoStore = {
	MongoRB = require(script.MongoRB)
}

function MongoStore:New(MongoConnection)
	local MStore = {
		Connection = MongoConnection
	}
	
	-- Main methods
	function MStore:GetAsync(Identifier: string | number): {string: string | number | boolean | {}}?
		return self.Connection:FindOne{
			Key = tostring(Identifier)
		}
	end
	
	function MStore:SetAsync(Identifier: string | number , Data: {string: string | number | boolean | {}}): boolean
		return self.Connection:UpdateOne(
			{Key = tostring(Identifier)},
			{["$set"] = Data},
			true
		)
	end
	
	-- Util methods
	function MStore:HasData(Identifier: string | number) : boolean
		return MStore:GetAsync(Identifier) ~= nil
	end
	
	return MStore
end



return MongoStore