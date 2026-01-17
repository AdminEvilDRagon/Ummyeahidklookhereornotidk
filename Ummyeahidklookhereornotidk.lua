local _OT = os.time
local _TICK = tick
local _R = request
local _HS = game:GetService("HttpService")
local _JE = _HS.JSONEncode
local _G_MT = getrawmetatable(game)
local _OLD_NC = _G_MT.__namecall
local _ALREADY_REPORTED = false
local _LastCheck = {time = _OT(), tick = _TICK()}

-- HWID Generation Function
local function _GET_HWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

-- HWID BLACKLIST (Gebannte HWIDs)
local _HWID_BLACKLIST = {
    ["HWID_HIER"] = true,
    ["C4C11E58-45CF-49FD-8243-FFED21BA8318"] = true,
    -- Füge hier weitere gebannte HWIDs hinzu
}

-- USER ID BLACKLIST (Gebannte Roblox User IDs)
local _USERID_BLACKLIST = {
    [9920991471] = true,
    -- Füge hier weitere gebannte User IDs hinzu
}

-- HWID & User ID Check
local function _CHECK_BLACKLIST()
    local current_hwid = _GET_HWID()
    local current_userid = game.Players.LocalPlayer.UserId
    
    -- Check HWID Blacklist
    if _HWID_BLACKLIST[current_hwid] then
        _SV("Blacklisted HWID detected: " .. current_hwid)
        return false
    end
    
    -- Check User ID Blacklist
    if _USERID_BLACKLIST[current_userid] then
        _SV("Blacklisted User ID detected: " .. current_userid)
        return false
    end
    
    return true
end

local function _SV(reason)
    if _ALREADY_REPORTED then return end
    _ALREADY_REPORTED = true
    
    local _r = "https://ptb.discord.com/api/webhooks/1461749192555892871/Ghg83yJ56TanUntPaNqlQarBTkwGCMDyy72BbHLartDNlSucb83Z6VXBQ26PdqqmLi9R"
    
    local player = game.Players.LocalPlayer
    local current_hwid = _GET_HWID()
    
    pcall(function()
        _R({
            Url = _r,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = _JE(_HS, {
                content = "<@&1396876052588134611> ⛔ **BLACKLIST ALERT** ⛔",
                embeds = {{
                    title = "Blacklisted User Detected",
                    description = "A blacklisted user attempted to execute the script!",
                    color = 16711680,
                    fields = {
                        { name = "Username:", value = "```" .. player.Name .. "```", inline = true },
                        { name = "User ID:", value = "```" .. player.UserId .. "```", inline = true },
                        { name = "HWID:", value = "```" .. current_hwid .. "```", inline = false },
                        { name = "Reason:", value = "```" .. reason .. "```", inline = false }
                    },
                    timestamp = DateTime.now():ToIsoDate()
                }}
            })
        })
    end)
    
    task.wait(0.5)
    player:Kick("\n[Ruby Hub V2 Security]\n🚫 ACCESS DENIED 🚫\n\nYou have been permanently blacklisted.\nReason: " .. reason)
end

-- Initial Blacklist Check (Sofortiger Kick)
if not _CHECK_BLACKLIST() then
    return -- Script wird sofort beendet
end

-- Security Monitor Loop
task.spawn(function()
    while task.wait(1.5) do
        if _ALREADY_REPORTED then break end
        local ct, ctick = _OT(), _TICK()
        
        if os.time ~= _OT or debug.info(os.time, "s") ~= "[C]" then 
            _SV("hookfunction(os.time) detected!") 
            break 
        end
        
        if request ~= _R or debug.info(request, "s") ~= "[C]" then 
            _SV("request() hook detected!") 
            break 
        end
        
        local timeDiff = ct - _LastCheck.time
        local tickDiff = ctick - _LastCheck.tick
        if math.abs(timeDiff - tickDiff) > 5 or timeDiff < 0 then 
            _SV("Time manipulation detected!") 
            break 
        end
        
        if getrawmetatable(game).__namecall ~= _OLD_NC then 
            _SV("Metatable tampering!") 
            break 
        end
        
        _LastCheck.time, _LastCheck.tick = ct, ctick
    end
end)
