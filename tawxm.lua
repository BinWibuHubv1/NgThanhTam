if not game:IsLoaded() then
    game.Loaded:Wait()
end

if setclipboard then
    setclipboard("https://discord.gg/HaHYKVqc7")
elseif toclipboard then
    toclipboard("https://discord.gg/HaHYKVqc7")
end

local bloxFruitsIds = {100117331123089, 2753915549, 85211729168715}
local scriptUrl = ""

if table.find(bloxFruitsIds, game.PlaceId) or table.find(bloxFruitsIds, game.GameId) then
    scriptUrl = "https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/BloxFruits.lua"
elseif game.PlaceId == 79268393072444 or game.GameId == 79268393072444 then
    scriptUrl = "https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/SellLemon.lua.txt"
elseif game.PlaceId == 16447934574 or game.GameId == 16447934574 then
    scriptUrl = "https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/TouchFootball.lua.txt"
else
    scriptUrl = "https://raw.githubusercontent.com/BinWibuHubv1/NgThanhTam/refs/heads/main/HopHub.lua.txt"
end

if scriptUrl ~= "" then
    task.spawn(function()
        local success, content = pcall(game.HttpGet, game, scriptUrl)
        if success and content then
            local func = loadstring(content)
            if func then
                func()
            end
        end
    end)
end
