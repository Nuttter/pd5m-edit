Mss_Amb_PrisonerTransport_Nutter = {
    Weight = 100,
    Main = function()
		local RadioCalls = {
			"TIMEOUT",
			"TIMEOUT2",
			"TIMEOUT3",
			"TIMEOUT4",
		}
		
		local bus, busDriver
		local escortBlip
		local blip
		

		
        local stationLocations = {
            vector4(403.54, -993.51, 28.86, 357.85),   -- Mission Row
            vector4(808.32, -1311.74, 25.63, 357.53), -- La mesa
            vector4(395.41, -1597.04, 28.83, 227.24),  -- Rancho
			vector4(-1149.71, -845.35, 13.91, 39.41)  -- Vespucci
			--vector4(2137.29, 2773.18, 49.29, 130.34) -- Test Location
        }
		local prisonInnerYard = vector3(1786.08, 2605.47, 44.88)    -- Inside yard or secondary gate

        local prisonCoords = vector3(1902.6, 2609.75, 45.06)
        local busModel = `pissbus`
        local driverModel = `s_m_m_prisguard_01`
		local cruiserModels = {
			`vvpi`,
			`buffsxpol`,
			`polnscout`,
			`pgranger2`,
			`police02`
		}


        TriggerServerEvent("InteractSound_SV:PlayOnSource", "prisonescort", 0.2)
        local selected = stationLocations[math.random(#stationLocations)]
        local displayText = true

        function DrawCalloutText()
            Citizen.CreateThread(function()
                while displayText do
                    Wait(0)
                    SetTextFont(4)
                    SetTextScale(0.5, 0.5)
                    SetTextColour(255, 255, 255, 255)
                    SetTextOutline()
                    SetTextEntry("STRING")
                    SetTextCentre(true)
                    AddTextComponentString("Press [~g~F2~w~] ~o~~italic~"..timer.."~italic~~w~  Seconds to Respond ~o~Prisoner Escort.")
                    DrawText(0.5, 0.9)
                    if IsControlJustPressed(0, 289) then
                        if calloutAccepted then
							Notify('You have already responded to a callout')
                            displayText = false
                        else
                            calloutAccepted = true
                            displayText = false
                            timer = 0
                            PlaySound(-1, "Radio_On", "TAXI_SOUNDS", 0, 0)
                            Wait(100)
                            PlaySound(-1, "Radio_Off", "TAXI_SOUNDS", 0, 0)
                        end
                        break
                    end
                end
            end)
        end

        callid = math.random(200, 250)
        streetcode = GetStreetNameAtCoord(selected.x, selected.y, selected.z)
        streetname = GetStreetNameFromHashKey(streetcode)

        BeginTextCommandThefeedPost("TWOSTRINGS")
        AddTextComponentSubstringPlayerName("Prisoner Transport Escort Request ~o~"..streetname.."~s~.")
        AddTextComponentSubstringPlayerName("~n~~o~30~s~ Seconds to Respond.")
        EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
        EndTextCommandThefeedPostTicker(false, false)

        Citizen.CreateThread(function()
            timer = 30
            calloutAccepted = false
            displayText = true

            DrawCalloutText()

            while timer > 0 do
                Wait(1000)
                timer = timer - 1
            end

            displayText = false

            if calloutAccepted then
                Notify('Call Accepted!')
                StartEvent()
            else
                Notify('Call Timeout!')
                RemoveBlip(blip)
				local soundName = RadioCalls[math.random(#RadioCalls)]
				TriggerServerEvent("InteractSound_SV:PlayOnSource", soundName, 0.2)
            end
        end)

        function StartEvent()
			blip = AddBlipForCoord(selected)
			SetBlipSprite(blip, 56)
			SetBlipScale(blip, 1.2)
			SetBlipColour(blip, 29)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Prisoner Escort")
			EndTextCommandSetBlipName(blip)
            SetBlipRoute(blip, true)
			CreateThread(function()
				local escortSpawned = false
		
				while true do
					Wait(1000)
					
					local playerPed = PlayerPedId()
					local playerCoords = GetEntityCoords(playerPed)
					local distance = #(playerCoords - vector3(selected.x, selected.y, selected.z))
					-- Spawn the escort only once when within 200 units
					if distance < 200 and not escortSpawned then
						escortSpawned = true
						SpawnEscort()
					end
		
					-- Wait for proper vehicle
					if distance < 50 and escortSpawned then
						if GetVehicleClass(GetVehiclePedIsIn(playerPed, false)) == 18 then
							canBeginEscort = true
							break
						else
							Notify("Must be in a ~b~marked emergency vehicle~s~ to begin escort.")
						end
					end
				end
			end)
		end

		local prisoners = {}
		
		local function loadModel(model)
			RequestModel(model)
			local retries = 0
			while not HasModelLoaded(model) do
				Wait(100)
				retries = retries + 1
				if retries > 100 then
					print("Model failed to load:", model)
					return false
				end
			end
			return true
		end
		
        function SpawnEscort()
			local copModel = `s_m_y_cop_01`
			local prisonerModel = `s_m_y_prisoner_01`
			local sheriffModel = `s_m_y_sheriff_01`
			local rifleHash = `WEAPON_CARBINERIFLE`
			local cruiserModel = cruiserModels[math.random(#cruiserModels)]
		
			RequestModel(busModel)
			RequestModel(driverModel)
			RequestModel(cruiserModel)
			RequestModel(copModel)
			RequestModel(prisonerModel)
			RequestModel(sheriffModel)
			RemoveBlip(blip)
		
			if not (
				loadModel(busModel) and
				loadModel(driverModel) and
				loadModel(cruiserModel) and
				loadModel(copModel) and
				loadModel(prisonerModel) and
				loadModel(sheriffModel)
			) then
				print("🚫 Model loading failed. Escort not spawned.")
				return
			end

		
			-- Create bus
			bus = CreateVehicle(busModel, selected.x, selected.y, selected.z, selected.w, true, true)
			SetVehicleOnGroundProperly(bus)
			busDriver = CreatePedInsideVehicle(bus, 4, driverModel, -1, true, true)
			SetPedCanBeDraggedOut(busDriver, false)
			SetBlockingOfNonTemporaryEvents(busDriver, true)
		
			-- Spawn prisoners + sheriffs to the right of the bus
			local busPos = GetEntityCoords(bus)
			local busHeading = GetEntityHeading(bus)
			local spawnDistance = 3.0
			local angleOffset = 0.0
		
			local baseRightSpawn = vector3(
				busPos.x + math.cos(math.rad(busHeading + angleOffset)) * spawnDistance,
				busPos.y + math.sin(math.rad(busHeading + angleOffset)) * spawnDistance,
				busPos.z
			)
			
			local offsetX = math.cos(math.rad(busHeading + angleOffset)) * (spawnDistance)
			local offsetY = math.sin(math.rad(busHeading + angleOffset)) * (spawnDistance)
			local offset = vector3(busPos.x + offsetX, busPos.y + offsetY, busPos.z)
		
			local success, spawnPos, heading = GetClosestVehicleNode(baseRightSpawn.x, baseRightSpawn.y, baseRightSpawn.z, 1, 3.0, 0)
		
			if success then
				-- Sheriff Driver (first officer)
				local driverOffset = vector3(spawnPos.x, spawnPos.y, spawnPos.z)
				sheriffDriver = CreatePed(4, sheriffModel, offset.x + 2.5, offset.y , offset.z, heading, true, true)
				SetEntityAsMissionEntity(sheriffDriver, true, true)
				GiveWeaponToPed(sheriffDriver, rifleHash, 100, true, true)
				SetEntityHeading(sheriffDriver, busHeading +90)
				SetPedCanSwitchWeapon(sheriffDriver, false)
				TaskStartScenarioInPlace(sheriffDriver, "WORLD_HUMAN_GUARD_STAND", 0, true)
				SetBlockingOfNonTemporaryEvents(sheriffDriver, true)
				SetVehicleOnGroundProperly(sheriffDriver)
		
				-- Sheriff Passenger (second officer)
				local passengerOffset = vector3(spawnPos.x + 1.5, spawnPos.y, spawnPos.z)
				sheriffPassenger = CreatePed(4, sheriffModel, offset.x + 2.5, offset.y - 2.0, offset.z, heading, true, true)
				SetEntityAsMissionEntity(sheriffPassenger, true, true)
				SetEntityHeading(sheriffPassenger, busHeading +90)
				GiveWeaponToPed(sheriffPassenger, rifleHash, 100, true, true)
				SetPedCanSwitchWeapon(sheriffPassenger, false)
				TaskStartScenarioInPlace(sheriffPassenger, "WORLD_HUMAN_GUARD_STAND", 0, true)
				SetBlockingOfNonTemporaryEvents(sheriffPassenger, true)
				SetVehicleOnGroundProperly(sheriffPassenger)
				
				SetEntityInvincible(sheriffDriver, true)
				SetEntityInvincible(sheriffPassenger, true)
		
				-- Spawn prisoners further to the right
				for i = 2, 7 do
					
		
					local prisoner = CreatePed(4, prisonerModel, offset.x, offset.y, offset.z, heading, true, true)
					SetEntityAsMissionEntity(prisoner, true, true)
					TaskStartScenarioInPlace(prisoner, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
					SetEntityInvincible(prisoner, true)
					SetBlockingOfNonTemporaryEvents(prisoner, true)
		
					RequestAnimDict("mp_arresting")
					while not HasAnimDictLoaded("mp_arresting") do Wait(0) end
					TaskPlayAnim(prisoner, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
					table.insert(prisoners, prisoner)
				end
			end
		
			-- Spawn cruiser behind bus
			local behindBus = GetOffsetFromEntityInWorldCoords(bus, 0.0, -10.0, 0.0)
			cruiser = CreateVehicle(cruiserModel, behindBus.x, behindBus.y, behindBus.z, busHeading, true, true)
			SetVehicleOnGroundProperly(cruiser)
			SetEntityAsMissionEntity(cruiser, true, true)
			SetVehicleSiren(cruiser, true)
		
			cruiserBlip = AddBlipForEntity(cruiser)
			SetBlipSprite(cruiserBlip, 41)
			SetBlipScale(cruiserBlip, 0.3)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Escort Cruiser")
			EndTextCommandSetBlipName(cruiserBlip)
		
			-- Begin boarding prisoners, then sheriffs enter vehicle
			CreateThread(function()
				for i, prisoner in ipairs(prisoners) do
					ClearPedTasksImmediately(prisoner)
					Wait(100)
					TaskEnterVehicle(prisoner, bus, -1, i - 1, 1.0, 1, 0)
					while not IsPedInVehicle(prisoner, bus, false) do Wait(100) end
					Wait(500)
				end
		
				-- Clear sheriffs from idle and board cruiser
				ClearPedTasksImmediately(sheriffDriver)
				ClearPedTasksImmediately(sheriffPassenger)
		
				TaskEnterVehicle(sheriffDriver, cruiser, -1, -1, 1.0, 1, 0)      -- driver
				TaskEnterVehicle(sheriffPassenger, cruiser, -1, 0, 1.0, 1, 0)    -- front passenger
		
				while not IsPedInVehicle(sheriffDriver, cruiser, false) do Wait(100) end
				while not IsPedInVehicle(sheriffPassenger, cruiser, false) do Wait(100) end
		
				Notify("All prisoners secured. Awaiting escort authorization...")
		
				while not canBeginEscort do Wait(500) end
				Notify("Escort Authorized. Proceeding.")
				BeginEscort()
			end)
		
			-- Bus blip
			escortBlip = AddBlipForEntity(bus)
			SetBlipSprite(escortBlip, 56)
			SetBlipColour(escortBlip, 29)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Transport Bus")
			EndTextCommandSetBlipName(escortBlip)
		end

		local spawnedGuards = {}

		function SpawnPrisonGuards()
			local guardModel = `s_m_m_prisguard_01`
			RequestModel(guardModel)
			while not HasModelLoaded(guardModel) do Wait(100) end
		
			local guardPositions = {
				{ coords = vector3(1852.67, 2612.93, 45.67), heading = 296.28 },
				{ coords = vector3(1852.3, 2603.46, 45.67), heading = 283.59 }	
			}
		
			for _, pos in pairs(guardPositions) do
				local guard = CreatePed(4, guardModel, pos.coords.x, pos.coords.y, pos.coords.z, pos.heading, true, true)
				SetEntityAsMissionEntity(guard, true, true)
				SetBlockingOfNonTemporaryEvents(guard, true)
				TaskStartScenarioInPlace(guard, "WORLD_HUMAN_GUARD_STAND", 0, true)
				table.insert(spawnedGuards, guard)
			end
		end

		function BeginEscort()
			local reachedFirstPoint = false
			local escortComplete = false
			local guardsSpawned = false
		
			RemoveBlip(blip)
			Notify("Escort starting...")
			
			SetVehicleDoorShut(bus, 3, false, true)
			SetVehicleDoorShut(bus, 4, false, true)
			local drivingStyle = 1074528293 -- Aggressive + road rule ignorance
		
			SetBlockingOfNonTemporaryEvents(busDriver, true)
		
			-- Begin escort behavior
			TaskVehicleEscort(sheriffDriver, cruiser, bus, -1, 90.0, drivingStyle, 5.0, 0, 0)
			TaskVehicleDriveToCoordLongrange(busDriver, bus, prisonCoords.x, prisonCoords.y, prisonCoords.z, 60.0, drivingStyle, 10.0)
			
			SetDriverAggressiveness(sheriffDriver, 1.0)
			SetDriverAggressiveness(busDriver, 1.0)
			SetDriverAbility(busDriver, 1.0)
			SetDriverAbility(sheriffDriver, 1.0)
		
			-- Monitoring for fail/guard spawn
			CreateThread(function()
				while true do
					Wait(2000)
					if escortComplete then break end
					if not DoesEntityExist(bus) then break end
		
					local playerCoords = GetEntityCoords(PlayerPedId())
					local busCoords = GetEntityCoords(bus)
					local dist = #(playerCoords - busCoords)
		
					if dist > 150.0 and not reachedFirstPoint then
						Notify("You have strayed too far from the prisoner transport! Escort failed.")
						CleanupEscort()
						escortComplete = true
						break
					end
		
					if not guardsSpawned and #(busCoords - prisonCoords) < 50.0 then
						guardsSpawned = true
						SpawnPrisonGuards()
					end
				end
			end)
		
			-- Handle yard transition and final cleanup
			CreateThread(function()
				while true do
					Wait(1000)
		
					if not reachedFirstPoint then
						local busCoords = GetEntityCoords(bus)
						if #(busCoords - prisonCoords) < 20.0 then
							reachedFirstPoint = true
							Notify("Transport arriving at outer gate, please wait outside...")
		
							-- Reassign drive task to slow for inner yard
							TaskVehicleDriveToCoord(busDriver, bus, prisonInnerYard.x, prisonInnerYard.y, prisonInnerYard.z, 5.0, 1, busModel, 786603, 5.0, true)
							TaskVehicleDriveToCoord(sheriffDriver, cruiser, 1854.94, 2592.58, 45.0, 15.0, 1, cruiser, 786603, 1.0, true)
						end
					else
						local busCoords = GetEntityCoords(bus)
						if #(busCoords - prisonInnerYard) < 15.0 then
							Notify("Escort Complete.")
							CleanupEscort()
							TriggerServerEvent("cl-police:server:Pay", "escort") -- Not used unless wanting to reward player for job complete
							-- Delete all prisoners
							for _, ped in ipairs(prisoners) do
								if DoesEntityExist(ped) then DeleteEntity(ped) end
							end
		
							-- Delete vehicles and blips
							if DoesEntityExist(busDriver) then DeleteEntity(busDriver) end
							if DoesEntityExist(bus) then DeleteEntity(bus) end
							if DoesEntityExist(sheriffDriver) then DeleteEntity(sheriffDriver) end
							if DoesEntityExist(cruiser) then DeleteEntity(cruiser) end
							if DoesBlipExist(escortBlip) then RemoveBlip(escortBlip) end
							if DoesBlipExist(cruiserBlip) then RemoveBlip(cruiserBlip) end
							if DoesEntityExist(sheriffPassenger) then DeleteEntity(sheriffPassenger) end
							CleanupEscort()
							escortComplete = true
							break
						end
					end
				end
			end)
		end

		
		function CleanupEscort()
			-- Bus + Driver
			if DoesEntityExist(bus) then DeleteEntity(bus) end
			if DoesEntityExist(busDriver) then DeleteEntity(busDriver) end
		
			-- Cruiser + Driver
			if DoesEntityExist(cruiser) then DeleteEntity(cruiser) end
			if DoesEntityExist(sheriffDriver) then DeleteEntity(sheriffDriver) end
			if DoesEntityExist(sheriffPassenger) then DeleteEntity(sheriffPassenger) end
		
			-- Guards
			for _, guard in ipairs(spawnedGuards) do
				if DoesEntityExist(guard) then DeleteEntity(guard) end
			end
			spawnedGuards = {}
			for _, ped in ipairs(prisoners) do
				if DoesEntityExist(ped) then
					DeleteEntity(ped)
				end
			end
			prisoners = {}
			
			-- Blips
			if DoesBlipExist(escortBlip) then RemoveBlip(escortBlip) end
			if DoesBlipExist(cruiserBlip) then RemoveBlip(cruiserBlip) end
		end

    end,
	
	

}