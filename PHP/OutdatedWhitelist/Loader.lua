local Game_ID = game.PlaceId
local rq = http_request or request or HttpPost or syn.request or http.request 

local decode = (syn and syn.crypt.base64.decode) or (KRNL_LOADED and Krnl.Base64.Decode) or (identifyexecutor and crypt.base64decode)
local encode = (syn and syn.crypt.base64.encode) or (KRNL_LOADED and Krnl.Base64.Encode) or (identifyexecutor and crypt.base64encode)

local b = shared.a
local response = rq({
	Url = "http://xenonv2.co.uk/dependencies.php?b9q=" .. b,
	Method = 'GET',
})
local dependencies = game:GetService("HttpService"):JSONDecode(response.Body);

local response2 = rq({
	Url = "http://xenonv2.co.uk/whitelist.php?q7d=" .. b,
	Method = 'GET',
})
local px = response2.Body:gsub("%s+", "")
local x = decode(px);

local _a, __ = math[string.gsub(string.reverse(dependencies.c02qp_2oaalsowpq2402l1palfr), " ", "")] 
local _b, ___ = math[string.gsub(string.reverse(dependencies.s1_291a92evea9h21al243n601k), " ", "")] 
local _c, ____ = math[string.gsub(string.reverse(dependencies.co291_29asd9223ak8291lqpior), " ", "")]
local _e, _____ = math[string.gsub(string.reverse(dependencies.sow910lamfiwqorti21oapqlfke), " ", "")]
local _f, ______ = math[string.gsub(string.reverse(dependencies.as9f93p2o1lwjaslghw421ppqow), " ", "")]
local _d = os.time()
if _d == 0 then
	while true do
	end
end

x = x:gsub("@", "");
x = x:gsub("%s+", "");
local split = string.split(x, "_");
local _gr, ___b = split[1], tonumber(split[2])
local _ts = math.floor((math.floor(os.time())*2.3149/3)-___b);

if (_ts > 100 or _ts < -25) then
	_ts = 9123128391238;
else
	_ts = math.floor((os.time()*2.3149/3)-_ts)
end

local _er = _f((_ts * (176 ^ 2)) + 3 / 2)
_gr:gsub("%s+", "");

if tonumber(_er) ~= tonumber(_gr) then
	print("Invalid whitelist.")
	for i = 1, 1000000 do
		while true do
		end
		for i = 1, 1000 do
			while true do
			end
		end
	end
end

local Game_Locations = {
    [{2809202155, 4643697430}] = "yba";	
}

local g_f = ""
for i,v in pairs(Game_Locations) do
    if table.find(i, Game_ID) then
        g_f = v
        break
    end
end

local GameScript = rq({
    Url = "http://xenonv2.co.uk/loader.php?zx0=" .. b,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json",
        ["Game"] = g_f
    },
})

loadstring(GameScript.Body)()