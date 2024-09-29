--[[

RongoDB is a MongoDB wrapper via HTTP requests allowing for a faster, more organised and easily editable alternative to Roblox DatastoreService.

It currently only consists of the findOne endpoint though any new ones can be easily added via the Endpoints.lua file and functions can be easily created.

--]]

local HttpService = game:GetService("HttpService")

export type Authentication = {
    Url: string;
    APIKey: string
}

export type Payload = {
    Cluster: string;
    Database: string;
    Collection: string;
}

export type Connection = {
    Authentication: Authentication;
    Payload: Payload;
    SetCluster: (self: Connection, Cluster: string) -> ();
    SetDatabase: (self: Connection, Database: string) -> ();
    SetCollection: (self: Connection, Collection: string) -> ();
    FindOne: (self: Connection, Filter: {[string]: string}) -> ({any: any}?);
    Find: (self: Connection, Filter: {[string]: string}) -> ({any: any}?);
}

local RongoDB = {}
local Endpoints = require(script.Endpoints)

function Request(Endpoint: string, Auth: Authentication, Data: any)
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
            Body = HttpService:JSONEncode(Data);
        })
    end)

    if not Success then
        return warn(`Request failed! [Result: {Result}]`)
    end

    local Body = HttpService:JSONDecode(Result.Body)

    if not Body["document"] then
        return warn(`Invalid request: {Result.Body}`)
    end

    return Body
end

function RongoDB.ParseBody(Payload)
    return {
        ["dataSource"] = Payload.Cluster;
        ["database"] = Payload.Database;
        ["collection"] = Payload.Collection;
    }
end

function RongoDB.Authenticate(Url: string, APIKey: string) : Authentication
    assert(Url ~= nil, "Cannot authenticate: URL was not provided")
    assert(APIKey ~= nil, "Cannot authenticate: APIKey was not provided")

    return {
        Url = Url;
        APIKey = APIKey;
    } :: Authentication
end

function RongoDB.Connect(Auth: Authentication)
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
        local DataBody = RongoDB.ParseBody(self.Payload)
        DataBody["filter"] = Filter or {}

        local Data = Request(
            Endpoints.FindOne,
            self.Authentication,
            DataBody
        )

        return (Data and Data["document"]) or nil
    end

    function Connection:Find(Filter)
        local DataBody = RongoDB.ParseBody(self.Payload)
        DataBody["filter"] = Filter or {}

        local Data = Request(
            Endpoints.Find,
            self.Authentication,
            DataBody
        )

        return (Data and Data["document"]) or nil
    end

    return Connection :: Connection
end

return RongoDB