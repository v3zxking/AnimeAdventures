if not getgenv().BuddhaForm or getgenv().BuddhaForm == "" then
    getgenv().BuddhaForm = "two" -- Auto Bleed Attack Form
end

repeat task.wait() until game:IsLoaded()

getgenv().AutoBuddha = true -- change to false to shut off auto buddha if anything goes wrong.
print("[... Buddha Ability] [✅] [Note: to disable, execute 'getgenv().AutoBuddha = false'")

getgenv().buddha = {} -- insert all buddhas

function GetBuddhas()
    local Workspace = game:GetService("Workspace")
    local Units = Workspace:FindFirstChild("_UNITS")
    local Player = game:GetService("Players").LocalPlayer

    for _, unit in pairs(Units:GetDescendants()) do
        local stats = unit:FindFirstChild("_stats")
        if stats and stats:FindFirstChild("player") and stats.player.Value == Player then
            if stats.id.Value == "buddha_evolved" then
                if not table.find(getgenv().buddha, unit) and stats.upgrade.Value >= 3 and not string.find(stats.primary_attack.Value, getgenv().BuddhaForm) then
                    table.insert(getgenv().buddha, unit) 
                end
            end
        end
    end
end

function AutoBuddhaAbility()
    for _, unit in pairs(getgenv().buddha) do
        local stats = unit:FindFirstChild("_stats")
        if stats then
            local attackForm = stats.primary_attack.Value
            while not string.find(attackForm, getgenv().BuddhaForm) and getgenv().AutoBuddha do
                game.ReplicatedStorage.endpoints.client_to_server.use_active_attack:InvokeServer(unit)
                task.wait(5)
                attackForm = stats.primary_attack.Value
                if string.find(attackForm, getgenv().BuddhaForm) then break end
            end
        end
    end
end

coroutine.resume(coroutine.create(function()
    while true do
        GetBuddhas()
        task.wait(1)
        AutoBuddhaAbility()

        if not getgenv().AutoBuddha then break end
    end
end))
