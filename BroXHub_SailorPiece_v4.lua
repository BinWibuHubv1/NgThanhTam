local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera            = Workspace.CurrentCamera

local LP        = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()

local CFG = {
    AutoFarm = false, AutoFarmMob = "Bandit",
    AutoBoss = false, AutoBossName = "solo hunter", AutoBossKw = "solo hunter",
    AutoQuest = false, AutoChest = false,
    AutoFrag = false, AutoMapPiece = false,
    AutoDungeon = false, AutoInfTower = false,
    AutoCrystal = false, CrystalCoin = false,
    AutoSeaBeast = false,
    AutoSkill = false, AutoSkillDelay = 0.1,
    AutoHakiObs = false, AutoHakiArm = false,
    AutoHakiV2 = false, AutoHakiV3 = false,
    AutoFightStyle = false, FightStyle = "Yuji",
    AutoEquipWeapon = false, SelectedWeapon = "Dragon Goddess",
    AutoSummonBoss = false, SummonBossName = "Strongest Shinobi",
    AutoPityFarm = false, PityBossName = "Strongest Shinobi",
    AutoStat = false, StatType = "Melee",
    AutoReroll = false, RerollTarget = "Demonic",
    AutoAscend = false,
    FruitESP = false, FruitSniper = false, FruitNotif = false, AutoEatFruit = false,
    KillAura = false, KillAuraRange = 25,
    GodMode = false, InfHealth = false, AutoHeal = false,
    ESPPlayers = false, ESPMobs = false, ESPBoss = false,
    ESPChest = false, ESPFrag = false, ESPSeaBeast = false,
    ShowNames = false, ShowHP = false, ShowDist = false,
    ShipSpeed = false, AntiSink = false,
    Fullbright = false, NoFog = false, FPSBoost = false, NoShaders = false,
    AntiAFK = false, AutoRespawn = false,
    Speed = 16, SpeedEnabled = false,
    HighJump = false, JumpPower = 50,
    Fly = false, FlySpeed = 80,
    Noclip = false, InfStamina = false, NoFall = false,
}

local ESPStore = {}

local function GetRoot() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()  local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function Notify(t, c, d) Rayfield:Notify({ Title=t, Content=c, Duration=d or 4, Image=4483362458 }) end
local function SafeTP(cf) local r = GetRoot(); if r then r.CFrame = cf end end

local function FireAttack(target)
    for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local n = rem.Name:lower()
            if n:find("attack") or n:find("hit") or n:find("damage") or n:find("punch") or n:find("slash") or n:find("kill") then
                pcall(function() rem:FireServer(target) end)
            end
        end
    end
end

local function FireInteract(target)
    for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local n = rem.Name:lower()
            if n:find("open") or n:find("interact") or n:find("collect") or n:find("pickup") or n:find("grab") or n:find("touch") then
                pcall(function() rem:FireServer(target) end)
            end
        end
    end
end

local function FireRemoteByKey(keyword, arg)
    for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            if rem.Name:lower():find(keyword) then
                pcall(function() if arg then rem:FireServer(arg) else rem:FireServer() end end)
            end
        end
    end
end

local function FireFunctionByKey(keyword, arg)
    for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteFunction") then
            if rem.Name:lower():find(keyword) then
                pcall(function() if arg then rem:InvokeServer(arg) else rem:InvokeServer() end end)
            end
        end
    end
end

local function FindNearest(keyword, maxDist)
    local root = GetRoot()
    if not root then return nil end
    local best, bestDist = nil, maxDist or 99999
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(keyword:lower()) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local r   = obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and r then
                local d = (root.Position - r.Position).Magnitude
                if d < bestDist then bestDist = d; best = obj end
            end
        end
    end
    return best
end

local function ClearESP(tag)
    if ESPStore[tag] then
        for _, o in pairs(ESPStore[tag]) do pcall(function() o:Destroy() end) end
    end
    ESPStore[tag] = {}
end

local function AddHL(model, fill, outline, tag, trans)
    if not model or not model.Parent then return end
    local ex = model:FindFirstChild("BX_HL_"..tag); if ex then ex:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Name = "BX_HL_"..tag; hl.FillColor = fill; hl.OutlineColor = outline
    hl.FillTransparency = trans or 0.5; hl.Adornee = model; hl.Parent = model
    if not ESPStore[tag] then ESPStore[tag] = {} end
    table.insert(ESPStore[tag], hl)
end

local function AddBB(part, text, color, tag, yOff)
    if not part or not part.Parent then return end
    local ex = part:FindFirstChild("BX_BB_"..tag); if ex then ex:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "BX_BB_"..tag; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,160,0,52); bb.StudsOffset = Vector3.new(0, yOff or 4, 0); bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = 12; lbl.Font = Enum.Font.GothamBold; lbl.TextWrapped = true; lbl.Parent = bb
    if not ESPStore[tag] then ESPStore[tag] = {} end
    table.insert(ESPStore[tag], bb)
    return lbl
end

local function RefreshPlayerESP(state)
    ClearESP("Ply")
    if not state then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            AddHL(p.Character, Color3.fromRGB(80,160,255), Color3.fromRGB(0,100,220), "Ply")
            local head = p.Character:FindFirstChild("Head")
            if head then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local txt = p.Name
                if CFG.ShowHP and hum then txt = txt.."\n❤️ "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
                AddBB(head, txt, Color3.fromRGB(120,200,255), "Ply", 3)
            end
        end
    end
end

local SEA1_MOBS = {
    "Bandit","Monkey","Marine","Pirate","Ninja","Zombie","Sorcerer",
    "Slime","Shinigami","Hollow","Demon","Desert Bandit","Guard",
}
local SEA2_MOBS = {
    "Bizarre Bandit","Punch Island Guard","Dark Sorcerer",
    "Ancient Golem","Shadow Demon","Easter Enemy","Sea 2 Pirate",
}
local SEA1_BOSSES = {
    {name="Solo Hunter",          kw="solo hunter",   drop="Abyss Edge, Dark Ring, Rerolls"},
    {name="Vampire King (Alucard)",kw="alucard",      drop="Dark Ring, Capes, Titles"},
    {name="Yuji (Cursed Vessel)", kw="yuji",          drop="Energy Cores, Limitless Items"},
    {name="Gojo (Limitless)",     kw="gojo",          drop="Blindfold, Energy Core"},
    {name="Sukuna (Curse King)",  kw="sukuna",        drop="Malevolent Items"},
    {name="Aizen (Manipulator)",  kw="aizen",         drop="Hogyoku Fragment, Mirage Pendant"},
    {name="True Aizen",           kw="true aizen",    drop="Hogyoku Fragment+, Reiatsu Core"},
    {name="Yamato",               kw="yamato",        drop="Yamato Sword Mats, Artifacts"},
    {name="Blessed Maiden",       kw="blessed maiden",drop="Divine Fragment, Wings"},
    {name="Madoka",               kw="madoka",        drop="Hearts, Divine Fragment"},
    {name="Strongest Shinobi",    kw="shinobi",       drop="Void Reaver, Boss Tickets, Dungeon Keys"},
    {name="Qin Shi",              kw="qin shi",       drop="High Tier Artifacts"},
    {name="Demon King (Anos)",    kw="demon king",    drop="Path Fragment, Eternal Core"},
    {name="Slime (Rimuru)",       kw="rimuru",        drop="Slime Mats, Cores"},
    {name="Time Tyrant",          kw="time tyrant",   drop="Time Fragment, Dominion Brand"},
    {name="World Summoner",       kw="world summoner",drop="World Fragment, Artifacts"},
}
local SEA2_BOSSES = {
    {name="Cosmic Being",         kw="cosmic being",  drop="Cosmic Mats, F-Move, Punch Island Drop"},
    {name="The World",            kw="the world",     drop="World Fragment, Melee Mat"},
    {name="Dragon Goddess",       kw="dragon goddess",drop="Dragon Scale, Sea Beast Drops"},
    {name="Great Mage",           kw="great mage",    drop="Mage Core, Magic Fragment"},
    {name="Kraken",               kw="kraken",        drop="Sea Beast Chest, Dragon Goddess Mat"},
    {name="Sea Serpent",          kw="sea serpent",   drop="Sea Beast Chest, Dragon Goddess Mat"},
}
local SEA1_ISLANDS = {
    {name="Starter Island",   kw="starter",    lvl=0},
    {name="Jungle Island",    kw="jungle",     lvl=250},
    {name="Desert Island",    kw="desert",     lvl=750},
    {name="Lawless Island",   kw="lawless",    lvl=1500},
    {name="Shibuya Station",  kw="shibuya",    lvl=3000},
    {name="Hueco Mundo",      kw="hueco",      lvl=3500},
    {name="Valentine Island", kw="valentine",  lvl=4000},
    {name="Sailor Island",    kw="sailor",     lvl=4500},
    {name="Ninja Island",     kw="ninja",      lvl=5000},
    {name="Boss Island",      kw="boss isl",   lvl=5000},
    {name="Dungeon Island",   kw="dungeon",    lvl=5000},
    {name="Shinjuku Island",  kw="shinjuku",   lvl=6250},
    {name="Slime Island",     kw="slime isl",  lvl=8000},
    {name="Academy Island",   kw="academy",    lvl=9000},
    {name="Judgement Island", kw="judgement",  lvl=10000},
    {name="Soul Society",     kw="soul",       lvl=10750},
    {name="World Island",     kw="world isl",  lvl=12500},
}
local SEA2_ISLANDS = {
    {name="World Island Sea 2",   kw="world",    lvl=12500},
    {name="Starter Island Sea 2", kw="starter",  lvl=12750},
    {name="Bizarre Island",       kw="bizarre",  lvl=13000},
    {name="Easter Island",        kw="easter",   lvl=13000},
    {name="Punch Island",         kw="punch",    lvl=14500},
}
local FIGHT_STYLES = {
    "Yuji","Gilgamesh","Qin Shi","Cosmic Being","The World",
    "Shadow Monarch","Demon King","True Aizen","Rimuru",
    "Dragon God","Thunder God","Ice Emperor",
}
local WEAPONS = {
    "Dragon Goddess","Great Mage","Yamato","Abyss Edge",
    "Dark Blade","Soul Blade","Void Reaver","Thunder Sword","Katana",
}
local FRUITS = {
    "Rubber","Flame","Ice","Quake","Dark","Light",
    "Sand","String","Shadow","Spring","Bomb","Smoke",
}

local Window = Rayfield:CreateWindow({
    Name            = "BroXHub",
    Icon            = 0,
    LoadingTitle    = "BroXHub",
    LoadingSubtitle = "Sailor Piece | Anti-Magic Update 2026",
    Theme           = "Default",
    ConfigurationSaving = { Enabled=true, FolderName="BroXHub", FileName="SailorPiece_v4" },
    Discord  = { Enabled=false, Invite="", RememberJoins=false },
    KeySystem = false,
})

local S1 = Window:CreateTab("🌊 Sea 1", 4483362458)

S1:CreateSection("Auto Mob Farm")

local s1Mobs = {}
for _,m in ipairs(SEA1_MOBS) do table.insert(s1Mobs, m) end
S1:CreateDropdown({ Name="Mob (Sea 1)", Options=s1Mobs, CurrentOption={"Bandit"}, MultipleOptions=false, Flag="S1Mob",
    Callback=function(v) CFG.AutoFarmMob = type(v)=="table" and v[1] or v end })

S1:CreateToggle({ Name="Auto Farm Mob", CurrentValue=false, Flag="AFarmS1",
    Callback=function(v)
        CFG.AutoFarm = v
        if v then task.spawn(function()
            while CFG.AutoFarm do
                local mob = FindNearest(CFG.AutoFarmMob)
                if mob then
                    local r = mob:FindFirstChild("HumanoidRootPart")
                    if r then SafeTP(r.CFrame * CFrame.new(0,0,-3.5)); task.wait(0.05); FireAttack(mob) end
                end
                task.wait(0.1)
            end
        end) end
    end })

S1:CreateSection("Boss Farm")

local s1BossNames = {}
for _,b in ipairs(SEA1_BOSSES) do table.insert(s1BossNames, b.name) end
S1:CreateDropdown({ Name="Boss (Sea 1)", Options=s1BossNames, CurrentOption={"Solo Hunter"}, MultipleOptions=false, Flag="S1Boss",
    Callback=function(v)
        local sel = type(v)=="table" and v[1] or v
        for _,b in ipairs(SEA1_BOSSES) do if b.name==sel then CFG.AutoBossKw=b.kw; break end end
    end })

S1:CreateToggle({ Name="Auto Farm Boss", CurrentValue=false, Flag="ABossS1",
    Callback=function(v)
        CFG.AutoBoss = v
        if v then task.spawn(function()
            while CFG.AutoBoss do
                local boss = FindNearest(CFG.AutoBossKw)
                if boss then
                    local r = boss:FindFirstChild("HumanoidRootPart")
                    if r then SafeTP(r.CFrame * CFrame.new(0,0,-5)); task.wait(0.06); FireAttack(boss) end
                else task.wait(4) end
                task.wait(0.1)
            end
        end) end
    end })

S1:CreateToggle({ Name="Auto Summon Boss (Boss Island)", CurrentValue=false, Flag="AutoSummon",
    Callback=function(v)
        CFG.AutoSummonBoss = v
        if v then task.spawn(function()
            while CFG.AutoSummonBoss do
                FireRemoteByKey("summon"); FireRemoteByKey("spawn_boss"); FireRemoteByKey("summonboss")
                task.wait(1)
                local boss = FindNearest(CFG.SummonBossName)
                if boss then
                    local r = boss:FindFirstChild("HumanoidRootPart")
                    if r then SafeTP(r.CFrame * CFrame.new(0,0,-5)); task.wait(0.06); FireAttack(boss) end
                end
                task.wait(0.2)
            end
        end) end
    end })

local summonOpts = {}
for _,b in ipairs(SEA1_BOSSES) do table.insert(summonOpts, b.name) end
S1:CreateDropdown({ Name="Summon Boss Target", Options=summonOpts, CurrentOption={"Strongest Shinobi"}, MultipleOptions=false, Flag="SummonBoss",
    Callback=function(v)
        local sel = type(v)=="table" and v[1] or v
        for _,b in ipairs(SEA1_BOSSES) do if b.name==sel then CFG.SummonBossName=b.kw; break end end
    end })

S1:CreateToggle({ Name="Auto Pity Farm (25 kills guaranteed rare)", CurrentValue=false, Flag="AutoPity",
    Callback=function(v)
        CFG.AutoPityFarm = v
        if v then task.spawn(function()
            local kills = 0
            while CFG.AutoPityFarm do
                local boss = FindNearest(CFG.AutoBossKw)
                if boss then
                    local hum = boss:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local r = boss:FindFirstChild("HumanoidRootPart")
                        if r then SafeTP(r.CFrame * CFrame.new(0,0,-5)); task.wait(0.06); FireAttack(boss) end
                    else
                        kills = kills + 1
                        if kills % 25 == 0 then Notify("💎 Pity!", "Kill #"..kills.." — Rare drop guaranteed!", 5) end
                        task.wait(2)
                    end
                else task.wait(3) end
                task.wait(0.1)
            end
        end) end
    end })

S1:CreateButton({ Name="⚡ TP to Boss", Callback=function()
    local boss = FindNearest(CFG.AutoBossKw)
    if boss then
        local r = boss:FindFirstChild("HumanoidRootPart")
        if r then SafeTP(r.CFrame * CFrame.new(0,0,-6)); Notify("BroXHub","TP → "..boss.Name,3) end
    else Notify("BroXHub","Boss not found.",3) end
end })

local infoS1 = ""
for _,b in ipairs(SEA1_BOSSES) do infoS1=infoS1.."• "..b.name.."\n  "..b.drop.."\n\n" end
S1:CreateParagraph({ Title="Sea 1 Boss Drops", Content=infoS1 })

S1:CreateSection("Quest & Items")

S1:CreateToggle({ Name="Auto Quest", CurrentValue=false, Flag="AQuestS1",
    Callback=function(v)
        CFG.AutoQuest = v
        if v then task.spawn(function()
            while CFG.AutoQuest do
                FireRemoteByKey("quest"); FireRemoteByKey("accept"); FireRemoteByKey("complete")
                task.wait(1.5)
            end
        end) end
    end })

S1:CreateToggle({ Name="Auto Collect Chests", CurrentValue=false, Flag="AChestS1",
    Callback=function(v)
        CFG.AutoChest = v
        if v then task.spawn(function()
            while CFG.AutoChest do
                for _,obj in pairs(Workspace:GetDescendants()) do
                    if not CFG.AutoChest then break end
                    if obj:IsA("Model") and obj.Name:lower():find("chest") then
                        local r = obj:FindFirstChildWhichIsA("BasePart")
                        if r then SafeTP(CFrame.new(r.Position+Vector3.new(0,3,0))); task.wait(0.2); FireInteract(obj) end
                    end
                end
                task.wait(1)
            end
        end) end
    end })

S1:CreateToggle({ Name="Auto Collect Ancient Fragments (Sea 2 Unlock)", CurrentValue=false, Flag="AFragS1",
    Callback=function(v)
        CFG.AutoFrag = v
        if v then
            Notify("BroXHub","Searching Fragments...\nSpawn 1.5min, despawn 5min.",5)
            task.spawn(function()
                while CFG.AutoFrag do
                    for _,obj in pairs(Workspace:GetDescendants()) do
                        if not CFG.AutoFrag then break end
                        local n = obj.Name:lower()
                        if obj:IsA("BasePart") and (n:find("ancient") or n:find("fragment") or n:find("relic")) then
                            SafeTP(CFrame.new(obj.Position+Vector3.new(0,3,0))); task.wait(0.2); FireInteract(obj)
                            Notify("🔮 Fragment!","Collected: "..obj.Name,4); task.wait(0.5)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end })

S1:CreateToggle({ Name="Auto Farm Map Pieces (7 needed)", CurrentValue=false, Flag="AMapS1",
    Callback=function(v)
        CFG.AutoMapPiece = v
        if v then task.spawn(function()
            while CFG.AutoMapPiece do
                for _,b in ipairs(SEA1_BOSSES) do
                    if not CFG.AutoMapPiece then break end
                    local boss = FindNearest(b.kw)
                    if boss then
                        local r = boss:FindFirstChild("HumanoidRootPart")
                        if r then SafeTP(r.CFrame * CFrame.new(0,0,-5)); task.wait(0.06); FireAttack(boss) end
                    end
                end
                task.wait(0.2)
            end
        end) end
    end })

S1:CreateSection("Island Teleport — Sea 1")
for _,isl in ipairs(SEA1_ISLANDS) do
    local d = isl
    S1:CreateButton({ Name="⚓ "..d.name.." (Lv "..d.lvl.."+)", Callback=function()
        local root = GetRoot(); if not root then return end
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(d.kw) then
                root.CFrame = CFrame.new(obj.Position+Vector3.new(0,10,0))
                Notify("BroXHub","⚓ "..d.name,3); return
            end
        end
        Notify("BroXHub","Not loaded: "..d.name,3)
    end })
end

local S2 = Window:CreateTab("⚡ Sea 2", 4483362458)

S2:CreateSection("Auto Mob Farm")

local s2Mobs = {}
for _,m in ipairs(SEA2_MOBS) do table.insert(s2Mobs, m) end
S2:CreateDropdown({ Name="Mob (Sea 2)", Options=s2Mobs, CurrentOption={"Bizarre Bandit"}, MultipleOptions=false, Flag="S2Mob",
    Callback=function(v) CFG.AutoFarmMob = type(v)=="table" and v[1] or v end })

S2:CreateToggle({ Name="Auto Farm Mob (Sea 2)", CurrentValue=false, Flag="AFarmS2",
    Callback=function(v)
        CFG.AutoFarm = v
        if v then task.spawn(function()
            while CFG.AutoFarm do
                local mob = FindNearest(CFG.AutoFarmMob)
                if mob then
                    local r = mob:FindFirstChild("HumanoidRootPart")
                    if r then SafeTP(r.CFrame * CFrame.new(0,0,-3.5)); task.wait(0.05); FireAttack(mob) end
                end
                task.wait(0.1)
            end
        end) end
    end })

S2:CreateSection("Boss Farm — Sea 2")

local s2BossNames = {}
for _,b in ipairs(SEA2_BOSSES) do table.insert(s2BossNames, b.name) end
S2:CreateDropdown({ Name="Boss (Sea 2)", Options=s2BossNames, CurrentOption={"Cosmic Being"}, MultipleOptions=false, Flag="S2Boss",
    Callback=function(v)
        local sel = type(v)=="table" and v[1] or v
        for _,b in ipairs(SEA2_BOSSES) do if b.name==sel then CFG.AutoBossKw=b.kw; break end end
    end })

S2:CreateToggle({ Name="Auto Farm Boss (Sea 2)", CurrentValue=false, Flag="ABossS2",
    Callback=function(v)
        CFG.AutoBoss = v
        if v then task.spawn(function()
            while CFG.AutoBoss do
                local boss = FindNearest(CFG.AutoBossKw)
                if boss then
                    local r = boss:FindFirstChild("HumanoidRootPart")
                    if r then SafeTP(r.CFrame * CFrame.new(0,0,-5)); task.wait(0.06); FireAttack(boss) end
                else task.wait(5) end
                task.wait(0.1)
            end
        end) end
    end })

S2:CreateButton({ Name="⚡ TP to Boss (Sea 2)", Callback=function()
    local boss = FindNearest(CFG.AutoBossKw)
    if boss then
        local r = boss:FindFirstChild("HumanoidRootPart")
        if r then SafeTP(r.CFrame * CFrame.new(0,0,-6)); Notify("BroXHub","TP → "..boss.Name,3) end
    else Notify("BroXHub","Boss not spawned.",3) end
end })

local infoS2 = ""
for _,b in ipairs(SEA2_BOSSES) do infoS2=infoS2.."• "..b.name.."\n  "..b.drop.."\n\n" end
S2:CreateParagraph({ Title="Sea 2 Boss Drops", Content=infoS2 })

S2:CreateSection("Sea Beast Farm")

S2:CreateToggle({ Name="Auto Kill Sea Beast (Kraken / Serpent)", CurrentValue=false, Flag="ASeaBeast",
    Callback=function(v)
        CFG.AutoSeaBeast = v
        if v then
            Notify("BroXHub","Sea Beast farm!\nNeed 500k+ Bounty\nSwim 200-600 studs from island.",5)
            task.spawn(function()
                while CFG.AutoSeaBeast do
                    local beast = FindNearest("kraken") or FindNearest("serpent") or FindNearest("sea beast")
                    if beast then
                        local r = beast:FindFirstChild("HumanoidRootPart")
                        if r then SafeTP(r.CFrame * CFrame.new(0,0,-6)); task.wait(0.05); FireAttack(beast) end
                    else task.wait(3) end
                    task.wait(0.12)
                end
            end)
        end
    end })

S2:CreateButton({ Name="TP → Kraken", Callback=function()
    local k = FindNearest("kraken")
    if k then local r=k:FindFirstChild("HumanoidRootPart"); if r then SafeTP(r.CFrame*CFrame.new(0,0,-8)); Notify("BroXHub","TP → Kraken",3) end
    else Notify("BroXHub","Kraken not found.",3) end
end })

S2:CreateButton({ Name="TP → Sea Serpent", Callback=function()
    local s = FindNearest("serpent")
    if s then local r=s:FindFirstChild("HumanoidRootPart"); if r then SafeTP(r.CFrame*CFrame.new(0,0,-8)); Notify("BroXHub","TP → Sea Serpent",3) end
    else Notify("BroXHub","Sea Serpent not found.",3) end
end })

S2:CreateSection("Quest & Dungeon")

S2:CreateToggle({ Name="Auto Quest (Sea 2)", CurrentValue=false, Flag="AQuestS2",
    Callback=function(v)
        if v then task.spawn(function()
            while v do
                FireRemoteByKey("quest"); FireRemoteByKey("accept"); FireRemoteByKey("complete")
                task.wait(1.5)
            end
        end) end
    end })

S2:CreateToggle({ Name="Auto Dungeon", CurrentValue=false, Flag="ADungeon",
    Callback=function(v)
        CFG.AutoDungeon = v
        if v then task.spawn(function()
            while CFG.AutoDungeon do
                FireRemoteByKey("dungeon"); FireRemoteByKey("raid"); FireRemoteByKey("enter")
                task.wait(0.5)
                for _,mob in pairs(Workspace:GetDescendants()) do
                    if not CFG.AutoDungeon then break end
                    if mob:IsA("Model") and mob.Name ~= LP.Name and not Players:FindFirstChild(mob.Name) then
                        local mHum = mob:FindFirstChildOfClass("Humanoid")
                        local mRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mHum and mHum.Health > 0 and mRoot then
                            SafeTP(mRoot.CFrame * CFrame.new(0,0,-3)); task.wait(0.05); FireAttack(mob)
                        end
                    end
                end
                task.wait(0.2)
            end
        end) end
    end })

S2:CreateSection("Island Teleport — Sea 2")
for _,isl in ipairs(SEA2_ISLANDS) do
    local d = isl
    S2:CreateButton({ Name="⚓ "..d.name.." (Lv "..d.lvl.."+)", Callback=function()
        local root = GetRoot(); if not root then return end
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(d.kw) then
                root.CFrame = CFrame.new(obj.Position+Vector3.new(0,10,0))
                Notify("BroXHub","⚓ "..d.name,3); return
            end
        end
        Notify("BroXHub","Not loaded: "..d.name,3)
    end })
end

S2:CreateSection("How to Unlock Sea 2")
S2:CreateParagraph({ Title="Sea 2 Unlock Steps", Content=
    "Requirements:\n• Level 12,500\n• Ascension V\n\n"..
    "Steps:\n1. Go to World Island (Sea 1)\n"..
    "2. Talk to Sea Traveler NPC\n"..
    "3. Collect 2 Ancient Fragments\n   (Spawn 1.5min, despawn 5min)\n"..
    "4. Get 7 Map Pieces from bosses\n"..
    "5. Return to Sea Traveler NPC\n"..
    "6. Enter Sea 2 door\n\n"..
    "💡 Door not opening? TP to World Island\n   and interact with Sea 2 door directly."
})

local SkillTab = Window:CreateTab("⚡ Skills", 4483362458)

SkillTab:CreateSection("Auto Skill Usage")

SkillTab:CreateToggle({ Name="Auto Use Skills (Spam All)", CurrentValue=false, Flag="AutoSkill",
    Callback=function(v)
        CFG.AutoSkill = v
        if v then task.spawn(function()
            while CFG.AutoSkill do
                for _,rem in pairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local n = rem.Name:lower()
                        if n:find("skill") or n:find("ability") or n:find("move") or n:find("cast") or n:find("use") then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
                task.wait(CFG.AutoSkillDelay)
            end
        end) end
    end })

SkillTab:CreateSlider({ Name="Skill Spam Delay (ms)", Range={50,500}, Increment=10, Suffix="ms", CurrentValue=100, Flag="SkillDelay",
    Callback=function(v) CFG.AutoSkillDelay = v/1000 end })

SkillTab:CreateSection("Fighting Style")

S_FightOpts = {}
for _,f in ipairs(FIGHT_STYLES) do table.insert(S_FightOpts, f) end
SkillTab:CreateDropdown({ Name="Fighting Style", Options=S_FightOpts, CurrentOption={"Yuji"}, MultipleOptions=false, Flag="FightStyleDrop",
    Callback=function(v) CFG.FightStyle = type(v)=="table" and v[1] or v end })

SkillTab:CreateToggle({ Name="Auto Spam Fighting Style Skills", CurrentValue=false, Flag="AutoFightStyle",
    Callback=function(v)
        CFG.AutoFightStyle = v
        if v then task.spawn(function()
            while CFG.AutoFightStyle do
                for _,rem in pairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local n = rem.Name:lower()
                        if n:find(CFG.FightStyle:lower()) or n:find("style") or n:find("technique") or n:find("combo") then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
                task.wait(0.12)
            end
        end) end
    end })

SkillTab:CreateToggle({ Name="Auto Equip Best Weapon", CurrentValue=false, Flag="AutoEquip",
    Callback=function(v)
        CFG.AutoEquipWeapon = v
        if v then task.spawn(function()
            while CFG.AutoEquipWeapon do
                local char = LP.Character
                if char then
                    for _,tool in pairs(LP.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find(CFG.SelectedWeapon:lower()) then
                            tool.Parent = char
                        end
                    end
                end
                task.wait(1)
            end
        end) end
    end })

local weapOpts = {}
for _,w in ipairs(WEAPONS) do table.insert(weapOpts, w) end
SkillTab:CreateDropdown({ Name="Selected Weapon", Options=weapOpts, CurrentOption={"Dragon Goddess"}, MultipleOptions=false, Flag="WeaponDrop",
    Callback=function(v) CFG.SelectedWeapon = type(v)=="table" and v[1] or v end })

SkillTab:CreateSection("Haki System")

SkillTab:CreateParagraph({ Title="Haki Info", Content=
    "Observation Haki:\n• Dodge attacks automatically\n• See enemy HP bars\n• Predict movements\n• Required for Haki V2/V3\n\n"..
    "Armament Haki:\n• Damage Logia users\n• Coat weapons in black Haki\n• Increase attack damage\n• Essential for PvP/PvE"
})

SkillTab:CreateToggle({ Name="Auto Train Observation Haki", CurrentValue=false, Flag="AutoObsHaki",
    Callback=function(v)
        CFG.AutoHakiObs = v
        if v then task.spawn(function()
            while CFG.AutoHakiObs do
                FireRemoteByKey("observation"); FireRemoteByKey("obs_haki"); FireRemoteByKey("mantra")
                FireRemoteByKey("haki", "observation"); FireRemoteByKey("trainobs")
                task.wait(0.4)
            end
        end) end
    end })

SkillTab:CreateToggle({ Name="Auto Train Armament Haki", CurrentValue=false, Flag="AutoArmHaki",
    Callback=function(v)
        CFG.AutoHakiArm = v
        if v then task.spawn(function()
            while CFG.AutoHakiArm do
                FireRemoteByKey("armament"); FireRemoteByKey("arm_haki"); FireRemoteByKey("buso")
                FireRemoteByKey("haki", "armament"); FireRemoteByKey("trainarm")
                task.wait(0.35)
            end
        end) end
    end })

SkillTab:CreateToggle({ Name="Auto Unlock Haki V2", CurrentValue=false, Flag="AutoHakiV2",
    Callback=function(v)
        CFG.AutoHakiV2 = v
        if v then task.spawn(function()
            while CFG.AutoHakiV2 do
                FireRemoteByKey("haki_v2"); FireRemoteByKey("hakiv2"); FireRemoteByKey("upgradehaki")
                task.wait(1)
            end
        end) end
    end })

SkillTab:CreateToggle({ Name="Auto Unlock Haki V3 (Conqueror)", CurrentValue=false, Flag="AutoHakiV3",
    Callback=function(v)
        CFG.AutoHakiV3 = v
        if v then task.spawn(function()
            while CFG.AutoHakiV3 do
                FireRemoteByKey("haki_v3"); FireRemoteByKey("hakiv3"); FireRemoteByKey("conqueror")
                task.wait(1)
            end
        end) end
    end })

SkillTab:CreateSection("Mastery & Ascension")

SkillTab:CreateToggle({ Name="Auto Mastery (Weapon / Fruit)", CurrentValue=false, Flag="AutoMastery",
    Callback=function(v)
        if v then task.spawn(function()
            while v do
                FireRemoteByKey("mastery"); FireRemoteByKey("exp"); FireRemoteByKey("xp")
                task.wait(0.5)
            end
        end) end
    end })

SkillTab:CreateToggle({ Name="Auto Ascend", CurrentValue=false, Flag="AutoAscend",
    Callback=function(v)
        CFG.AutoAscend = v
        if v then task.spawn(function()
            while CFG.AutoAscend do
                FireRemoteByKey("ascend"); FireRemoteByKey("ascension"); FireRemoteByKey("breakthrough")
                task.wait(1)
            end
        end) end
    end })

SkillTab:CreateSection("Auto Stats & States")

SkillTab:CreateDropdown({ Name="Stat Focus", Options={"Melee","Sword","Defense","Speed","Power","Endurance"}, CurrentOption={"Melee"}, MultipleOptions=false, Flag="StatFocus",
    Callback=function(v) CFG.StatType = type(v)=="table" and v[1] or v end })

SkillTab:CreateToggle({ Name="Auto Allocate Stats", CurrentValue=false, Flag="AutoStats",
    Callback=function(v)
        CFG.AutoStat = v
        if v then task.spawn(function()
            while CFG.AutoStat do
                FireRemoteByKey("stat", CFG.StatType); FireRemoteByKey("upgrade", CFG.StatType)
                FireRemoteByKey("addpoint", CFG.StatType); FireRemoteByKey("invest", CFG.StatType)
                task.wait(0.3)
            end
        end) end
    end })

SkillTab:CreateDropdown({ Name="Reroll Target", Options={"Demonic","Dragon","Celestial","Yonko","Pirate King","Ancient","Legendary"}, CurrentOption={"Demonic"}, MultipleOptions=false, Flag="RerollTarget",
    Callback=function(v) CFG.RerollTarget = type(v)=="table" and v[1] or v end })

SkillTab:CreateToggle({ Name="Auto Reroll Until Target", CurrentValue=false, Flag="AutoReroll",
    Callback=function(v)
        CFG.AutoReroll = v
        if v then task.spawn(function()
            local count = 0
            while CFG.AutoReroll do
                count = count + 1
                FireRemoteByKey("reroll"); FireRemoteByKey("spin"); FireRemoteByKey("trait"); FireRemoteByKey("clan")
                local ls = LP:FindFirstChild("leaderstats")
                if ls then
                    for _,val in pairs(ls:GetChildren()) do
                        if tostring(val.Value):lower():find(CFG.RerollTarget:lower()) then
                            CFG.AutoReroll = false
                            Notify("🎉 Got "..CFG.RerollTarget.."!","After "..count.." rolls!",8)
                            return
                        end
                    end
                end
                task.wait(0.4)
            end
        end) end
    end })

SkillTab:CreateSection("Recommended Builds")
SkillTab:CreateParagraph({ Title="PvE Endgame (Auto Farm)", Content=
    "Stat: 100% Melee\nStyle: Cosmic Being (Sea 2)\nWeapon: Dragon Goddess\nHaki: V2 Armament + V3 Conqueror\nBloodline: Demonic\nGoal: Max Kill Aura + Auto Farm loop"
})
SkillTab:CreateParagraph({ Title="Sword Build", Content=
    "Stat: 70% Sword + 30% Power\nWeapon: Dragon Goddess / Yamato\nStyle: The World (Sea 2)\nHaki: V2 Observation + Armament\nFarm: Kraken + Sea Serpent"
})
SkillTab:CreateParagraph({ Title="Sea 2 Progression Order", Content=
    "1. Lv 12,500 + Ascension V\n2. Unlock Sea 2 via World Island\n3. Farm Bizarre Island mobs\n4. Unlock Cosmic Being (Punch Island)\n5. Farm Dragon Goddess boss\n6. Hunt Kraken + Sea Serpent\n7. Build Guilds + Bloodlines + Relics"
})

local CrystalTab = Window:CreateTab("💎 Crystal Defense", 4483362458)

CrystalTab:CreateSection("Crystal Defense — Punch Island")
CrystalTab:CreateParagraph({ Title="Crystal Defense Info", Content=
    "Location: Punch Island (Sea 2, Lv 14,500+)\n"..
    "• Kill waves of enemies → earn Crystal Coins\n"..
    "• 5,000 Crystal Coins = Anti-Magic Sword\n"..
    "• Infinite Tower: 7,500 floors → Brilliant Aura\n"..
    "• Infinite Tower: 10,000 floors → Primordial Aura\n"..
    "• New Auras: Destroyer (+12.5% DMG), Demonic (+15% DMG)\n"..
    "• Dragon Goddess pity: 150 → 110 pulls\n"..
    "• World Boss drop rates increased"
})

CrystalTab:CreateToggle({ Name="Auto Crystal Defense (Wave Clear)", CurrentValue=false, Flag="AutoCrystal",
    Callback=function(v)
        CFG.AutoCrystal = v
        if v then task.spawn(function()
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("punch") then
                    SafeTP(CFrame.new(obj.Position+Vector3.new(0,5,0))); break
                end
            end
            task.wait(1)
            while CFG.AutoCrystal do
                FireRemoteByKey("crystal"); FireRemoteByKey("defense"); FireRemoteByKey("wave")
                task.wait(0.5)
                for _,mob in pairs(Workspace:GetDescendants()) do
                    if not CFG.AutoCrystal then break end
                    if mob:IsA("Model") and mob.Name ~= LP.Name and not Players:FindFirstChild(mob.Name) then
                        local mHum = mob:FindFirstChildOfClass("Humanoid")
                        local mRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mHum and mHum.Health > 0 and mRoot then
                            SafeTP(mRoot.CFrame * CFrame.new(0,0,-3)); task.wait(0.05); FireAttack(mob)
                        end
                    end
                end
                task.wait(0.3)
            end
        end) end
    end })

CrystalTab:CreateToggle({ Name="Auto Collect Crystal Coins", CurrentValue=false, Flag="CrystalCoin",
    Callback=function(v)
        CFG.CrystalCoin = v
        if v then task.spawn(function()
            while CFG.CrystalCoin do
                for _,obj in pairs(Workspace:GetDescendants()) do
                    if not CFG.CrystalCoin then break end
                    local n = obj.Name:lower()
                    if obj:IsA("BasePart") and (n:find("crystal") or n:find("coin") or n:find("credit")) then
                        SafeTP(CFrame.new(obj.Position+Vector3.new(0,3,0))); task.wait(0.1); FireInteract(obj)
                    end
                end
                task.wait(0.5)
            end
        end) end
    end })

CrystalTab:CreateToggle({ Name="Auto Spam Skills in Crystal Defense", CurrentValue=false, Flag="CrystalSpam",
    Callback=function(v)
        if v then task.spawn(function()
            while v do
                for _,rem in pairs(ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") then
                        local n = rem.Name:lower()
                        if n:find("skill") or n:find("ability") or n:find("q") or n:find("e") or n:find("r") then
                            pcall(function() rem:FireServer() end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end) end
    end })

CrystalTab:CreateSection("Infinite Tower")

CrystalTab:CreateToggle({ Name="Auto Infinite Tower Farm", CurrentValue=false, Flag="AutoInfTower",
    Callback=function(v)
        CFG.AutoInfTower = v
        if v then task.spawn(function()
            while CFG.AutoInfTower do
                FireRemoteByKey("tower"); FireRemoteByKey("floor"); FireRemoteByKey("infinite")
                task.wait(0.5)
                for _,mob in pairs(Workspace:GetDescendants()) do
                    if not CFG.AutoInfTower then break end
                    if mob:IsA("Model") and mob.Name ~= LP.Name and not Players:FindFirstChild(mob.Name) then
                        local mHum = mob:FindFirstChildOfClass("Humanoid")
                        local mRoot = mob:FindFirstChild("HumanoidRootPart")
                        if mHum and mHum.Health > 0 and mRoot then
                            SafeTP(mRoot.CFrame * CFrame.new(0,0,-3)); task.wait(0.05); FireAttack(mob)
                        end
                    end
                end
                task.wait(0.15)
            end
        end) end
    end })

local FruitTab = Window:CreateTab("🍎 Devil Fruit", 4483362458)

FruitTab:CreateSection("Fruit Finder")

FruitTab:CreateToggle({ Name="Devil Fruit ESP", CurrentValue=false, Flag="FruitESP",
    Callback=function(v)
        CFG.FruitESP = v; ClearESP("FrESP")
        if v then
            for _,obj in pairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if obj:IsA("BasePart") and (n:find("fruit") or n:find("devil") or n:find("akuma")) then
                    local sel = Instance.new("SelectionBox")
                    sel.Adornee=obj; sel.Color3=Color3.fromRGB(255,80,255); sel.LineThickness=0.07; sel.Parent=obj
                    if not ESPStore["FrESP"] then ESPStore["FrESP"]={} end
                    table.insert(ESPStore["FrESP"], sel)
                    AddBB(obj, "🍎 "..obj.Name, Color3.fromRGB(255,150,255), "FrESP", 4)
                end
            end
        end
    end })

FruitTab:CreateToggle({ Name="Fruit Spawn Notification", CurrentValue=false, Flag="FruitNotif",
    Callback=function(v)
        CFG.FruitNotif = v
        if v then
            Workspace.DescendantAdded:Connect(function(obj)
                if not CFG.FruitNotif then return end
                local n = obj.Name:lower()
                if obj:IsA("BasePart") and (n:find("fruit") or n:find("devil")) then
                    Notify("🍎 Fruit Spawned!", obj.Name.."\nActivate Fruit Sniper!", 8)
                end
            end)
        end
    end })

FruitTab:CreateToggle({ Name="Fruit Sniper (Auto TP + Grab)", CurrentValue=false, Flag="FruitSniper",
    Callback=function(v)
        CFG.FruitSniper = v
        if v then
            Workspace.DescendantAdded:Connect(function(obj)
                if not CFG.FruitSniper then return end
                local n = obj.Name:lower()
                if obj:IsA("BasePart") and (n:find("fruit") or n:find("devil")) then
                    task.wait(0.1)
                    SafeTP(CFrame.new(obj.Position+Vector3.new(0,4,0))); task.wait(0.1)
                    FireInteract(obj); Notify("🍎 Sniped!", obj.Name, 4)
                end
            end)
        end
    end })

FruitTab:CreateToggle({ Name="Auto Eat Fruit (Auto Collect)", CurrentValue=false, Flag="AutoEatFruit",
    Callback=function(v)
        CFG.AutoEatFruit = v
        if v then task.spawn(function()
            while CFG.AutoEatFruit do
                for _,obj in pairs(Workspace:GetDescendants()) do
                    if not CFG.AutoEatFruit then break end
                    local n = obj.Name:lower()
                    if obj:IsA("BasePart") and (n:find("fruit") or n:find("devil") or n:find("akuma")) then
                        SafeTP(CFrame.new(obj.Position+Vector3.new(0,4,0))); task.wait(0.2)
                        FireRemoteByKey("eat"); FireRemoteByKey("consume"); FireRemoteByKey("fruit"); FireInteract(obj)
                        task.wait(0.5)
                    end
                end
                task.wait(1)
            end
        end) end
    end })

FruitTab:CreateSection("Fruit Tier List")
FruitTab:CreateParagraph({ Title="Devil Fruit Tiers", Content=
    "S+ Tier:\n• Quake — AoE Damage\n• Light — Speed + Laser\n• Dark — Gravity\n• Magma — Highest Damage\n\n"..
    "S Tier:\n• Rubber — Gum-Gum Attacks\n• Ice — Freeze + Flight\n• Flame — Fire AoE\n• String — Birdcage\n\n"..
    "A Tier:\n• Sand — Desert Spada\n• Shadow — Nightmare Mode\n• Smoke — Screen\n• Spring — Bounce\n\n"..
    "B Tier:\n• Bomb, Chop, Slip, Wax"
})

local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({ Name="Player ESP", CurrentValue=false, Flag="ESPPly",
    Callback=function(v) CFG.ESPPlayers=v; RefreshPlayerESP(v) end })

ESPTab:CreateToggle({ Name="Show Names", CurrentValue=false, Flag="ShowNames",
    Callback=function(v) CFG.ShowNames=v; RefreshPlayerESP(CFG.ESPPlayers) end })

ESPTab:CreateToggle({ Name="Show HP", CurrentValue=false, Flag="ShowHP",
    Callback=function(v) CFG.ShowHP=v; RefreshPlayerESP(CFG.ESPPlayers) end })

ESPTab:CreateToggle({ Name="Show Distance", CurrentValue=false, Flag="ShowDist",
    Callback=function(v) CFG.ShowDist=v end })

ESPTab:CreateColorPicker({ Name="Player ESP Color", Color=Color3.fromRGB(80,160,255), Flag="PlyESPCol",
    Callback=function(c)
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hl = p.Character:FindFirstChild("BX_HL_Ply")
                if hl then hl.FillColor=c; hl.OutlineColor=c end
            end
        end
    end })

ESPTab:CreateSection("World ESP")

ESPTab:CreateToggle({ Name="Mob ESP (Red)", CurrentValue=false, Flag="ESPMob",
    Callback=function(v)
        CFG.ESPMobs=v; ClearESP("MobE")
        if v then
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and not Players:FindFirstChild(obj.Name) and obj.Name ~= LP.Name then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then AddHL(obj, Color3.fromRGB(255,100,100), Color3.fromRGB(200,0,0), "MobE") end
                end
            end
        end
    end })

ESPTab:CreateToggle({ Name="Boss ESP (Orange)", CurrentValue=false, Flag="ESPBoss",
    Callback=function(v)
        CFG.ESPBoss=v; ClearESP("BossE")
        if v then
            local allKws = {}
            for _,b in ipairs(SEA1_BOSSES) do table.insert(allKws, b.kw) end
            for _,b in ipairs(SEA2_BOSSES) do table.insert(allKws, b.kw) end
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local n = obj.Name:lower()
                    for _,kw in ipairs(allKws) do
                        if n:find(kw) then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                AddHL(obj, Color3.fromRGB(255,165,0), Color3.fromRGB(255,80,0), "BossE", 0.35)
                                local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                                if r then AddBB(r, "👑 "..obj.Name.."\n❤️ "..math.floor(hum.Health), Color3.fromRGB(255,165,0), "BossE", 9) end
                            end
                            break
                        end
                    end
                end
            end
        end
    end })

ESPTab:CreateToggle({ Name="Sea Beast ESP (Cyan)", CurrentValue=false, Flag="ESPSBeast",
    Callback=function(v)
        CFG.ESPSeaBeast=v; ClearESP("SBE")
        if v then
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local n = obj.Name:lower()
                    if n:find("kraken") or n:find("serpent") or n:find("sea beast") then
                        AddHL(obj, Color3.fromRGB(0,200,255), Color3.fromRGB(0,100,220), "SBE", 0.4)
                        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if r then AddBB(r, "🌊 "..obj.Name, Color3.fromRGB(0,220,255), "SBE", 11) end
                    end
                end
            end
        end
    end })

ESPTab:CreateToggle({ Name="Chest ESP (Gold)", CurrentValue=false, Flag="ESPChest",
    Callback=function(v)
        CFG.ESPChest=v; ClearESP("ChE")
        if v then
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("chest") then
                    AddHL(obj, Color3.fromRGB(255,215,0), Color3.fromRGB(200,160,0), "ChE")
                    local r = obj:FindFirstChildWhichIsA("BasePart")
                    if r then AddBB(r, "📦 "..obj.Name, Color3.fromRGB(255,215,0), "ChE", 5) end
                end
            end
        end
    end })

ESPTab:CreateToggle({ Name="Ancient Fragment ESP (Purple)", CurrentValue=false, Flag="ESPFrag",
    Callback=function(v)
        CFG.ESPFrag=v; ClearESP("FgE")
        if v then
            for _,obj in pairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if obj:IsA("BasePart") and (n:find("fragment") or n:find("ancient") or n:find("relic")) then
                    local sel = Instance.new("SelectionBox")
                    sel.Adornee=obj; sel.Color3=Color3.fromRGB(160,0,255); sel.LineThickness=0.07; sel.Parent=obj
                    if not ESPStore["FgE"] then ESPStore["FgE"]={} end
                    table.insert(ESPStore["FgE"], sel)
                    AddBB(obj, "🔮 Fragment!", Color3.fromRGB(200,80,255), "FgE", 4)
                end
            end
        end
    end })

local ShipTab = Window:CreateTab("🚢 Ship & Sail", 4483362458)

ShipTab:CreateSection("Ship Control")

ShipTab:CreateToggle({ Name="Ship Speed Boost", CurrentValue=false, Flag="ShipSpd",
    Callback=function(v)
        CFG.ShipSpeed = v
        task.spawn(function()
            for _,obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
                    if obj.Occupant and obj.Occupant.Parent == LP.Character then
                        local ex = obj:FindFirstChild("BX_ShipV")
                        if v and not ex then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name="BX_ShipV"; bv.MaxForce=Vector3.new(9e9,0,9e9)
                            bv.Velocity=obj.CFrame.LookVector*200; bv.Parent=obj
                        elseif not v and ex then ex:Destroy() end
                    end
                end
            end
        end)
    end })

ShipTab:CreateToggle({ Name="Anti Sink", CurrentValue=false, Flag="AntiSink",
    Callback=function(v)
        CFG.AntiSink = v
        if v then task.spawn(function()
            while CFG.AntiSink do
                for _,obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("ship") or obj.Name:lower():find("boat")) then
                        local base = obj:FindFirstChildWhichIsA("BasePart")
                        if base and base.Position.Y < 3 then
                            base.CFrame = CFrame.new(base.Position.X, 3, base.Position.Z)
                        end
                    end
                end
                task.wait(0.5)
            end
        end) end
    end })

ShipTab:CreateSection("Quick Island TP — Sea 1")
for _,isl in ipairs(SEA1_ISLANDS) do
    local d = isl
    ShipTab:CreateButton({ Name="⚓ "..d.name, Callback=function()
        local root = GetRoot(); if not root then return end
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(d.kw) then
                root.CFrame = CFrame.new(obj.Position+Vector3.new(0,10,0)); Notify("BroXHub","⚓ "..d.name,3); return
            end
        end
        Notify("BroXHub","Not loaded: "..d.name,3)
    end })
end

ShipTab:CreateSection("Quick Island TP — Sea 2")
for _,isl in ipairs(SEA2_ISLANDS) do
    local d = isl
    ShipTab:CreateButton({ Name="⚓ "..d.name, Callback=function()
        local root = GetRoot(); if not root then return end
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(d.kw) then
                root.CFrame = CFrame.new(obj.Position+Vector3.new(0,10,0)); Notify("BroXHub","⚓ "..d.name,3); return
            end
        end
        Notify("BroXHub","Not loaded: "..d.name,3)
    end })
end

local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

CombatTab:CreateSection("Kill Aura")

CombatTab:CreateToggle({ Name="Kill Aura", CurrentValue=false, Flag="KillAura",
    Callback=function(v) CFG.KillAura=v end })

CombatTab:CreateSlider({ Name="Kill Aura Range", Range={5,100}, Increment=1, Suffix=" studs", CurrentValue=25, Flag="KARange",
    Callback=function(v) CFG.KillAuraRange=v end })

CombatTab:CreateSection("Player Health")

CombatTab:CreateToggle({ Name="God Mode", CurrentValue=false, Flag="GodMode",
    Callback=function(v)
        CFG.GodMode=v
        local hum = GetHum()
        if hum and v then hum.MaxHealth=math.huge; hum.Health=math.huge end
    end })

CombatTab:CreateToggle({ Name="Infinite Health", CurrentValue=false, Flag="InfHealth",
    Callback=function(v) CFG.InfHealth=v end })

CombatTab:CreateToggle({ Name="Auto Heal (HP < 40%)", CurrentValue=false, Flag="AutoHeal",
    Callback=function(v) CFG.AutoHeal=v end })

CombatTab:CreateButton({ Name="💚 Full Heal Now", Callback=function()
    local hum = GetHum(); if hum then hum.Health=hum.MaxHealth; Notify("BroXHub","Healed!",2) end
end })

CombatTab:CreateSection("Player Physics")

CombatTab:CreateToggle({ Name="Speed Hack", CurrentValue=false, Flag="SpeedHack",
    Callback=function(v)
        CFG.SpeedEnabled=v
        local hum = GetHum(); if hum then hum.WalkSpeed = v and CFG.Speed or 16 end
    end })

CombatTab:CreateSlider({ Name="Walk Speed", Range={16,500}, Increment=1, Suffix=" spd", CurrentValue=16, Flag="WalkSpd",
    Callback=function(v)
        CFG.Speed=v
        if CFG.SpeedEnabled then local hum=GetHum(); if hum then hum.WalkSpeed=v end end
    end })

CombatTab:CreateToggle({ Name="High Jump", CurrentValue=false, Flag="HighJump",
    Callback=function(v)
        CFG.HighJump=v
        local hum=GetHum(); if hum then hum.JumpPower = v and CFG.JumpPower or 50 end
    end })

CombatTab:CreateSlider({ Name="Jump Power", Range={50,1000}, Increment=10, Suffix=" pwr", CurrentValue=50, Flag="JumpPwr",
    Callback=function(v)
        CFG.JumpPower=v
        if CFG.HighJump then local hum=GetHum(); if hum then hum.JumpPower=v end end
    end })

CombatTab:CreateToggle({ Name="Noclip", CurrentValue=false, Flag="Noclip",
    Callback=function(v) CFG.Noclip=v end })

CombatTab:CreateToggle({ Name="Infinite Stamina", CurrentValue=false, Flag="InfStam",
    Callback=function(v) CFG.InfStamina=v end })

CombatTab:CreateToggle({ Name="No Fall Damage", CurrentValue=false, Flag="NoFall",
    Callback=function(v) CFG.NoFall=v end })

CombatTab:CreateToggle({ Name="Fly (WASD + Space / LCtrl)", CurrentValue=false, Flag="Fly",
    Callback=function(v)
        CFG.Fly=v
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        if v then
            local bg = Instance.new("BodyGyro"); bg.Name="BX_FG"; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.P=9e9; bg.Parent=root
            local bv = Instance.new("BodyVelocity"); bv.Name="BX_FV"; bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=root
        else
            local bg=root:FindFirstChild("BX_FG"); if bg then bg:Destroy() end
            local bv=root:FindFirstChild("BX_FV"); if bv then bv:Destroy() end
        end
    end })

CombatTab:CreateSlider({ Name="Fly Speed", Range={20,500}, Increment=5, Suffix=" spd", CurrentValue=80, Flag="FlySpd",
    Callback=function(v) CFG.FlySpeed=v end })

CombatTab:CreateSection("Target")

CombatTab:CreateInput({ Name="TP to Player", PlaceholderText="Username...", RemoveTextAfterFocusLost=false, Flag="TPPly",
    Callback=function(v)
        local p = Players:FindFirstChild(v)
        if p and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then SafeTP(r.CFrame*CFrame.new(0,0,-4)); Notify("BroXHub","TP → "..p.Name,3) end
        else Notify("BroXHub","Player not found.",3) end
    end })

CombatTab:CreateButton({ Name="TP to Nearest Player", Callback=function()
    local root=GetRoot(); if not root then return end
    local best,bd=nil,math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local pr=p.Character:FindFirstChild("HumanoidRootPart")
            if pr then local d=(root.Position-pr.Position).Magnitude; if d<bd then bd=d; best=p end end
        end
    end
    if best then
        local pr=best.Character:FindFirstChild("HumanoidRootPart")
        if pr then SafeTP(pr.CFrame*CFrame.new(0,0,-4)); Notify("BroXHub","TP → "..best.Name,3) end
    else Notify("BroXHub","No players found.",3) end
end })

CombatTab:CreateButton({ Name="TP to Quest NPC", Callback=function()
    local root=GetRoot(); if not root then return end
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n=obj.Name:lower()
            if n:find("quest") or n:find("npc") or n:find("traveler") or n:find("giver") then
                local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if r then SafeTP(CFrame.new(r.Position+Vector3.new(0,3,3))); Notify("BroXHub","TP → "..obj.Name,3); return end
            end
        end
    end
    Notify("BroXHub","No Quest NPC found.",3)
end })

local VisualTab = Window:CreateTab("🎨 Visual", 4483362458)

VisualTab:CreateSection("World")

VisualTab:CreateToggle({ Name="Fullbright", CurrentValue=false, Flag="Fullbright",
    Callback=function(v)
        CFG.Fullbright=v; Lighting.Brightness=v and 10 or 2
        Lighting.ClockTime=v and 14 or Lighting.ClockTime; Lighting.GlobalShadows=not v
    end })

VisualTab:CreateToggle({ Name="No Fog", CurrentValue=false, Flag="NoFog",
    Callback=function(v)
        CFG.NoFog=v; Lighting.FogEnd=v and 100000 or 1500; Lighting.FogStart=v and 100000 or 0
    end })

VisualTab:CreateToggle({ Name="FPS Boost (Disable Particles)", CurrentValue=false, Flag="FPSBoost",
    Callback=function(v)
        CFG.FPSBoost=v
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = not v
            end
        end
        for _,fx in pairs(Lighting:GetDescendants()) do
            if fx:IsA("Atmosphere") then fx.Density=v and 0 or 0.395 end
        end
    end })

VisualTab:CreateToggle({ Name="No Shaders", CurrentValue=false, Flag="NoShaders",
    Callback=function(v)
        for _,fx in pairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect")
            or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then fx.Enabled=not v end
        end
    end })

VisualTab:CreateSection("Camera")

VisualTab:CreateSlider({ Name="Field of View", Range={70,120}, Increment=1, Suffix="°", CurrentValue=70, Flag="FOV",
    Callback=function(v) Camera.FieldOfView=v end })

local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateSection("Utility")

MiscTab:CreateToggle({ Name="Anti AFK", CurrentValue=false, Flag="AntiAFK",
    Callback=function(v)
        CFG.AntiAFK=v
        if v then LP.Idled:Connect(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end) end
    end })

MiscTab:CreateToggle({ Name="Auto Respawn", CurrentValue=false, Flag="AutoRespawn",
    Callback=function(v)
        CFG.AutoRespawn=v
        if v then task.spawn(function()
            while CFG.AutoRespawn do
                local hum=GetHum()
                if hum and hum.Health <= 0 then
                    FireRemoteByKey("respawn"); FireRemoteByKey("revive"); task.wait(0.5)
                end
                task.wait(0.3)
            end
        end) end
    end })

MiscTab:CreateButton({ Name="📊 Show My Stats", Callback=function()
    local hum=GetHum()
    local hp=hum and (math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)) or "N/A"
    local ls=LP:FindFirstChild("leaderstats")
    local lvl,beli,bounty=0,0,0
    if ls then
        for _,val in pairs(ls:GetChildren()) do
            local n=val.Name:lower()
            if n:find("level") or n:find("lv") then lvl=val.Value end
            if n:find("beli") or n:find("gold") or n:find("money") then beli=val.Value end
            if n:find("bounty") or n:find("honor") then bounty=val.Value end
        end
    end
    Notify("📊 "..LP.Name, "Level: "..lvl.."\nBeli: "..beli.."\nBounty: "..bounty.."\nHP: "..hp, 7)
end })

MiscTab:CreateButton({ Name="🌐 Server Player List", Callback=function()
    local info="Players ("..#Players:GetPlayers().."):\n"
    for _,p in pairs(Players:GetPlayers()) do info=info.."• "..p.Name.."\n" end
    Notify("🌐 Server", info, 8)
end })

MiscTab:CreateButton({ Name="🔁 Rejoin Server", Callback=function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end })

MiscTab:CreateSection("Interface")

MiscTab:CreateKeybind({ Name="Show BroX", CurrentKeybind="RightAlt", HoldToInteract=false, Flag="ShowBroX",
    Callback=function() Rayfield:Toggle() end })

MiscTab:CreateButton({ Name="Save Config", Callback=function() Notify("BroXHub","Config saved!",2) end })

MiscTab:CreateButton({ Name="Reset Settings", Callback=function()
    for k,v in pairs(CFG) do if type(v)=="boolean" then CFG[k]=false end end
    Notify("BroXHub","Settings reset.",2)
end })

MiscTab:CreateParagraph({ Title="BroXHub — Sailor Piece", Content=
    "Version   : 4.0\n"..
    "Update    : Anti-Magic (April 2026)\n"..
    "Max Level : 16,000\n"..
    "Sea 2     : Lv 12,500 + Ascension V\n\n"..
    "Tabs: Sea 1 | Sea 2 | Skills | Crystal\n"..
    "      Devil Fruit | ESP | Ship | Combat\n"..
    "      Visual | Misc\n\n"..
    "Toggle: Right Alt / Show BroX"
})

RunService.RenderStepped:Connect(function()
    if CFG.Fly then
        local root=GetRoot()
        if root then
            local bv=root:FindFirstChild("BX_FV"); local bg=root:FindFirstChild("BX_FG")
            if bv and bg then
                bg.CFrame=Camera.CFrame
                local vel=Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel+=Camera.CFrame.LookVector *CFG.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel-=Camera.CFrame.LookVector *CFG.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel-=Camera.CFrame.RightVector*CFG.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel+=Camera.CFrame.RightVector*CFG.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then vel+=Vector3.new(0,CFG.FlySpeed,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel-=Vector3.new(0,CFG.FlySpeed,0) end
                bv.Velocity=vel
            end
        end
    end
    if CFG.ESPPlayers then
        local root=GetRoot()
        if root then
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local head=p.Character:FindFirstChild("Head")
                    if head then
                        local bb=head:FindFirstChild("BX_BB_Ply")
                        if bb then
                            local lbl=bb:FindFirstChildOfClass("TextLabel")
                            if lbl then
                                local hum=p.Character:FindFirstChildOfClass("Humanoid")
                                local txt=p.Name
                                if CFG.ShowHP and hum then txt=txt.."\n❤️ "..math.floor(hum.Health) end
                                if CFG.ShowDist then txt=txt.."\n📏 "..math.floor((root.Position-head.Position).Magnitude).."m" end
                                lbl.Text=txt
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart")

    if CFG.Noclip then
        for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
    if CFG.SpeedEnabled and hum then hum.WalkSpeed=CFG.Speed end
    if CFG.GodMode and hum then hum.MaxHealth=math.huge; hum.Health=math.huge end
    if CFG.InfHealth and hum then if hum.Health < hum.MaxHealth then hum.Health=hum.MaxHealth end end
    if CFG.AutoHeal and hum then if hum.Health < hum.MaxHealth*0.4 then hum.Health=hum.MaxHealth end end
    if CFG.NoFall and hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
    if CFG.InfStamina and hum then
        for _,v in pairs(hum:GetChildren()) do
            if v:IsA("NumberValue") then
                local n=v.Name:lower()
                if n:find("stam") or n:find("energy") or n:find("ki") then if v.Value<40 then v.Value=100 end end
            end
        end
    end
    if CFG.KillAura and root then
        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name ~= LP.Name and not Players:FindFirstChild(obj.Name) then
                local mHum=obj:FindFirstChildOfClass("Humanoid"); local mRoot=obj:FindFirstChild("HumanoidRootPart")
                if mHum and mHum.Health > 0 and mRoot then
                    if (root.Position-mRoot.Position).Magnitude <= CFG.KillAuraRange then FireAttack(obj) end
                end
            end
        end
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        local n=obj.Name:lower()
        if n:find("fragment") or n:find("ancient") then
            Notify("🔮 Fragment!","Spawned: "..obj.Name.."\nAuto Collect it!",5)
        end
    end
    if obj:IsA("Model") then
        local n=obj.Name:lower()
        local bossKws={"kraken","serpent","cosmic being","dragon goddess","solo hunter","true aizen","yamato","blessed maiden"}
        for _,kw in ipairs(bossKws) do
            if n:find(kw) then Notify("👑 Boss Spawned!",obj.Name.." appeared!",5); break end
        end
    end
end)

LP.CharacterAdded:Connect(function(c)
    Character=c; task.wait(1.5)
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then
        if CFG.SpeedEnabled then h.WalkSpeed=CFG.Speed end
        if CFG.HighJump then h.JumpPower=CFG.JumpPower end
        if CFG.GodMode then h.MaxHealth=math.huge; h.Health=math.huge end
    end
    if CFG.Fly then
        local root=c:FindFirstChild("HumanoidRootPart")
        if root then
            local bg=Instance.new("BodyGyro"); bg.Name="BX_FG"; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.P=9e9; bg.Parent=root
            local bv=Instance.new("BodyVelocity"); bv.Name="BX_FV"; bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=root
        end
    end
    task.wait(0.5); if CFG.ESPPlayers then RefreshPlayerESP(true) end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(1)
        if CFG.ESPPlayers then
            AddHL(c, Color3.fromRGB(80,160,255), Color3.fromRGB(0,100,220), "Ply")
            local head=c:FindFirstChild("Head")
            if head then AddBB(head, p.Name, Color3.fromRGB(120,200,255), "Ply", 3) end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p) ClearESP(p.Name) end)

task.wait(2)
Notify("✅ BroXHub Loaded!","Sailor Piece v4.0 | Anti-Magic 2026\nRight Alt = Toggle UI",7)
