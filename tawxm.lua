local hopHubIds = {100117331123089, 79091703265657, 85211729168715, 97598239454123}

if table.find(hopHubIds, game.PlaceId) or table.find(hopHubIds, game.GameId) then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/HopHub.lua.txt"))()
elseif game.PlaceId == 79268393072444 or game.GameId == 79268393072444 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/SellLemon.lua.txt"))()
elseif game.PlaceId == 16447934574 or game.GameId == 16447934574 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/TouchFootball.lua.txt"))()
end
