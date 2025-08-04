Mss_Amb_ShopRobbery_Nutter = {
	Weight = 100,
	Main = function()
		local RadioCalls = {
			"TIMEOUT",
			"TIMEOUT2",
			"TIMEOUT3",
			"TIMEOUT4",
		}
		
		local stores = {
			{
				label = "24/7 Supermarket - Vinewood",
				storeCoords = vector3(378.13, 327.59, 103.57),
				vehicleCoords = vector4(365.0, 322.88, 103.26, 178.72)
			},
			{
				label = "RON Gasoline - Palmino Freeway",
				storeCoords = vector3(2554.25, 385.86, 108.62),
				vehicleCoords = vector4(2566.34, 391.15, 108.05, 357.68)
			},
			{
				label = "24/7 Supermarket - Great Ocean Hwy",
				storeCoords = vector3(-3042.72, 588.36, 7.91),
				vehicleCoords = vector4(-3032.9, 591.2, 7.36, 19.24)
			},
			{
				label = "24/7 Supermarket - Chumash",
				storeCoords = vector3(-3243.29, 1005.23, 12.83),
				vehicleCoords = vector4(-3237.36, 995.63, 12.02, 306.72)
			},
			{
				label = "Grocery Store - Harmony",
				storeCoords = vector3(544.72, 2670.54, 42.16),
				vehicleCoords = vector4(536.16, 2679.01, 41.91, 295.26)
			},
			{
				label = "24/7 Supermarket - Little Seoul",
				storeCoords = vector3(-571.49, -1015.41, 22.32),
				vehicleCoords = vector4(-567.0, -1004.91, 21.8, 291.89)
			},
			{
				label = "LTD Gasoline - Little Seoul",
				storeCoords = vector3(-712.24, -913.63, 19.22),
				vehicleCoords = vector4(-709.2, -920.92, 18.64, 168.38)
			},
			{
				label = "LTD Gasoline - Mirror Park",
				storeCoords = vector3(1159.04, -324.1, 69.21),
				vehicleCoords = vector4(1163.51, -329.77, 68.62, 248.81)
			},
			{
				label = "Robs Liquor - Vespucci Canals",
				storeCoords = vector3(-1224.37, -905.8, 12.33),
				vehicleCoords = vector4(-1225.34, -894.45, 11.99, 303.48)
			},
			{
				label = "Pit Tattoo Parlour - Vespucci Canals",
				storeCoords = vector3(-1154.09, -1424.57, 4.95),
				vehicleCoords = vector4(-1160.02, -1417.68, 4.32, 77.44)
			},
			{
				label = "BeachCombOver Barbers - Vespucci Canals",
				storeCoords = vector3(-1287.14, -1116.39, 6.99),
				vehicleCoords = vector4(-1294.67, -1113.11, 6.04, 43.63)
			},
			{
				label = "LTD Gasoline - Grove Street",
				storeCoords = vector3(-50.04, -1756.26, 29.42),
				vehicleCoords = vector4(-57.55, -1762.46, 28.45, 149.39)
			},
			{
				label = "LTD Gasoline - Innocence Blvd",
				storeCoords = vector3(-343.82, -1483.02, 30.76),
				vehicleCoords = vector4(-337.97, -1476.24, 30.25, 335.75)
			},
			{
				label = "24/7 Supermarket - Innocence Blvd",
				storeCoords = vector3(26.64, -1340.14, 29.5),
				vehicleCoords = vector4(25.85, -1353.46, 29.0, 163.0)
			},
			{
				label = "LTD Gasoline - Fenwell PL",
				storeCoords = vector3(647.43, 265.93, 103.3),
				vehicleCoords = vector4(642.33, 273.69, 102.8, 49.0)
			},
			{
				label = "LTD Gasoline - Banham Canyon Dr",
				storeCoords = vector3(-1825.22, 791.61, 138.2),
				vehicleCoords = vector4(-1813.42, 795.71, 137.83, 15.35)
			},
			{
				label = "Vinewood Pawn & Jewelry - Boulevard Del Perro",
				storeCoords = vector3(-1459.34, -413.63, 35.75),
				vehicleCoords = vector4(-1459.6, -417.83, 35.23, 98.12)
			},
		}
		
		local pedModels = {
			"a_m_m_eastsa_02",
			"a_m_y_breakdance_01",
			"a_m_y_eastsa_02",
			"a_m_m_skater_01",
			"a_m_m_og_boss_01",
			"a_m_m_hillbilly_02",
			"a_m_m_soucent_03",
			"a_m_m_skidrow_01",
			"a_m_m_salton_01",
		}
		local vehicleModels = {
			"gaulle",
			"fireboltc",
			"dominator",
			"arbiterx",
			"chavos2",
			"clubgtr",
			"speedo",
			"flash",
			"elegyheritage",
			"arias",
			"sunrise1",
			"contender2s",
			"everonb",
			"indiana",
			"rebel5",
			"imperial",
			"steed2",
			"stanley", -- remove if wanted, just funny
		}
		TriggerServerEvent("InteractSound_SV:PlayOnSource", "robbery", 0.2)
		local selected = stores[math.random(#stores)]
		--local robberyAccepted = false
		local displayText = true
		-- Function to draw text on HUD
		function DrawRobberyText()
			Citizen.CreateThread(function()
				while displayText do
					Citizen.Wait(0)
					SetTextFont(4)
					SetTextScale(0.5, 0.5)
					SetTextColour(255, 255, 255, 255)
					SetTextOutline()
					SetTextEntry("STRING")
					SetTextCentre(true)
					AddTextComponentString("Press [~g~F2~w~] ~o~~italic~"..timer.."~italic~~w~  Seconds to Respond ~o~Active Robbery.")
					DrawText(0.5, 0.9)
					if IsControlJustPressed(0, 289) then -- Y Key (default 246)
						if not robberyAccepted then
							robberyAccepted = true
							displayText = false -- Stop rendering the text
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
		callid = math.random(33, 75)
		BeginTextCommandThefeedPost("TWOSTRINGS")
		AddTextComponentSubstringPlayerName("Reported Robbery at ~o~"..selected.label.."~s~.")
		AddTextComponentSubstringPlayerName("~n~~o~30~s~ Seconds to Respond.")
		EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
		EndTextCommandThefeedPostTicker(false, false)
		local blip = AddBlipForCoord(selected.storeCoords)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 1.2)
		SetBlipColour(blip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Store Robbery")
		EndTextCommandSetBlipName(blip)
		
		Citizen.CreateThread(function()
			timer = 30
			robberyAccepted = false
			displayText = true
		
			DrawRobberyText() -- Start rendering the text
		
			while timer > 0 do
				Citizen.Wait(1000)
				timer = timer - 1
			end
		
			displayText = false -- Stop rendering the text
		
			if robberyAccepted then
				Notify('Call Accepted!')
				StartRobbery()
				SetBlipRoute(blip, true)
			else
				Notify('Call Timeout!')
				local soundName = RadioCalls[math.random(#RadioCalls)]
				TriggerServerEvent("InteractSound_SV:PlayOnSource", soundName, 0.2)
				RemoveBlip(blip)
			end
		end)
		
		function StartRobbery()
			CreateThread(function()
				while true do
					Wait(1000)
					local playerCoords = GetEntityCoords(PlayerPedId())
					local distance = #(playerCoords - selected.storeCoords)
		
					if distance < 200 then
						RemoveBlip(blip)
						SpawnRobber()
						break
					end
				end
			end)
		end
		
		function SpawnRobber()
			local playerped = GetPlayerPed(-1)
			local pedModel = GetHashKey(pedModels[math.random(#pedModels)])
			local vehicleModel = GetHashKey(vehicleModels[math.random(#vehicleModels)]) 
			
			PlaySoundFromCoord(-1, "ALARM", selected.storeCoords, "DLC_HEIST_HACKING_SNAKE_SOUNDS", false, 0, false)

			RequestModel(pedModel)
			RequestModel(vehicleModel)
		
			while not HasModelLoaded(pedModel) or not HasModelLoaded(vehicleModel) do
				Wait(100)
			end
		
			
			target = CreatePed(4, pedModel, selected.storeCoords, 0.0, true, true)
			SetPedCombatAttributes(target, 46, true)
			SetBlockingOfNonTemporaryEvents(target, true)
			local TargetNetID = PedToNet(target)
			targetSpawned = true
			TriggerEvent('pd5m:int:weaponizeped', target)
			
			local robberyBlip = AddBlipForEntity(target)
			SetBlipSprite(robberyBlip, 280)
			SetBlipColour(robberyBlip, 1)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Suspect")
			EndTextCommandSetBlipName(robberyBlip)
		
			local robberyVehicle = CreateVehicle(vehicleModel, selected.vehicleCoords.xyz, selected.vehicleCoords.w, true, false)
			SetVehicleDoorsLocked(robberyVehicle, 1)
		
			
			--TaskGoToCoordAnyMeans(target, selected.vehicleCoords.xyz, 2.0, robberyVehicle, 0, 786603, 0)
			--Wait(5000)
			TaskEnterVehicle(target, robberyVehicle, -1, -1, 2.0, 1, 0)
			Wait(3000)
			TriggerServerEvent('pd5m:syncsv:SetEntityAsMissionEntity', TargetNetID)
			TriggerServerEvent('pd5m:msssv:AddAmbientEventTimer', TargetNetID)
			TriggerServerEvent('pd5m:syncsv:ChangePedEntry', TargetNetID, 'flagismissionped', true)
			CreateThread(function()
				while true do
				Wait(0)
					if IsPedInAnyVehicle(target, false) then
						TriggerEvent('pd5m:client:initbackup', target)
						TaskReactAndFleePed(target, playerped)
						break
					end
				end
			end)
			while targetSpawned do
				Wait(2000)
				local playerCoords = GetEntityCoords(PlayerPedId())
				local targetCoords = GetEntityCoords(target)
				local dist = #(playerCoords - targetCoords)
				--print(dist)
		
				if dist > 300 and not IsEntityDead(target) then
					Notify('Suspect Has Escaped!!')
					RemoveBlip(robberyBlip)
					targetSpawned = false
					robberyAccepted = false
					SetEntityAsNoLongerNeeded(target)
					TriggerEvent('pd5m:int:backupcancel')
					RemoveBlip(robberyBlip)
					break
				end
				if IsEntityDead(target) then
					RemoveBlip(robberyBlip)
					targetSpawned = false
					robberyAccepted = false
					
					break
				end
			end
			Wait(30000)
			SetEntityAsNoLongerNeeded(robberyVehicle)
		end
	end,
}