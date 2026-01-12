local seatbelt = false
local alarmTimer = 0

-- Detectar idioma del manifest o usar inglés por defecto
local lang = Locales[GetConvar("sets locale", "es")] or Locales['es']

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            sleep = 0 
            
            -- Cinturón Instantáneo (G)
            if IsControlJustPressed(0, 47) then
                seatbelt = not seatbelt
                PlaySoundFrontend(-1, "BUTTON_PRESS", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                SendNUIMessage({ action = "updateSeatbelt", belt = seatbelt })
            end

            if seatbelt then DisableControlAction(0, 75, true) end

            -- Alarma sonora si no hay cinturón y hay velocidad
            local speed = GetEntitySpeed(vehicle) * 3.6
            if not seatbelt and speed > 20.0 then
                if GetGameTimer() > alarmTimer then
                    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
                    alarmTimer = GetGameTimer() + 600
                end
            end

            -- Datos de Calle y Zona
            local coords = GetEntityCoords(playerPed)
            local streetHash, _ = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local streetName = GetStreetNameFromHashKey(streetHash)
            local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
            
            -- Estado de Luces
            local _, lightsOn, highBeamsOn = GetVehicleLightsState(vehicle)

            SendNUIMessage({
                action = "updateCarHUD",
                show = true,
                speed = math.ceil(speed),
                rpm = GetVehicleCurrentRpm(vehicle),
                gear = GetVehicleCurrentGear(vehicle) == 0 and "R" or GetVehicleCurrentGear(vehicle),
                fuel = math.ceil(GetVehicleFuelLevel(vehicle)),
                engine = GetVehicleEngineHealth(vehicle),
                lights = (lightsOn == 1 or highBeamsOn == 1),
                street = streetName .. " | " .. zoneName,
                -- Envío de traducciones desde locales/
                txtFuel = lang.fuel,
                txtEngine = lang.engine,
                txtGear = lang.gear
            })
        else
            if seatbelt then seatbelt = false end
            SendNUIMessage({ action = "updateCarHUD", show = false })
            sleep = 1000
        end
        Citizen.Wait(sleep)
    end
end)