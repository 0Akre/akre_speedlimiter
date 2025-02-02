local QBCore = exports['qb-core']:GetCoreObject()

local limiterEnabled = false
local currentSpeedLimit = 0.0
local speedMultiplier = Config.Unit == 'kmh' and 3.6 or 2.236936

RegisterCommand(Config.SpeedLimiter.command, function(source, args)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        if #args == 0 then
            if limiterEnabled then
                limiterEnabled = false
                currentSpeedLimit = 0.0
                SetEntityMaxSpeed(vehicle, 999.0)
                TriggerEvent("hud:client:UpdateSpeedLimiter", false)
                QBCore.Functions.Notify("Speed limiter disabled")
            else
                currentSpeedLimit = GetEntitySpeed(vehicle) * speedMultiplier
                if currentSpeedLimit > 0 then
                    limiterEnabled = true
                    SetEntityMaxSpeed(vehicle, currentSpeedLimit / speedMultiplier)
                    TriggerEvent("hud:client:UpdateSpeedLimiter", true)
                    QBCore.Functions.Notify("Speed limiter set to current speed: " .. math.floor(currentSpeedLimit) .. " " .. Config.Unit)
                end
            end
        elseif #args == 1 then
            local specifiedSpeed = tonumber(args[1])
            if specifiedSpeed and specifiedSpeed > 0 then
                limiterEnabled = true
                currentSpeedLimit = specifiedSpeed
                SetEntityMaxSpeed(vehicle, currentSpeedLimit / speedMultiplier)
                TriggerEvent("hud:client:UpdateSpeedLimiter", true)
                QBCore.Functions.Notify("Speed limiter set to: " .. math.floor(currentSpeedLimit) .. " " .. Config.Unit)
            else
                QBCore.Functions.Notify("Invalid speed value", "error")
            end
        else
            QBCore.Functions.Notify("Invalid usage. Use /" .. Config.SpeedLimiter.command .. " or /" .. Config.SpeedLimiter.command .. " [speed]", "error")
        end
    else
        QBCore.Functions.Notify("You need to be in a vehicle to use the speed limiter", "error")
    end
end, false)

RegisterKeyMapping(Config.SpeedLimiter.command, Config.SpeedLimiter.description, 'keyboard', 'F5')

CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/" .. Config.SpeedLimiter.command, Config.SpeedLimiter.description, {
        { name="type", help="Speed" }
    })    
end)

CreateThread(function()
    while true do
        Wait(200)
        if limiterEnabled then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                local speed = GetEntitySpeed(vehicle) * speedMultiplier
                if speed > currentSpeedLimit then
                    SetEntityMaxSpeed(vehicle, currentSpeedLimit / speedMultiplier)
                end
            else
                limiterEnabled = false
                currentSpeedLimit = 0.0
            end
        else
            Wait(1000)
        end
    end
end)