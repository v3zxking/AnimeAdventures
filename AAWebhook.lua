if getgenv().GbrlExec then
    return
end
if not getgenv().GabrielWebhook then
    print("[Gabriel WH] [⚙️]: Missing configuration, please copy the guide given.")
    return
end
if not getgenv().GabrielWebhook.URL or getgenv().GabrielWebhook.URL == "" then
    print("[Gabriel WH] [⚙️]: Missing URL.")
    return
end

repeat
    task.wait()
until game:IsLoaded()
repeat
    task.wait()
until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local HttpService = game:GetService("HttpService")

-- AutoExecute on Teleport
task.spawn(
    function()
        local queue_on_teleport =
            queue_on_teleport or syn.queue_on_teleport or fluxus.queue_on_teleport or function(...)
                return ...
            end
        game.Players.LocalPlayer.OnTeleport:Connect(
            function(state)
                if state ~= Enum.TeleportState.Started and state ~= Enum.TeleportState.InProgress then
                    return
                end
                queue_on_teleport(
                    [[
        wait(2)
        if getgenv().GbrlExec then return end -- avoid multiple executions
        loadstring(game:HttpGet("https://raw.githubusercontent.com/v3zxking/AnimeAdventures/refs/heads/main/AAWebhook.lua"))()
    ]]
                )
            end
        )
    end
)

-- Time Started
local startTime = os.clock()

local workspace = game:GetService("Workspace")
local waveStarted = workspace["_waves_started"]
getgenv().GbrlExec = true
if waveStarted then
    repeat
        task.wait()
    until waveStarted.Value == true
end

print("[Gabriel WH] [✅]: Webhook Result")
print(
    "[Gabriel WH] [⚙️]:\nURL = '" ..
        GabrielWebhook.URL ..
            "'\nDiscord_ID = '" ..
                GabrielWebhook.Discord_ID .. "'\nSecret_Ping = " .. tostring(GabrielWebhook.SecretPing)
)

local HttpService = game:GetService("HttpService")
local v5 = require(game.ReplicatedStorage.src.Loader)
local v19 = v5.load_client_service(script, "ItemInventoryServiceClient")

function get_inventory_items_unique_items()
    return v19["session"]["inventory"]["inventory_profile_data"]["unique_items"]
end
function get_inventory_items()
    return v19["session"]["inventory"]["inventory_profile_data"]["normal_items"]
end
function get_Units_Owner()
    return v19["session"]["collection"]["collection_profile_data"]["owned_units"]
end
function get_Units_Equipped()
    return v19["session"]["collection"]["collection_profile_data"]["equipped_units"]
end
function newStatsData()
    local player = game:GetService("Players").LocalPlayer
    local stats = player._stats
    local data = {
        Gems = stats["gem_amount"].Value,
        Gold = stats["gold_amount"].Value,
        HolidayStars = (stats._resourceHolidayStars and stats._resourceHolidayStars.Value) or 0
    }
    return data
end
local profiledata = v19 and v19.session and v19.session.profile_data
local resources = profiledata.resources or {}
local Old_Stats = {
    Gems = profiledata["gem_amount"],
    Gold = profiledata["gold_amount"],
    HolidayStars = resources.HolidayStars or 0
}

local unitscache = {}
local itemscache = {}

-- Unit Extract
for _, Module in next, game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild(
    "Units"
):GetDescendants() do
    if Module:IsA("ModuleScript") and Module.Name ~= "UnitPresets" then
        for UnitName, UnitStats in next, require(Module) do
            unitscache[UnitName] = UnitStats
        end
    end
end
-- Items Extract
for _, Module in next, game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild(
    "Items"
):GetDescendants() do
    if Module:IsA("ModuleScript") then
        for ItemName, ItemStats in next, require(Module) do
            itemscache[ItemName] = ItemStats
        end
    end
end
-- World Extract
local Worlds = {}
for _, Module in next, game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild(
    "Worlds"
):GetDescendants() do
    if Module:IsA("ModuleScript") then
        for MapName, MapStats in next, require(Module) do
            Worlds[MapName] = MapStats
        end
    end
end

-- Save Old Inventory and Create New Inventory
local Table_All_Items_Old_data = {}
local Table_All_Items_New_data = {}
local New_Stats = {}
local Equipped_Units = {}

for v2, v3 in pairs(game:GetService("ReplicatedStorage").src.Data.Items:GetDescendants()) do
    if v3:IsA("ModuleScript") then
        for v4, v5 in pairs(require(v3)) do
            Table_All_Items_Old_data[v4] = {}
            Table_All_Items_Old_data[v4]["id"] = v5["id"]
            Table_All_Items_Old_data[v4]["name"] = v5["name"]
            Table_All_Items_Old_data[v4]["rarity"] = v5["rarity"]
            Table_All_Items_Old_data[v4]["count"] = 0
            -- New
            Table_All_Items_New_data[v4] = {}
            Table_All_Items_New_data[v4]["id"] = v5["id"]
            Table_All_Items_New_data[v4]["name"] = v5["name"]
            Table_All_Items_New_data[v4]["rarity"] = v5["rarity"]
            Table_All_Items_New_data[v4]["count"] = 0
        end
    end
end
local Data_Units_All_Games = require(game:GetService("ReplicatedStorage").src.Data.Units)
for i, v in pairs(Data_Units_All_Games) do
    if v.rarity then
        Table_All_Items_Old_data[i] = {}
        Table_All_Items_Old_data[i]["id"] = v["id"]
        Table_All_Items_Old_data[i]["name"] = v["name"]
        Table_All_Items_Old_data[i]["rarity"] = v["rarity"]
        Table_All_Items_Old_data[i]["count"] = 0
        Table_All_Items_Old_data[i]["shiny"] = 0
        -- New
        Table_All_Items_New_data[i] = {}
        Table_All_Items_New_data[i]["id"] = v["id"]
        Table_All_Items_New_data[i]["name"] = v["name"]
        Table_All_Items_New_data[i]["rarity"] = v["rarity"]
        Table_All_Items_New_data[i]["count"] = 0
        Table_All_Items_New_data[i]["shiny"] = 0
    end
end

--- UPDATE table all items old AND new

function update_inventory(data)
    local new_data = data
    for i, v in pairs(get_inventory_items()) do
        new_data[i]["count"] = v
    end
    for i, v in pairs(get_inventory_items_unique_items()) do
        if string.find(v["item_id"], "portal") or string.find(v["item_id"], "disc") then
            new_data[v["item_id"]]["count"] = new_data[v["item_id"]]["count"] + 1
        end
    end
    for i, v in pairs(get_Units_Owner()) do
        new_data[v["unit_id"]]["count"] = new_data[v["unit_id"]]["count"] + 1
        if v.shiny then
            new_data[v["unit_id"]]["count"] = new_data[v["unit_id"]]["count"] - 1
            new_data[v["unit_id"]]["shiny"] = new_data[v["unit_id"]]["shiny"] + 1
        end
    end

    return new_data
end

Table_All_Items_Old_data = update_inventory(Table_All_Items_Old_data)

for i, v in pairs(get_Units_Equipped()) do
    Equipped_Units[i] = v
end

function getDropResult(old, new)
    local dropResult = {
        units = {}, -- List of unit names received
        items = {}, -- List of items received
        ping = false, -- True if a secret rarity item is received
        message = {} -- Insert a message for secret/unit received
    }

    for i, v in pairs(new) do
        local oldData = old[i] or {count = 0, shiny = 0} -- Default to zero if old data is missing

        -- Check for units
        if (v.count > 0 or v.shiny) and unitscache[v["id"]] then
            local shinyDifference = v.shiny - oldData.shiny
            local countDifference = v.count - oldData.count

            if shinyDifference > 0 then
                -- Shiny unit received
                dropResult.ping = true -- Always ping when a unit is received
                table.insert(
                    dropResult.units,
                    "+ " .. tostring(shinyDifference) .. " " .. v.name .. " (Shiny) { " .. v.shiny .. " }"
                )
                table.insert(
                    dropResult.message,
                    tostring(countDifference) .. " " .. v.name .. " (Shiny)" .. " { " .. v.count .. " }"
                )
            elseif countDifference > 0 then
                -- Non-shiny unit received
                dropResult.ping = true -- Always ping when a unit is received
                table.insert(
                    dropResult.units,
                    "+ " .. tostring(countDifference) .. " " .. v.name .. " { " .. v.count .. " }"
                )
                table.insert(dropResult.message, tostring(countDifference) .. " " .. v.name .. " { " .. v.count .. " }")
            end
        end

        -- Check for items
        if v.count > 0 and (v.count - oldData.count) > 0 then
            local itemDifference = v.count - oldData.count
            table.insert(
                dropResult.items,
                "+ " .. tostring(itemDifference) .. " " .. v.name .. " { " .. v.count .. " }"
            )
            if v.rarity == "Secret" then
                dropResult.ping = true -- Ping if a secret rarity item is received
                table.insert(dropResult.message, tostring(itemDifference) .. " " .. v.name .. " { " .. v.count .. " }")
            end
        end
    end
    dropResult.items = table.concat(dropResult.items, "\n")
    dropResult.units = table.concat(dropResult.units, "\n")
    dropResult.message = table.concat(dropResult.message, ", ")
    if dropResult.items ~= "" then
        dropResult.items = "\n" .. dropResult.items
    end
    if dropResult.units ~= "" then
        dropResult.units = "\n" .. dropResult.units
    end

    return dropResult
end

function comma_value(number)
    number = string.gsub(number, "+", "")
    local i, j, minus, int, fraction = number:find("([-]?)(%d+)([.]?%d*)")
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function determinePlayerLevel(xp)
    local level = 1
    local xpRequired = 100
    local totalXp = 0

    while totalXp <= xp do
        totalXp = totalXp + xpRequired
        if totalXp > xp then
            break
        end
        level = level + 1
        xpRequired = xpRequired + 7
    end

    -- Calculate current XP for the current level
    local previousTotalXp = totalXp - xpRequired
    local currentXp = xp - previousTotalXp

    return level, currentXp, xpRequired
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function formatElapsedTime(seconds)
    if seconds < 60 then
        return string.format("%02d:%02d", 0, math.floor(seconds)) -- MM:SS
    elseif seconds < 3600 then -- Less than an hour
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = math.fmod(seconds, 60)
        return string.format("%02d:%02d", minutes, remainingSeconds) -- MM:SS
    else -- An hour or more
        local hours = math.floor(seconds / 3600)
        local remainingSecondsAfterHours = math.fmod(seconds, 3600)
        local minutes = math.floor(remainingSecondsAfterHours / 60)
        local remainingSeconds = math.fmod(remainingSecondsAfterHours, 60)
        return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds) -- HH:MM:SS
    end
end

function webhook()
    local url = GabrielWebhook.URL
    if not url or url == "" then
        return
    end
    local discord_user = GabrielWebhook.Discord_ID or ""
    local secret_ping = GabrielWebhook.SecretPing or false

    local colors = {
        default = 3298472,
        victory = 4050024,
        defeat = 11348008
    }
    local endTime = os.clock()
    local elapsedTime = endTime - startTime
    local outputTime = formatElapsedTime(elapsedTime)

    local OSTime = os.time()
    local Time = os.date("*t", OSTime)
    local player = game.Players.LocalPlayer
    local currentXp = player._stats.player_xp.Value
    local playerLevel, currentXpInLevel, maxXpForLevel = determinePlayerLevel(currentXp)
    local outputLevel = string.format("Level %d ||[%d/%d]||", playerLevel, currentXpInLevel, maxXpForLevel)
    -- Player Stats
    New_Stats = newStatsData()
    local result_stats = {}
    if (New_Stats.Gems - Old_Stats.Gems) > 0 then
        table.insert(result_stats, "+ " .. New_Stats.Gems - Old_Stats.Gems .. " Gems")
    end
    if (New_Stats.Gold - Old_Stats.Gold) > 0 then
        table.insert(result_stats, "+ " .. New_Stats.Gold - Old_Stats.Gold .. " Gold")
    end
    if (New_Stats.HolidayStars - Old_Stats.HolidayStars) > 0 then
        table.insert(result_stats, "+ " .. New_Stats.HolidayStars - Old_Stats.HolidayStars .. " Holiday Stars")
    end

    ResultHolder = player.PlayerGui:FindFirstChild("ResultsUI"):FindFirstChild("Holder")
    if game.PlaceId ~= 8304191830 then
        levelname =
            game:GetService("Workspace"):FindFirstChild("_MAP_CONFIG"):FindFirstChild("GetLevelData"):InvokeServer()[
            "name"
        ]
        result = ResultHolder.Title.Text
    else
        levelname, result = "nil", "nil"
    end
    if result == "VICTORY" then
        result = "VICTORY"
    end
    if result == "DEFEAT" then
        result = "DEFEAT"
    end

    -- World Result
    cwaves = player.PlayerGui.ResultsUI.Holder.Middle.WavesCompleted.Text
    ctime = player.PlayerGui.ResultsUI.Holder.Middle.Timer.Text
    waves = cwaves:split(": ")
    if waves ~= nil and waves[2] == "999" then
        waves[2] = "Use [Auto Leave at Wave] or [Test Webhook]"
    end
    ttime = ctime:split(": ")
    if waves ~= nil and ttime[2] == "22:55" then
        ttime[2] = "Use [Auto Leave at Wave] or [Test Webhook]"
    end
    gold =
        ResultHolder:FindFirstChild("LevelRewards"):FindFirstChild("ScrollingFrame"):FindFirstChild("GoldReward"):FindFirstChild(
        "Main"
    ):FindFirstChild("Amount").Text
    if gold == "+99999" then
        gold = "+0"
    end
    gems =
        ResultHolder:FindFirstChild("LevelRewards"):FindFirstChild("ScrollingFrame"):FindFirstChild("GemReward"):FindFirstChild(
        "Main"
    ):FindFirstChild("Amount").Text
    if gems == "+99999" then
        gems = "+0"
    end
    xpx =
        ResultHolder:FindFirstChild("LevelRewards"):FindFirstChild("ScrollingFrame"):FindFirstChild("XPReward"):FindFirstChild(
        "Main"
    ):FindFirstChild("Amount").Text
    xp = xpx:split(" ")
    if xp[1] == "+99999" then
        xp[1] = "+0"
    end
    trophy =
        ResultHolder:FindFirstChild("LevelRewards"):FindFirstChild("ScrollingFrame"):FindFirstChild("TrophyReward"):FindFirstChild(
        "Main"
    ):FindFirstChild("Amount").Text
    if trophy == "+99999" then
        trophy = "+0"
    end

    -- Get game mode and result
    _map = game:GetService("Workspace")["_BASES"].player.base["fake_unit"]:WaitForChild("HumanoidRootPart")
    mapconfig = game:GetService("Workspace")._MAP_CONFIG.GetLevelData:InvokeServer()
    GetLevelData = game.workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer()
    world = Worlds[GetLevelData.world] or GetLevelData._location_name or GetLevelData.name
    mapname = mapconfig["name"]
    gamemode = mapconfig["_gamemode"]
    portaldepth = ""
    challenge = ""
    if mapconfig["_portal_depth"] then
        portaldepth = "\n(Tier: " .. mapconfig["_portal_depth"] .. ")"
    end
    if mapconfig["_challengename"] then
        challenge = " - " .. mapconfig["_challengename"]
    else
        challenge = " - " .. mapconfig["_difficulty"]
    end
    if type(world) == "table" then
        world = world.Name
    end

    if type(world) == "string" and string.find(world, "Raid:") then
        world = world:gsub("Raid: ")
        challenge = " - " .. world
    end

    -- Determine Gamemode
    if gamemode == "challenge" then
        gamemode = "Challenge Mode"
    elseif mapconfig["_portal_only_level"] then
        if mapconfig["_challengename"] then
            gamemode = "Portal Mode" .. challenge
        else
            gamemode = "Portal Mode"
        end
    elseif string.find(mapconfig["id"], "event") then
        gamemode = mapname
    elseif gamemode == "raid" then
        gamemode = "Raid Mode"
    elseif gamemode == "story" then
        gamemode = "Story Mode"
    elseif gamemode == "infinite" then
        gamemode = "Infinite Mode"
    elseif gamemode == "infinite_tower" then
        gamemode = "Infinity Castle Mode"
    else
        gamemode = mapconfig["name"]
    end

    totaltime = ResultHolder:FindFirstChild("Middle"):FindFirstChild("Timer").Text
    totalwaves = ResultHolder:FindFirstChild("Middle"):FindFirstChild("WavesCompleted").Text

    worldResult = gamemode .. " - **" .. result .. "**\n(" .. world .. "" .. challenge .. ")"
    if gamemode == "Infinite Mode" then
        worldResult = gamemode .. " - " .. world
    elseif string.find(mapconfig["id"], "event") then
        worldResult = "(" .. world .. " - **" .. result .. "**)\n" .. gamemode .. ""
    elseif gamemode == "Raid Mode" then
        worldResult = "(" .. world .. " - **" .. result .. "**)" .. "\n" .. GetLevelData["name"]:gsub("Raid: ", "")
    elseif string.find(gamemode, "Infinity Castle") then
        worldResult =
            gamemode .. " - **" .. result .. "**\n(" .. world .. " - Room: " .. tostring(mapconfig["floor_num"]) .. ")"
    elseif string.find(gamemode, "Story Mode") then
        worldResult = gamemode .. " - **" .. result .. "**\n(" .. world .. " - " .. tostring(mapconfig["name"]) .. ")"
    end

    -- Item/Unit Result Drop
    Table_All_Items_New_data = update_inventory(Table_All_Items_New_data)

    local drop_results = getDropResult(Table_All_Items_Old_data, Table_All_Items_New_data)
    -- Returns { units -string, items -string, ping -bool}

    local text_results = ""
    if tablelength(result_stats) > 0 then
        text_results = table.concat(result_stats, "\n")
    end

    local icons = {
        ["Gems"] = "<:gems:1321382598479708240>",
        ["Gold"] = "<:gold:1321382789987176478>",
        ["HolidayStars"] = "<:holiday:1322162293978562642>"
    }
    local currentStats = newStatsData()
    local total_stats_result = {}
    for key, emoji in pairs(icons) do
        if currentStats[key] then
            table.insert(total_stats_result, emoji .. " " .. comma_value(currentStats[key]))
        end
    end

    total_stats_result = table.concat(total_stats_result, "\n")
    local pingUser = "<@" .. discord_user .. ">"

    if not drop_results.ping then
        pingUser = " "
    end

    local color = colors.default
    if result == "VICTORY" then
        color = colors.victory
    elseif result == "DEFEAT" then
        color = colors.defeat
    end

    local data = {
        ["content"] = "" .. pingUser .. "",
        ["embeds"] = {
            {
                ["title"] = "Anime Adventures",
                ["description"] = (drop_results.message ~= "" and "You received " .. drop_results.message) or "",
                ["color"] = color,
                ["footer"] = {
                    ["text"] = "Vile (" .. string.format("%02d:%02d:%02d", Time.hour, Time.min, Time.sec) .. ")"
                },
                ["fields"] = {
                    {
                        ["name"] = "Player",
                        ["value"] = "Name: ||" ..
                            player.Name ..
                                " (" .. player.displayName .. ")||\n" .. outputLevel .. "\n" .. total_stats_result,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Match",
                        ["value"] = "**Waves Finished:** " ..
                            tostring(waves[2]) .. " (" .. outputTime .. ")\n" .. worldResult,
                        ["inline"] = true
                    },
                    {
                        -- Rewards
                        ["name"] = "Rewards",
                        ["value"] = text_results .. drop_results.items .. drop_results.units,
                        ["inline"] = false
                    }
                }
            }
        }
    }

    local xd = game:GetService("HttpService"):JSONEncode(data)

    local headers = {["content-type"] = "application/json"}
    request = http_request or request or HttpPost or syn.request or http.request
    local sex = {Url = url, Body = xd, Method = "POST", Headers = headers}
    request(sex)
end

coroutine.resume(
    coroutine.create(
        function()
            local mapconfig = game:GetService("Workspace")._MAP_CONFIG.GetLevelData:InvokeServer()
            if mapconfig["_gamemode"] ~= "infinite" then
                local GameFinished = game:GetService("Workspace"):WaitForChild("_DATA"):WaitForChild("GameFinished")
                GameFinished:GetPropertyChangedSignal("Value"):Connect(
                    function()
                        print("Finished", GameFinished.Value == true)
                        if GameFinished.Value == true then
                            repeat
                                task.wait()
                            until game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Enabled == true
                            local s, e =
                                pcall(
                                function()
                                    webhook()
                                    print("[Gabriel WH]: Sent webhook!")
                                end
                            )
                            if e then
                                print("[Error sending webhook]:")
                                print(e)
                            end
                            task.wait(math.random())
                        end
                    end
                )
            end
        end
    )
)
