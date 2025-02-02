How to use AA Webhook?
Just enter your discord webhook url below the script
adjust the settings as you see fit
```lua
-- does not support when you auto leave the game
-- unless I implement a UI for this...

getgenv().GabrielWebhook = {
    URL = "", -- Insert webhook url here
    SecretPing = true, -- false if you don't want ping for secret 
    Discord_ID = "", -- insert your discord id here or else mention no one
    AutoExec = false -- set true if you want it to exec every new game/teleport
}

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/v3zxking/AnimeAdventures/refs/heads/main/AAWebhook.lua"))()
end)
```

For auto buddha ability, there are 3 options for this. pick one as you see fit to use in game.
Change `getgenv().BuddhaForm = ""` [Open Source](https://github.com/v3zxking/AnimeAdventures/blob/main/AutoBuddhaAbility.lua)
```lua
getgenv().BuddhaForm = "two"
-- "one" Normal / Small aoe
-- "two" Big aoe bleed
-- "three" Line aoe hybrid

pcall(function()
    task.wait(2)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/v3zxking/AnimeAdventures/refs/heads/main/AutoBuddhaAbility.lua'))()
end)
```

Auto Universal Ability - it automatically detects units with ability and use its ability.
```lua
pcall(function()
   loadstring(game:HttpGet('https://raw.githubusercontent.com/v3zxking/AnimeAdventures/refs/heads/main/AutoBuddhaAbility.lua'))()
end)
```
