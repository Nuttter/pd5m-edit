Mss_Amb_BankAlarmCheck_Nutter = {
    Weight = 100,
    Main = function()
		local RadioCalls = {
			"TIMEOUT",
			"TIMEOUT2",
			"TIMEOUT3",
			"TIMEOUT4",
		}
        local callid = math.random(300, 350)
        local calloutAccepted = false
        local displayText = true
        local timer = 30
        local clerkPed, blip
        local spawnedNPCs = {}
        local spawnedVehicles = {}
        local robbers = {}
        local clerkModel = `s_f_y_bank_01`
        local copModel = `s_m_y_cop_01`
        local robberModel = `g_m_y_mexgang_01`
        local getawayVehicleModel = `buffalo`
        local cruiserModel = `police02`
        local isRobbery = (math.random(100) <= 10) -- 50% chance of being a real robbery

        local locations = {
            {
                Label = "Pacific Standard Bank",
                Location = vector3(149.91, -1040.24, 29.37),
                Clerk = vector4(152.81, -1037.69, 29.33, 11.65),
				Getaway = vector4(157.1, -1035.87, 28.81, 309.67),
                Cruisers = {
                    vector4(142.26, -1018.71, 28.99, 221.15),
                    vector4(155.71, -1022.35, 28.98, 161.36),
                    vector4(159.93, -1029.13, 28.92, 239.16)
                },
                Robbers = {
                    vector3(147.2, -1038.35, 29.37),
                    vector3(144.72, -1039.44, 29.37)
                }
            },
            -- Add more locations here using the same structure
        }
		
		TriggerServerEvent("InteractSound_SV:PlayOnSource", "TC_SILENTALARM", 0.2)
        local selected = locations[math.random(#locations)]

        local function Notify(msg)
            SetNotificationTextEntry("STRING")
            AddTextComponentSubstringPlayerName(msg)
            DrawNotification(false, false)
        end

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
                    AddTextComponentString("Press [~g~F2~w~] ~o~~italic~"..timer.."~italic~~w~  Seconds to Respond ~o~"..selected.Label)
                    DrawText(0.5, 0.9)
                    if IsControlJustPressed(0, 289) then
                        if not calloutAccepted then
                            calloutAccepted = true
                            displayText = false
                            timer = 0
                            PlaySound(-1, "Radio_On", "TAXI_SOUNDS", 0, 0)
                            Wait(100)
                            PlaySound(-1, "Radio_Off", "TAXI_SOUNDS", 0, 0)
                        else
                            Notify('You have already responded to a callout')
                        end
                        break
                    end
                end
            end)
        end

        BeginTextCommandThefeedPost("TWOSTRINGS")
        AddTextComponentSubstringPlayerName("Silent Alarm Triggered at ~y~"..selected.Label)
        AddTextComponentSubstringPlayerName("~n~~o~30~s~ Seconds to Respond.<br> ~r~WORK IN PROGRESS~s~")
        EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
        EndTextCommandThefeedPostTicker(false, false)

        Citizen.CreateThread(function()
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
                Notify('Call Timeout.')
                if blip then RemoveBlip(blip) end
				local soundName = RadioCalls[math.random(#RadioCalls)]
				TriggerServerEvent("InteractSound_SV:PlayOnSource", soundName, 0.2)
            end
        end)

        function StartEvent()
            blip = AddBlipForCoord(selected.Location)
            SetBlipSprite(blip, 161)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 1.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Alarm Check - "..selected.Label)
            EndTextCommandSetBlipName(blip)
            SetBlipRoute(blip, true)

            CreateThread(function()
                while true do
                    Wait(1000)
                    if not calloutAccepted then return end

                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local dist = #(playerCoords - selected.Location)

                    if dist < 200.0 then
                        RemoveBlip(blip)
                        if isRobbery then
                            HandleRobbery()
                        else
                            HandleCheck()
                        end
                        break
                    end
                end
            end)
        end

        function HandleCheck()
            RequestModel(clerkModel)
            while not HasModelLoaded(clerkModel) do Wait(0) end

            clerkPed = CreatePed(4, clerkModel, selected.Clerk.x, selected.Clerk.y, selected.Clerk.z, selected.Clerk.w, true, true)
            FreezeEntityPosition(clerkPed, true)
            SetBlockingOfNonTemporaryEvents(clerkPed, true)
            SetEntityInvincible(clerkPed, true)
            TaskStartScenarioInPlace(clerkPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)

            Notify("Investigate inside and speak to the clerk.")

            CreateThread(function()
                while true do
                    Wait(1000)
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    if #(playerCoords - selected.Location) > 100.0 then break end

                    if #(playerCoords - vector3(selected.Clerk.x, selected.Clerk.y, selected.Clerk.z)) < 2.0 then
                        Notify("~g~Clerk: False alarm. Everything is fine.")
                        DeleteEntity(clerkPed)
                        break
                    end
                end
            end)
        end

        function HandleRobbery()
            -- Load models
            RequestModel(copModel)
            RequestModel(robberModel)
            RequestModel(getawayVehicleModel)
            RequestModel(cruiserModel)
			AddRelationshipGroup("ROBBERS")
			SetRelationshipBetweenGroups(1, `ROBBERS`, `ROBBERS`)

            while not HasModelLoaded(copModel) or not HasModelLoaded(robberModel) or not HasModelLoaded(getawayVehicleModel) or not HasModelLoaded(cruiserModel) do Wait(0) end

            -- Spawn police units
			for _, pos in pairs(selected.Cruisers) do
				local veh = CreateVehicle(cruiserModel, pos.x, pos.y, pos.z, pos.w, true, true)
				SetVehicleSiren(veh, true)
				SetVehicleOnGroundProperly(veh)
				SetVehicleDoorsLocked(veh, 1)
				SetEntityAsMissionEntity(veh, true, true)
			
				-- Spawn cop and force them out
				local ped = CreatePedInsideVehicle(veh, 4, copModel, -1, true, true)
				SetBlockingOfNonTemporaryEvents(ped, true)
				SetEntityAsMissionEntity(ped, true, true)
				TaskLeaveVehicle(ped, veh, 0)
				Wait(500)
				ClearPedTasksImmediately(ped)
				TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
			
				table.insert(spawnedVehicles, veh)
				table.insert(spawnedNPCs, ped)
			
				-- Blip
				local copBlip = AddBlipForEntity(ped)
				SetBlipSprite(copBlip, 60)
				SetBlipColour(copBlip, 29)
			end


            -- Spawn robbers
            for i, pos in ipairs(selected.Robbers) do
                if i <= 2 then
                    local ped = CreatePed(4, robberModel, pos.x, pos.y, pos.z, pos.w, true, true)
					SetPedRelationshipGroupHash(ped, `ROBBERS`)
                    GiveWeaponToPed(ped, (i == 1 and `WEAPON_SMG`) or `WEAPON_PUMPSHOTGUN`, 100, true, true)
                    TaskCombatHatedTargetsAroundPed(ped, 50.0, 0)
                    SetEntityAsMissionEntity(ped, true, true)
                    table.insert(robbers, ped)
                    local robBlip = AddBlipForEntity(ped)
                    SetBlipSprite(robBlip, 161)
                    SetBlipColour(robBlip, 1)
                end
            end

            -- Spawn getaway vehicle at configured location
			local getaway = selected.Getaway
			local vehicle = CreateVehicle(getawayVehicleModel, getaway.x, getaway.y, getaway.z, getaway.w, true, true)
			SetEntityAsMissionEntity(vehicle, true, true)
			
			local playerPed = PlayerPedId()
			local driverPed = nil
			
			for i, ped in ipairs(robbers) do
				TaskGoToCoordAnyMeans(ped, getaway.xyz, 3.0, 0, 0, 786603, 0xbf800000)
				if i == 1 then
					driverPed = ped
					TaskEnterVehicle(ped, vehicle, -1, -1, 3.0, 1, 0) -- driver seat
				else
					TaskEnterVehicle(ped, vehicle, -1, i - 2, 3.0, 1, 0)
				end
			end
			
			-- Flee logic once driver is in vehicle
			CreateThread(function()
				while true do
					Wait(1000)
					if DoesEntityExist(driverPed) and IsPedInAnyVehicle(driverPed, false) then
						TaskSmartFleePed(driverPed, playerPed, 500.0, -1, false, false)
						break
					end
				end
			end)


            -- Cleanup thread
            CreateThread(function()
                while true do
                    Wait(5000)
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local dist = #(playerCoords - selected.Location)

                    if dist > 200.0 then
                        for _, ped in ipairs(spawnedNPCs) do if DoesEntityExist(ped) then DeleteEntity(ped) end end
                        for _, veh in ipairs(spawnedVehicles) do if DoesEntityExist(veh) then DeleteEntity(veh) end end
                        for _, ped in ipairs(robbers) do if DoesEntityExist(ped) then DeleteEntity(ped) end end
                        if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
                        break
                    end
                end
            end)
			-- Monitor if all robbers are dead and trigger police retreat with drive away
			CreateThread(function()
				local retreated = false
				while not retreated do
					Wait(2000)
					local allDead = true
					for _, ped in ipairs(robbers) do
						if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
							allDead = false
							break
						end
					end
			
					if allDead then
						retreated = true
						Notify("All robbers neutralized. Officers returning to patrol.")
			
						for i, ped in ipairs(spawnedNPCs) do
							local veh = spawnedVehicles[i]
							if DoesEntityExist(ped) and DoesEntityExist(veh) then
								ClearPedTasksImmediately(ped)
								SetVehicleSiren(veh, false)
								Wait(5000)
								TaskEnterVehicle(ped, veh, -1, -1, 2.0, 1, 0)
			
								CreateThread(function()
									-- Wait for the ped to enter vehicle
									local attempts = 0
									while not IsPedInVehicle(ped, veh, false) and attempts < 50 do
										Wait(200)
										attempts += 1
									end
			
									if IsPedInVehicle(ped, veh, false) then
										-- Get random drive-away node
										local pedCoords = GetEntityCoords(ped)
										local success, node = GetNthClosestVehicleNode(pedCoords.x, pedCoords.y, pedCoords.z, 30, 0, 0, 0)
										if success then
											TaskVehicleDriveToCoord(ped, veh, node.x, node.y, node.z, 30.0, 0, GetEntityModel(veh), 786603, 5.0, true)
											RemoveBlip(blip)
										end
									end
								end)
							end
						end
			
						-- Final cleanup after delay
						Wait(20000)
						for _, ped in ipairs(spawnedNPCs) do
							if DoesEntityExist(ped) then DeleteEntity(ped) end
						end
						for _, veh in ipairs(spawnedVehicles) do
							if DoesEntityExist(veh) then DeleteEntity(veh) end
						end
					end
				end
			end)
        end
    end
}
