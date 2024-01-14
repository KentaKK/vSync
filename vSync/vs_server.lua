------------------ change this -------------------

admins = {
    'steam:11000013edf372d',
    'steam:1100001586cb84d'
}

-- Set this to false if you don't want the weather to change automatically every 10 minutes.
DynamicWeather = false

--------------------------------------------------
debugprint = false -- don't touch this unless you know what you're doing or you're being asked by Vespura to turn this on.
--------------------------------------------------

-------------------- DON'T CHANGE THIS --------------------
AvailableWeatherTypes = {
    'EXTRASUNNY',
    'CLEAR',
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS',
    'HALLOWEEN',
}
CurrentWeather = 'XMAS'
local baseTime = 0
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 10

local function isAllowedToChange(player)
    local allowed = false
    for _,id in ipairs(admins) do
        for _,pid in ipairs(GetPlayerIdentifiers(player)) do
            if debugprint then print('admin id: ' .. id .. '\nplayer id:' .. pid) end
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end

local function setTimeOfDay(source, hour, minute)
    if isAllowedToChange(source) then
        ShiftToMinute(minute)
        ShiftToHour(hour)
        TriggerClientEvent('vSync:updateSet', -1)
        --TriggerClientEvent('vSync:notify', source, string.format("%s ~y~%s~s~.", lang.timeSet, text))
        TriggerEvent('vSync:requestSync')
    end
end

RegisterServerEvent('vSync:requestSync')
AddEventHandler('vSync:requestSync', function()
    TriggerClientEvent('vSync:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
end)

RegisterServerEvent('vSync:changeWeather')
AddEventHandler('vSync:changeWeather', function(weather)
    CurrentWeather = weather
    TriggerEvent('vSync:requestSync')
end)

RegisterCommand('changeback', function(source)
    if source == 0 then
        TriggerClientEvent('vSync:updateSet2', -1)
        TriggerEvent('vSync:requestSync')
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 9, 0)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~back~s~.')
        TriggerClientEvent('vSync:updateSet2', -1)
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('freezetime', function(source)
    if source ~= 0 then
        if isAllowedToChange(source) then
            freezeTime = not freezeTime
            if freezeTime then
                TriggerClientEvent('vSync:updateSet', -1)
                TriggerClientEvent('vSync:notify', source, 'Time is now ~b~frozen~s~.')
            else
                TriggerClientEvent('vSync:notify', source, 'Time is ~y~no longer frozen~s~.')
            end
        else
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, '^8Error: ^1You are not allowed to use this command.')
        end
    else
        freezeTime = not freezeTime
        if freezeTime then
            print("Time is now frozen.")
        else
            print("Time is no longer frozen.")
        end
    end
end, false)

RegisterCommand('freezeweather', function(source)
    if source ~= 0 then
        if isAllowedToChange(source) then
            DynamicWeather = not DynamicWeather
            if not DynamicWeather then
                TriggerClientEvent('vSync:notify', source, 'Dynamic weather changes are now ~r~disabled~s~.')
            else
                TriggerClientEvent('vSync:notify', source, 'Dynamic weather changes are now ~b~enabled~s~.')
            end
        else
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, '^8Error: ^1You are not allowed to use this command.')
        end
    else
        DynamicWeather = not DynamicWeather
        if not DynamicWeather then
            print("Weather is now frozen.")
        else
            print("Weather is no longer frozen.")
        end
    end
end, false)

RegisterCommand('weather', function(source, args)
    if source == 0 then
        local validWeatherType = false
        if args[1] == nil then
            print("Invalid syntax, correct syntax is: /weather <weathertype> ")
            return
        else
            for _,wtype in ipairs(AvailableWeatherTypes) do
                if wtype == string.upper(args[1]) then
                    validWeatherType = true
                end
            end
            if validWeatherType then
                print("Weather has been updated.")
                CurrentWeather = string.upper(args[1])
                newWeatherTimer = 10
                TriggerEvent('vSync:requestSync')
            else
                print("Invalid weather type, valid weather types are: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ")
            end
        end
    else
        if isAllowedToChange(source) then
            local validWeatherType = false
            if args[1] == nil then
                TriggerClientEvent('chat:addMessage', source, '', {255,255,255}, '^8Error: ^1Invalid syntax, use ^0/weather <weatherType> ^1instead!')
            else
                for _,wtype in ipairs(AvailableWeatherTypes) do
                    if wtype == string.upper(args[1]) then
                        validWeatherType = true
                    end
                end
                if validWeatherType then
                    TriggerClientEvent('vSync:notify', source, 'Weather will change to: ~y~' .. string.lower(args[1]) .. "~s~.")
                    CurrentWeather = string.upper(args[1])
                    newWeatherTimer = 10
                    TriggerEvent('vSync:requestSync')
                else
                    TriggerClientEvent('chat:addMessage', source, '', {255,255,255}, '^8Error: ^1Invalid weather type, valid weather types are: ^0\nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ')
                end
            end
        else
            TriggerClientEvent('chat:addMessage', source, '', {255,255,255}, '^8Error: ^1You do not have access to that command.')
            print('Access for command /weather denied.')
        end
    end
end, false)

RegisterCommand('blackout', function(source)
    if source == 0 then
        blackout = not blackout
        if blackout then
            print("Blackout is now enabled.")
        else
            print("Blackout is now disabled.")
        end
    else
        if isAllowedToChange(source) then
            blackout = not blackout
            if blackout then
                TriggerClientEvent('vSync:notify', source, 'Blackout is now ~b~enabled~s~.')
            else
                TriggerClientEvent('vSync:notify', source, 'Blackout is now ~r~disabled~s~.')
            end
            TriggerEvent('vSync:requestSync')
        end
    end
end, false)

RegisterCommand('sunrise', function(source)
    if source == 0 then
        setTimeOfDay(source, 5, 0)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 5, 0)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~morning~s~.')
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('morning', function(source)
    if source == 0 then
        setTimeOfDay(source, 9, 0)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 9, 0)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~morning~s~.')
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('noon', function(source)
    if source == 0 then
        setTimeOfDay(source, 12, 0)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 12, 0)
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~noon~s~.')
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('sunset', function(source)
    if source == 0 then
        setTimeOfDay(source, 16, 0)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 16, 0)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~morning~s~.')
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('evening', function(source)
    if source == 0 then
        TriggerClientEvent('vSync:updateSet', -1)
        setTimeOfDay(source, 18, 0)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 18, 0)
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~evening~s~.')
        TriggerEvent('vSync:requestSync')
    end
end, false)

RegisterCommand('night', function(source)
    if source == 0 then
        setTimeOfDay(source, 23, 0)
        TriggerClientEvent('vSync:updateSet', -1)
    end
    if isAllowedToChange(source) then
        setTimeOfDay(source, 23, 0)
        TriggerClientEvent('vSync:updateSet', -1)
        TriggerClientEvent('vSync:notify', source, 'Time set to ~y~night~s~.')
        TriggerEvent('vSync:requestSync')
    end
end, false)

function ShiftToMinute(minute)
    timeOffset = timeOffset - ( ( (baseTime+timeOffset) % 60 ) - minute )
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
end

RegisterCommand('time', function(source, args)
    if source == 0 then
        if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
            local argh = tonumber(args[1])
            local argm = tonumber(args[2])
            if argh < 24 then
                ShiftToHour(argh)
            else
                ShiftToHour(0)
            end
            if argm < 60 then
                ShiftToMinute(argm)
            else
                ShiftToMinute(0)
            end
            print("Time Change" .. argh .. ":" .. argm .. ".")
            TriggerClientEvent('vSync:updateSet', -1)
            TriggerEvent('vSync:requestSync')
        else
            --print(lang.errorInvalidSyntax .. lang.syntaxTime)
        end
    elseif source ~= 0 then
        if isAllowedToChange(source) then
            if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
                local argh = tonumber(args[1])
                local argm = tonumber(args[2])
                if argh < 24 then
                    ShiftToHour(argh)
                else
                    ShiftToHour(0)
                end
                if argm < 60 then
                    ShiftToMinute(argm)
                else
                    ShiftToMinute(0)
                end
                local newtime = math.floor(((baseTime+timeOffset)/60)%24) .. ":"
				local minute = math.floor((baseTime+timeOffset)%60)
                if minute < 10 then
                    newtime = newtime .. "0" .. minute
                else
                    newtime = newtime .. minute
                end
                --TriggerClientEvent('vSync:notify', source, lang.timeChanged..': ~y~' .. newtime .. "~s~!")
        TriggerClientEvent('vSync:updateSet', -1)
                TriggerEvent('vSync:requestSync')
            else
                --TriggerClientEvent('chatMessage', source, '', {255,255,255}, lang.errorInvalidSyntax .. lang.syntaxTime)
            end
        else
            --TriggerClientEvent('chatMessage', source, '', {255,255,255}, lang.errorNotAllowed)
            --print(lang.errorAcessDenied..'/time')
        end
    end
end, false)

CreateThread(function()
    while true do
        local sleep = 5000
        local newBaseTime = os.time(os.date("!*t"))/2 + 360
        if freezeTime then
            sleep = 0
            timeOffset = timeOffset + baseTime - newBaseTime
        end
        baseTime = newBaseTime
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(35000)
        TriggerClientEvent('vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        TriggerClientEvent('vSync:updateWeather', -1, CurrentWeather, blackout)
    end
end)

CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Wait(60000)
        if newWeatherTimer == 0 then
            if DynamicWeather then
                NextWeatherStage()
            end
            newWeatherTimer = 60
        end
    end
end)

function NextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "SMOG" end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("vSync:requestSync")
    if debugprint then
        print("[vSync] New random weather type has been generated: " .. CurrentWeather .. ".\n")
        print("[vSync] Resetting timer to 10 minutes.\n")
    end
end
