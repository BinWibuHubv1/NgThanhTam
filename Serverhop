xpcall(function()

if getgenv().SHOP then
	return warn("[SHOP] Already running")
end
getgenv().SHOP=true

CR=cloneref or function(...) return ... end
CF=clonefunction or function(...) return ... end
NC=newcclosure or function(...) return ... end

SVC=setmetatable({},{__index=function(s,n)
	s[n]=CR(game:GetService(n))
	return s[n]
end})

LP=CR(SVC.Players.LocalPlayer)
SG=CR(SVC.StarterGui)
TP=CR(SVC.TeleportService)
MS=CR(SVC.MarketplaceService)
HS=CR(SVC.HttpService)

SC=CF(SG.SetCore)
REQ=request or http_request or(http and http.request)

if not REQ then
	warn("[SHOP] No HTTP function")
	getgenv().SHOP=nil
	return
end

GH=gethui or get_hidden_gui or function()
	return game:GetService("CoreGui")
end

-- Thông báo Thanks - hiện 3 giây
xpcall(function()
	SC(SG,"SendNotification",{
		Title="Thanks",
		Text="Thanks For Using Script",
		Duration=3
	})
end,function()end)

-- Thông báo Credit - hiện 5 giây (thêm theo yêu cầu)
task.wait(3.5)  -- Đợi Thanks biến mất rồi mới hiện Credit
xpcall(function()
	SC(SG,"SendNotification",{
		Title="Credit",
		Text="Script Make By NgThanhTam",
		Duration=5
	})
end,function()end)

task.wait(1)

MODE,CONFIRMED_MODE,ACTION,CLOSE_SCRIPT,WAIT_NEW,GO_BACK=nil,false,nil,false,false,false
BIND=nil
KNOWN_SERVERS={}

GET_BIND=function()
if not BIND or not BIND:IsA("BindableFunction") then
if BIND then BIND:Destroy() end
BIND=Instance.new("BindableFunction")
BIND.Name="SHOP_BIND"
BIND.Parent=GH()
end
BIND.OnInvoke=NC(function(C)
if C=="Random"then
MODE="random"
CONFIRMED_MODE=true
elseif C=="More Options"then
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="More Options",
Text="Newest/Oldest or Lowest stats?\n(Script Make By NgThanhTam)",
Duration=999,
Button1="Newest/Oldest",
Button2="Lowest",
Callback=GET_BIND()
})
end,function()end)
elseif C=="Newest/Oldest"then
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Select Age",
Text="Newest: Latest | Oldest: First servers",
Duration=999,
Button1="Newest",
Button2="Oldest",
Callback=GET_BIND()
})
end,function()end)
elseif C=="Newest"then
MODE="newest"
CONFIRMED_MODE=true
elseif C=="Oldest"then
MODE="oldest"
CONFIRMED_MODE=true
elseif C=="Lowest"then
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Select Lowest",
Text="Players: Least players | Ping: Lowest latency",
Duration=999,
Button1="Lowest Players",
Button2="Lowest Ping",
Callback=GET_BIND()
})
end,function()end)
elseif C=="Lowest Players"then
MODE="lowestplayers"
CONFIRMED_MODE=true
elseif C=="Lowest Ping"then
MODE="lowestping"
CONFIRMED_MODE=true
elseif C=="Join/Copy"then
ACTION="joincopy"
elseif C=="Wait & Notify"then
ACTION="wait"
elseif C=="Join"then
ACTION="jointeleport"
elseif C=="Copy"then
ACTION="copylink"
elseif C=="Close"then
CLOSE_SCRIPT=true
elseif C=="Go back"then
GO_BACK=true
end
end)
return BIND
end

START=function()
MODE,CONFIRMED_MODE=nil,false
GAME_NAME=MS:GetProductInfo(game.PlaceId).Name or"Unknown"
CURRENT_JOB=game.JobId
warn("[SHOP] Starting...")
warn("[SHOP] Game: "..GAME_NAME.." | PlaceId: "..game.PlaceId.." | JobId: "..CURRENT_JOB)
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Select Server Type",
Text="Random: Any server | More options?",
Duration=999,
Button1="Random",
Button2="More Options",
Callback=GET_BIND()
})
end,function()end)
while not CONFIRMED_MODE do task.wait(1) end
warn("[SHOP] Mode: "..MODE)

SERVERS,CURRENT_SERVER={},nil
CURSOR,TOTAL,LIMIT,LAST_CHECK="",0,300,0

if MODE=="lowestping"then
for SORT_TYPE in {"Asc","Desc"} do
CURSOR=""
while TOTAL<LIMIT do
T=tick()
if T-LAST_CHECK<5 then task.wait(5-(T-LAST_CHECK)) end
LAST_CHECK=tick()
URL=CURSOR==""and"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT_TYPE.."&limit=100"or"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT_TYPE.."&limit=100&cursor="..CURSOR
OK,RES=xpcall(function()return REQ({Url=URL,Method="GET"})end,function()return nil end)
if not OK or not RES or not RES.Success then
if RES and RES.StatusCode==429 then
warn("[SHOP] Rate limited")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Waiting 5 seconds...",Duration=5})
end,function()end)
task.wait(5)
LAST_CHECK=tick()
continue
end
warn("[SHOP] Request failed: "..(RES and RES.StatusCode or"unknown"))
break
end
OK,DATA=xpcall(function()return HS:JSONDecode(RES.Body)end,function()return nil end)
if not OK or not DATA then warn("[SHOP] JSON decode failed") break end
if DATA.errors then
warn("[SHOP] API error: "..(DATA.errors[1] and DATA.errors[1].message or"unknown"))
break
end
if not DATA.data then warn("[SHOP] No data field") break end
VALID=0
for i=1,#DATA.data do
S=DATA.data[i]
if type(S)=="table"and tonumber(S.playing)and tonumber(S.maxPlayers)then
if S.id==CURRENT_JOB then
CURRENT_SERVER={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
KNOWN_SERVERS[S.id]=true
elseif S.playing<S.maxPlayers and S.id~=CURRENT_JOB then
SERVERS[#SERVERS+1]={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
VALID+=1
end
end
end
TOTAL+=VALID
CURSOR=DATA.nextPageCursor or""
if CURSOR==""then break end
end
end
else
while TOTAL<LIMIT do
T=tick()
if T-LAST_CHECK<5 then task.wait(5-(T-LAST_CHECK)) end
LAST_CHECK=tick()
SORT=MODE=="lowestplayers"and"Asc"or MODE=="newest"and"Asc"or"Desc"
URL=CURSOR==""and"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100"or"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100&cursor="..CURSOR
OK,RES=xpcall(function()return REQ({Url=URL,Method="GET"})end,function()return nil end)
if not OK or not RES or not RES.Success then
if RES and RES.StatusCode==429 then
warn("[SHOP] Rate limited")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Waiting 5 seconds...",Duration=5})
end,function()end)
task.wait(5)
LAST_CHECK=tick()
continue
end
warn("[SHOP] Request failed")
break
end
OK,DATA=xpcall(function()return HS:JSONDecode(RES.Body)end,function()return nil end)
if not OK or not DATA or not DATA.data then warn("[SHOP] Invalid data") break end
VALID=0
for i=1,#DATA.data do
S=DATA.data[i]
if type(S)=="table"and tonumber(S.playing)and tonumber(S.maxPlayers)then
if S.id==CURRENT_JOB then
CURRENT_SERVER={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
KNOWN_SERVERS[S.id]=true
elseif S.playing<S.maxPlayers and S.id~=CURRENT_JOB then
SERVERS[#SERVERS+1]={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
VALID+=1
end
end
end
TOTAL+=VALID
CURSOR=DATA.nextPageCursor or""
if CURSOR==""then break end
end
end

if #SERVERS==0 then
warn("[SHOP] No servers available (excluding current)")
if CURRENT_SERVER then
warn("[SHOP] You're already in the best server!")
BEST_TEXT=""
if MODE=="lowestplayers"then BEST_TEXT="lowest players"
elseif MODE=="lowestping"then BEST_TEXT="lowest ping"
elseif MODE=="newest"then BEST_TEXT="newest"
elseif MODE=="oldest"then BEST_TEXT="oldest"
elseif MODE=="random"then BEST_TEXT="best available"
end
xpcall(function()
SC(SG,"SendNotification",{
Title="Hmm..",
Text="Already in the "..BEST_TEXT.." server",
Duration=5
})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
warn("[SHOP] No servers available at all")
WAIT_NEW=false
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Hmm..",
Text="Wait for new or close?",
Duration=999,
Button1="Wait & Notify",
Button2="Close",
Callback=GET_BIND()
})
end,function()end)
while not WAIT_NEW and not CLOSE_SCRIPT do task.wait(1) end
if CLOSE_SCRIPT then
warn("[SHOP] Closed")
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
if WAIT_NEW then
MONITOR()
return
end
return
end

warn("[SHOP] Found "..#SERVERS.." servers")
if CURRENT_SERVER then
warn("[SHOP] Current server: "..CURRENT_SERVER.players.."/"..CURRENT_SERVER.max.." players")
SERVERS[#SERVERS+1]=CURRENT_SERVER
end

TARGET=nil

if MODE=="random"then
FILTERED={}
for i=1,#SERVERS do
if SERVERS[i].id~=CURRENT_JOB then FILTERED[#FILTERED+1]=SERVERS[i] end
end
if #FILTERED==0 then
warn("[SHOP] Only current server available")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Already in the best available server",Duration=5})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
TARGET=FILTERED[math.random(1,#FILTERED)]
elseif MODE=="newest"then
FILTERED={}
for i=1,#SERVERS do
if SERVERS[i].id~=CURRENT_JOB then FILTERED[#FILTERED+1]=SERVERS[i] end
end
if #FILTERED==0 then
warn("[SHOP] Only current server available")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Already in the newest server",Duration=5})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
TARGET=FILTERED[1]
elseif MODE=="oldest"then
FILTERED={}
for i=1,#SERVERS do
if SERVERS[i].id~=CURRENT_JOB then FILTERED[#FILTERED+1]=SERVERS[i] end
end
if #FILTERED==0 then
warn("[SHOP] Only current server available")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Already in the oldest server",Duration=5})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
TARGET=FILTERED[#FILTERED]
elseif MODE=="lowestplayers"then
table.sort(SERVERS,function(a,b)
if a.players==b.players then return a.ping<b.ping end
return a.players<b.players
end)
if SERVERS[1].id==CURRENT_JOB then
warn("[SHOP] Already in lowest players server")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Already in the lowest players server",Duration=5})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
TARGET=SERVERS[1]
SAME_STAT={}
for i=1,#SERVERS do
if SERVERS[i].players==TARGET.players and SERVERS[i].id~=CURRENT_JOB then
SAME_STAT[#SAME_STAT+1]=SERVERS[i]
end
end
if #SAME_STAT>1 then
warn("[SHOP] Multiple servers with same player count ("..TARGET.players..")")
VALID_PING={}
for i=1,#SAME_STAT do
if SAME_STAT[i].ping<999999 and SAME_STAT[i].ping>0 then
VALID_PING[#VALID_PING+1]=SAME_STAT[i]
end
end
if #VALID_PING>0 then
table.sort(VALID_PING,function(a,b)
if a.ping==b.ping then
if a.fps==b.fps then return a.max>b.max end
return a.fps>b.fps
end
return a.ping<b.ping
end)
TARGET=VALID_PING[1]
warn("[SHOP] Selected lowest ping: "..TARGET.ping.."ms")
else
warn("[SHOP] No valid ping data, using first match")
TARGET=SAME_STAT[1]
end
end
elseif MODE=="lowestping"then
FILTERED={}
for i=1,#SERVERS do
if SERVERS[i].ping<999999 and SERVERS[i].ping>0 then FILTERED[#FILTERED+1]=SERVERS[i] end
end
if #FILTERED==0 then warn("[SHOP] No valid ping") FILTERED=SERVERS end
table.sort(FILTERED,function(a,b)
if a.ping==b.ping then
if a.fps==b.fps then return a.players<b.players end
return a.fps>b.fps
end
return a.ping<b.ping
end)
if FILTERED[1].id==CURRENT_JOB then
warn("[SHOP] Already in lowest ping server")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Already in the lowest ping server",Duration=5})
end,function()end)
task.wait(3)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
TARGET=FILTERED[1]
end

if not TARGET then
warn("[SHOP] No target")
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end

-- HỎI HÀNH ĐỘNG NGAY SAU KHI TÌM SERVER (KHÔNG HIỆN STATUS)
ACTION=nil
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Found Server",
Text="What do you want to do?",
Duration=999,
Button1="Join/Copy",
Button2="Wait & Notify",
Callback=GET_BIND()
})
end,function()end)
while not ACTION do task.wait(1) end

if ACTION=="joincopy"then
ACTION=nil
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="Join or Copy",
Text="Teleport to server or copy invite link?",
Duration=999,
Button1="Join",
Button2="Copy",
Callback=GET_BIND()
})
end,function()end)
while not ACTION do task.wait(1) end
if ACTION=="jointeleport"then
xpcall(function()
SC(SG,"SendNotification",{Title="Joining",Text="Teleporting...",Duration=5})
end,function()end)
task.wait(1)
xpcall(function()
TP:TeleportToPlaceInstance(game.PlaceId,TARGET.id,LP)
end,function()
warn("[SHOP] Teleport failed")
task.wait(2)
warn("[SHOP] Retry...")
xpcall(function()
TP:TeleportToPlaceInstance(game.PlaceId,TARGET.id,LP)
end,function()
warn("[SHOP] Second attempt failed")
xpcall(function()
SC(SG,"SendNotification",{Title="Failed",Text="Could not teleport",Duration=5})
end,function()end)
end)
end)
elseif ACTION=="copylink"then
INVITE_LINK="roblox://placeId="..game.PlaceId.."&gameInstanceId="..TARGET.id
xpcall(function()
setclipboard(INVITE_LINK)
SC(SG,"SendNotification",{Title="Copied",Text="Invite link copied",Duration=3})
end,function()
warn("[SHOP] Failed to copy")
SC(SG,"SendNotification",{Title="Failed",Text="Could not copy invite link",Duration=3})
end)
GO_BACK,CLOSE_SCRIPT=false,false
task.wait(0.5)
xpcall(function()
SC(SG,"SendNotification",{
Title="What now?",
Text="Go back or close?",
Duration=999,
Button1="Go back",
Button2="Close",
Callback=GET_BIND()
})
end,function()end)
while not GO_BACK and not CLOSE_SCRIPT do task.wait(1) end
if CLOSE_SCRIPT then
warn("[SHOP] Closed")
xpcall(function()
SC(SG,"SendNotification",{Title="Closed",Text="Script closed",Duration=3})
end,function()end)
getgenv().SHOP=nil
if BIND then BIND:Destroy() end
return
end
if GO_BACK then
warn("[SHOP] Going back")
KNOWN_SERVERS={}
START()
return
end
end
elseif ACTION=="wait"then
for i=1,#SERVERS do
KNOWN_SERVERS[SERVERS[i].id]=true
end
MONITOR()
return
end
end

MONITOR=function()
warn("[SHOP] Monitoring...")
xpcall(function()
SC(SG,"SendNotification",{Title="Hmm..",Text="Checking every 5 seconds...",Duration=5})
end,function()end)
MONITOR_LAST=0
while true do
T=tick()
if T-MONITOR_LAST<5 then task.wait(5-(T-MONITOR_LAST)) end
MONITOR_LAST=tick()
CURSOR,CHECK_TOTAL,NEW="",0,{}
if MODE=="lowestping"then
for SORT_TYPE in {"Asc","Desc"} do
CURSOR=""
while CHECK_TOTAL<100 do
SORT=SORT_TYPE
URL=CURSOR==""and"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100"or"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100&cursor="..CURSOR
OK,RES=xpcall(function()return REQ({Url=URL,Method="GET"})end,function()return nil end)
if not OK or not RES or not RES.Success then
if RES and RES.StatusCode==429 then
warn("[SHOP] Rate limited")
xpcall(function()
SC(SG,"SendNotification",{Title="Rate Limited",Text="Waiting 5 seconds...",Duration=5})
end,function()end)
task.wait(5)
LAST_CHECK=tick()
continue
end
warn("[SHOP] Request failed: "..(RES and RES.StatusCode or"unknown"))
break
end
OK,DATA=xpcall(function()return HS:JSONDecode(RES.Body)end,function()return nil end)
if not OK or not DATA then warn("[SHOP] JSON decode failed") break end
if DATA.errors then
warn("[SHOP] API error: "..(DATA.errors[1] and DATA.errors[1].message or"unknown"))
break
end
if not DATA.data then warn("[SHOP] No data field") break end
for i=1,#DATA.data do
S=DATA.data[i]
if type(S)=="table"and tonumber(S.playing)and tonumber(S.maxPlayers)and S.playing<S.maxPlayers and not KNOWN_SERVERS[S.id]then
NEW[#NEW+1]={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
CHECK_TOTAL+=1
end
end
CURSOR=DATA.nextPageCursor or""
if CURSOR==""then break end
task.wait(0.15)
end
end
else
while CHECK_TOTAL<100 do
SORT=MODE=="lowestplayers"and"Asc"or MODE=="newest"and"Asc"or"Desc"
URL=CURSOR==""and"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100"or"https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..SORT.."&limit=100&cursor="..CURSOR
OK,RES=xpcall(function()return REQ({Url=URL,Method="GET"})end,function()return nil end)
if not OK or not RES or not RES.Success then break end
OK,DATA=xpcall(function()return HS:JSONDecode(RES.Body)end,function()return nil end)
if not OK or not DATA or not DATA.data then break end
for i=1,#DATA.data do
S=DATA.data[i]
if type(S)=="table"and tonumber(S.playing)and tonumber(S.maxPlayers)and S.playing<S.maxPlayers and not KNOWN_SERVERS[S.id]then
NEW[#NEW+1]={id=S.id,players=S.playing,max=S.maxPlayers,ping=tonumber(S.ping)or 999999,fps=tonumber(S.fps)or 0}
CHECK_TOTAL+=1
end
end
CURSOR=DATA.nextPageCursor or""
if CURSOR==""then break end
task.wait(0.15)
end
end
if #NEW>0 then
warn("[SHOP] New servers found")
xpcall(function()
SC(SG,"SendNotification",{Title="New Servers",Text="Restarting...",Duration=3})
end,function()end)
task.wait(3)
KNOWN_SERVERS={}
START()
return
end
end
end

START()
getgenv().SHOP=nil
if BIND then BIND:Destroy() end

end,function(err)
	warn("[SHOP FATAL ERROR] "..tostring(err))
	getgenv().SHOP=nil
	BIND_CHECK=GH():FindFirstChild("SHOP_BIND")
	if BIND_CHECK then BIND_CHECK:Destroy() end
end)
