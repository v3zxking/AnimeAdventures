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
end)```
