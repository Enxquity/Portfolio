--[[

RongoDB is a MongoDB wrapper via HTTP requests allowing for a faster, more organised and easily editable alternative to Roblox DatastoreService.

It has all the endpoints that the MongoDB Data API offers.

--]]

local HttpService = game:GetService("HttpService")

export type Authentication = {
    Url: string;
    APIKey: string
}

export type Payload = {
    Cluster: string?;
    Database: string?;
    Collection: string?;
}

export type Connection = {
    Authentication: Authentication;
    Payload: Payload;
    SetCluster: (self: Connection, Cluster: string) -> ();
    SetDatabase: (self: Connection, Database: string) -> ();
    SetCollection: (self: Connection, Collection: string) -> ();
    FindOne: (self: Connection, Filter: {[string]: string | number | boolean}?) -> ({any: any}?);
	Find: (self: Connection, Filter: {[string]: string | number | boolean}?) -> ({any: any}?);
	InsertOne: (self: Connection, Document: {[string]: string | number | boolean}?) -> (boolean)?;
	InsertMany: (self: Connection, Document: {[string]: string | number | boolean}?) -> (boolean)?;
	UpdateOne: (self: Connection, Filter: {[string]: string | number | boolean}, Update: {["$set"]: {[string]: string | number | boolean}}, Upsert: boolean) -> (boolean)?;
	UpdateMany: (self: Connection, Filter: {[string]: string | number | boolean}, Update: {["$set"]: {[string]: string | number | boolean}}, Upsert: boolean) -> (boolean)?;
	DeleteOne: (self: Connection, Filter: {[string]: string | number | boolean}?) -> ({any: any}?);
	DeleteMany: (self: Connection, Filter: {[string]: string | number | boolean}?) -> ({any: any}?);
}

local MongoRB = {
	DataLogging = false
}
local Endpoints = require(script.Endpoints)

function MongoRB.Encode(Data)
	local EncodedData = HttpService:JSONEncode(Data)
	
	--// Forced changes
	EncodedData = EncodedData:gsub('"filter":%[%]', '"filter":{}')
	
	return EncodedData
end --// Forced to use a encoding method because of the way roblox deals with JSON Encoding

function MongoRB.Request(Endpoint: string, Auth: Authentication, Data: any): {[number]: {}} | boolean | nil
	-- Log the request details for debugging
	if MongoRB.DataLogging == true then
		print(Endpoint, Auth, MongoRB.Encode(Data))
	end
	
    local Success, Result = pcall(function()
        return HttpService:RequestAsync({
            Url = Auth.Url .. Endpoint;
            Method = "POST";
            Headers = {
                ['Content-Type'] = 'application/json';
                ['Access-Control-Request-Headers'] = '*';
                ["Accept"] = "application/json";
                ["api-key"] = Auth.APIKey;
            };
			Body = MongoRB.Encode(Data);
        })
    end)
	
	-- Handle request failure
	if not Success then
		warn(`Request failed! [Result: {Result}]`)
        return nil
	end
	
	-- Handle empty find results
	if Result.Body == '{"document":null}' then
		return nil
	end

    local Body = HttpService:JSONDecode(Result.Body)
	
	-- Check for valid response structure
    if not Body["documents"] and not Body["document"] and not Body["insertedId"] and not Body["modifiedCount"] then
		warn(`Invalid request: {Result.Body}`)
		return false
    end

	return (
			   Body["documents"] 
			or Body["document"] 
			or Body["insertedId"] and true 
			or Body["insertedIds"] and true
			or Body["modifiedCount"] and true
			or nil
		)
end

function MongoRB.ParseBody(Payload)
    return {
        ["dataSource"] = Payload.Cluster;
        ["database"] = Payload.Database;
        ["collection"] = Payload.Collection;
    }
end

function MongoRB.Authenticate(Url: string, APIKey: string) : Authentication
    assert(Url ~= nil, "Cannot authenticate: URL was not provided")
    assert(APIKey ~= nil, "Cannot authenticate: APIKey was not provided")

    return {
        Url = Url;
        APIKey = APIKey;
    } :: Authentication
end

function MongoRB.Connect(Auth: Authentication)
    assert(Auth ~= nil, "Cannot connect: Authentication was not provided")

    local Connection = {
        Authentication = Auth :: Authentication;
        Payload = {
            Cluster = nil;
            Database = nil;
            Collection = nil;
        } :: Payload
    }

    function Connection:SetCluster(Cluster)
        self.Payload.Cluster = Cluster
    end

    function Connection:SetDatabase(Database)
        self.Payload.Database = Database
    end

    function Connection:SetCollection(Collection)
        self.Payload.Collection = Collection
    end

    function Connection:FindOne(Filter)
        local DataBody = MongoRB.ParseBody(self.Payload)
        DataBody["filter"] = Filter or {}

        local Data = MongoRB.Request(
            Endpoints.FindOne,
            self.Authentication,
            DataBody
        )

        return Data or nil
    end

    function Connection:Find(Filter)
        local DataBody = MongoRB.ParseBody(self.Payload)
        DataBody["filter"] = Filter or {}

        local Data = MongoRB.Request(
            Endpoints.Find,
            self.Authentication,
            DataBody
        )

        return Data
    end
	
	function Connection:InsertOne(Document)
		if Document == nil or typeof(Document) ~= "table" then
			return warn("Invalid document to insert.")
		end
		
		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["document"] = Document
		
		local Data = MongoRB.Request(
			Endpoints.InsertOne,
			self.Authentication,
			DataBody
		)
		
		return Data
	end
	
	function Connection:InsertMany(Documents)
		if Documents == nil or typeof(Documents) ~= "table" then
			return warn("Invalid document to insert.")
		end

		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["documents"] = Documents

		local Data = MongoRB.Request(
			Endpoints.InsertMany,
			self.Authentication,
			DataBody
		)

		return Data
	end
	
	function Connection:UpdateOne(Filter, Update, Upsert)
		if Update == nil or typeof(Update) ~= "table" then
			return warn("Invalid update to apply.")
		end

		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["filter"] = Filter
		DataBody["update"] = Update
		DataBody["upsert"] = Upsert or false

		local Data = MongoRB.Request(
			Endpoints.UpdateOne,
			self.Authentication,
			DataBody
		)

		return Data
	end
	
	function Connection:UpdateMany(Filter, Update, Upsert)
		if Update == nil or typeof(Update) ~= "table" then
			return warn("Invalid update to apply.")
		end

		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["filter"] = Filter
		DataBody["update"] = Update
		DataBody["upsert"] = Upsert or false

		local Data = MongoRB.Request(
			Endpoints.UpdateMany,
			self.Authentication,
			DataBody
		)

		return Data
	end
	
	function Connection:DeleteOne(Filter)
		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["filter"] = Filter or {}

		local Data = MongoRB.Request(
			Endpoints.DeleteOne,
			self.Authentication,
			DataBody
		)

		return Data
	end
	
	function Connection:DeleteMany(Filter)
		local DataBody = MongoRB.ParseBody(self.Payload)
		DataBody["filter"] = Filter or {}

		local Data = MongoRB.Request(
			Endpoints.DeleteMany,
			self.Authentication,
			DataBody
		)

		return Data
	end
	
    return Connection :: Connection
end

return MongoRB
