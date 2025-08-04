Mss_Amb_PursuitAssist_Nutter = {
	Weight = 100,
	Main = function()
		local RadioCalls = {
			"TIMEOUT",
			"TIMEOUT2",
			"TIMEOUT3",
			"TIMEOUT4",
		}
		
		local locations = {
			vector4(187.45, -1362.66, 28.97, 323.46),
			vector4(847.59, -1609.61, 31.53, 356.54),
			vector4(908.86, 170.25, 74.18, 320.06),
			vector4(-156.83, 99.59, 70.04, 61.66),
			vector4(-296.11, -225.95, 35.99, 179.56),
			vector4(658.11, -593.91, 35.5, 243.97),
			vector4(794.51, -1222.99, 25.89, 179.82),
			vector4(521.78, -1489.28, 28.82, 167.61),
			vector4(552.28, -1874.33, 24.93, 142.23),
			vector4(77.14, -1913.06, 20.78, 47.5),
			vector4(-600.4, -1711.72, 23.12, 50.98),
			vector4(-724.79, -1173.24, 10.2, 37.45),
			vector4(-1248.04, -307.36, 36.88, 113.3),
			vector4(-1810.08, 114.48, 73.99, 48.26),
			vector4(-1435.74, 783.18, 182.95, 207.23),
			vector4(-776.65, 1255.87, 260.19, 9.14),
			vector4(-418.89, 1936.72, 207.57, 217.02),
			vector4(259.82, 2625.8, 44.5, 283.25),
			vector4(826.9, 3093.57, 41.17, 264.09),
			vector4(1912.62, 3844.19, 31.92, 299.12),
			vector4(2721.92, 4381.43, 47.44, 290.77),
			vector4(2540.9, 2702.27, 41.83, 204.93),
			vector4(2530.17, 518.52, 112.53, 181.7),
			vector4(1226.1, -1358.3, 34.7, 173.26)
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
			"callista",
			"elegyx",
			"niner",
			"raidenz",
			"benefacgt",
			"elegyheritage",
			"windsor2c",
			"sunrise1",
			"argento",
			"jester5",
			"tfdominator",
			"rumpo",
			"banshee3c",
			"eurosc",
			"jester4c",
			"tailgater2c",
			"vectrec",
			"rhinetaxi",
			"estancia",
			"sheavas",
			"severo",
		}
		
		local PoliceVehicles = {
			"police02",
			"polnscout",
			"pgranger2",
			"buffsxpol",
		}
		TriggerServerEvent("InteractSound_SV:PlayOnSource", "pursuitassist", 0.2)
		local selected = locations[math.random(#locations)]
		local displayText = true
		-- Function to draw text on HUD
		local function getStartingLocation(coords)
			local dist, vector, nNode, heading = 0, vector3(0, 0, 0), math.random(10, 20), 0
		
			while dist < math.random(50.0, 80.0) do
				nNode = nNode + math.random(10, 20)
				_, vector, heading = GetNthClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, nNode, 9, 3.0, 2.5)
				dist = #(coords - vector)
			end
		
			return vector, heading
		end
		function DrawCalloutText()
			Citizen.CreateThread(function()
				while displayText do
					Citizen.Wait(0)
					SetTextFont(4)
					SetTextScale(0.5, 0.5)
					SetTextColour(255, 255, 255, 255)
					SetTextOutline()
					SetTextEntry("STRING")
					SetTextCentre(true)
					AddTextComponentString("Press [~g~F2~w~] ~o~~italic~"..timer.."~italic~~w~  Seconds to Respond ~o~Active Pursuit.")
					DrawText(0.5, 0.9)
					if IsControlJustPressed(0, 289) then -- Y Key (default 246)
						if not calloutAccepted then
							calloutAccepted = true
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
		callid = math.random(130, 270)
		streetcode = GetStreetNameAtCoord(selected.x, selected.y, selected.z)
		streetname = GetStreetNameFromHashKey(streetcode)
		BeginTextCommandThefeedPost("TWOSTRINGS")
		AddTextComponentSubstringPlayerName("Active Pursuit, Requesting Backup on ~o~"..streetname.."~s~.")
		AddTextComponentSubstringPlayerName("~n~~o~30~s~ Seconds to Respond.")
		EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
		EndTextCommandThefeedPostTicker(false, false)
		local blip = AddBlipForCoord(selected)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 1.2)
		SetBlipColour(blip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Active Pursuit")
		EndTextCommandSetBlipName(blip)
		
		Citizen.CreateThread(function()
			timer = 30
			calloutAccepted = false
			displayText = true
		
			DrawCalloutText() -- Start rendering the text
		
			while timer > 0 do
				Citizen.Wait(1000)
				timer = timer - 1
			end
		
			displayText = false -- Stop rendering the text
		
			if calloutAccepted then
				Notify('Call Accepted!')
				StartEvent()
				SetBlipRoute(blip, true)
			else
				Notify('Call Timeout!')
				local soundName = RadioCalls[math.random(#RadioCalls)]
				TriggerServerEvent("InteractSound_SV:PlayOnSource", soundName, 0.2)
				RemoveBlip(blip)
			end
		end)
		
		function StartEvent()
			CreateThread(function()
				while true do
					Wait(1000)
					local playerCoords = GetEntityCoords(PlayerPedId())
					local distance = #(playerCoords - selected.xyz)
		
					if distance < 275 then
						RemoveBlip(blip)
						SpawnVehicle()
						break
					end
				end
			end)
		end
		
		function spawnPursuitVehicle(target)
			local vehiclehash = GetHashKey(PoliceVehicles[math.random(#PoliceVehicles)])
			local polhash = GetHashKey("s_m_y_cop_01")
			RequestModel(vehiclehash)
			RequestModel(polhash)
			
			polpursuit = CreateVehicle(vehiclehash, selected.x+5, selected.y+5, selected.z+1, selected.w, true, true)
			npcofficer = CreatePedInsideVehicle(polpursuit, 26, polhash, -1, true, true)
			
			SetVehicleFixed(polpursuit)
			SetVehicleDirtLevel(polpursuit, 0.0)
			SetVehicleEngineOn(polpursuit, true, false)
			SetVehicleSiren(polpursuit, true)
			DecorSetBool(polpursuit, "esc_siren_enabled", true)
			SetVehicleOnGroundProperly(polpursuit)
			
			SetEntityAsMissionEntity(npcofficer, true, true)
			SetPedCanRagdoll(npcofficer, false)
			SetEntityInvincible(npcofficer, true)
			SetBlockingOfNonTemporaryEvents(npcofficer, true)
			
			pursuitblip = AddBlipForEntity(polpursuit)
			SetBlipSprite(pursuitblip, 42)
			SetBlipScale(pursuitblip, 0.6)
			
			TaskReactAndFleePed(target, npcofficer)
			TaskVehicleChase(npcofficer, target)
			SetTaskVehicleChaseBehaviorFlag(npcofficer, 16, true)
			pursuitActive = true
			Wait(1500)
			if not DoesEntityExist(polpursuit) then
				spawnPursuitVehicle(target)
			end
	
		end
		
		function SpawnVehicle()
			local playerped = GetPlayerPed(-1)
			local pedModel = GetHashKey(pedModels[math.random(#pedModels)])
			local vehicleModel = GetHashKey(vehicleModels[math.random(#vehicleModels)])
		
			RequestModel(pedModel)
			RequestModel(vehicleModel)
		
			while not HasModelLoaded(pedModel) or not HasModelLoaded(vehicleModel) do
				Wait(100)
			end
			local stolenVehicle = CreateVehicle(vehicleModel, selected.xyz, selected.w, true, true)
			
			SetVehicleEngineOn(stolenVehicle, true, false)
			
			
			target = CreatePedInsideVehicle(stolenVehicle, 4, pedModel, -1, true, true)
			SetPedCombatAttributes(target, 46, true)
			SetPedMoveRateOverride(target, 0.5)
			SetBlockingOfNonTemporaryEvents(target, true)
			local TargetNetID = PedToNet(target)
			targetSpawned = true
			
			
			targetBlip = AddBlipForEntity(target)
			SetBlipSprite(targetBlip, 280)
			SetBlipColour(targetBlip, 1)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Suspect")
			EndTextCommandSetBlipName(targetBlip)
			spawnPursuitVehicle(target)
			
			TriggerServerEvent('pd5m:syncsv:SetEntityAsMissionEntity', TargetNetID)
			TriggerServerEvent('pd5m:msssv:AddAmbientEventTimer', TargetNetID)
			TriggerServerEvent('pd5m:syncsv:ChangePedEntry', TargetNetID, 'flagismissionped', true)
			
			Wait(2000)
			while targetSpawned do
				Wait(2000)
				local playerCoords = GetEntityCoords(PlayerPedId())
				local copCoords = GetEntityCoords(npcofficer)
				local targetCoords = GetEntityCoords(target)
				local dist = #(playerCoords - targetCoords)
				local copdist = #(npcofficer - targetCoords)
				local spawnCoords, spawnHeading = getStartingLocation(targetCoords)
				if not DoesEntityExist(polpursuit) or not DoesEntityExist(npcofficer) then
					print("[PursuitAssist] Officer or vehicle missing. Respawning unit...")
				
					-- Respawn further away using nearest vehicle node
					local suspectCoords = GetEntityCoords(target)
					local nodeIndex = math.random(30, 50)
					local found, spawnCoords, spawnHeading = GetNthClosestVehicleNodeWithHeading(
						suspectCoords.x, suspectCoords.y, suspectCoords.z, nodeIndex, 1, 3.0, 2.5
					)
				
					if found then
						-- Despawn any leftovers
						if DoesEntityExist(polpursuit) then DeleteEntity(polpursuit) end
						if DoesEntityExist(npcofficer) then DeleteEntity(npcofficer) end
				
						-- Spawn new pursuit vehicle from a safe distance
						local vehiclehash = GetHashKey(PoliceVehicles[math.random(#PoliceVehicles)])
						local polhash = GetHashKey("s_m_y_cop_01")
						RequestModel(vehiclehash) while not HasModelLoaded(vehiclehash) do Wait(10) end
						RequestModel(polhash) while not HasModelLoaded(polhash) do Wait(10) end
				
						polpursuit = CreateVehicle(vehiclehash, spawnCoords, spawnHeading, true, true)
						npcofficer = CreatePedInsideVehicle(polpursuit, 26, polhash, -1, true, true)
				
						SetVehicleFixed(polpursuit)
						SetVehicleSiren(polpursuit, true)
						DecorSetBool(polpursuit, "esc_siren_enabled", true)
						SetEntityInvincible(npcofficer, true)
						SetBlockingOfNonTemporaryEvents(npcofficer, true)
				
						-- Replace old blip
						if DoesBlipExist(pursuitblip) then RemoveBlip(pursuitblip) end
						pursuitblip = AddBlipForEntity(polpursuit)
						SetBlipSprite(pursuitblip, 42)
						SetBlipScale(pursuitblip, 0.6)
				
						-- Delay so it feels natural
						Wait(2000)
						TaskVehicleChase(npcofficer, target)
						SetTaskVehicleChaseBehaviorFlag(npcofficer, 16, true)
						print("[PursuitAssist] New unit re-engaged pursuit.")
					end
				end
				if not IsPedInVehicle(target, stolenVehicle, true) then
					TaskHandsUp(target, -1, 0, -1, true)
					TriggerServerEvent('pd5m:syncsv:AddPedFlagEntry', TargetNetID, 'Arrested')
					PolExitVeh(target, npcofficer, polpursuit)
					break
				end
				
				---if copdist < 100 then
				---	SetEntityCoords(polpursuit, spawnCoords, spawnHeading, true, true, false, false)
				---end
				
				if dist > 300 and not IsEntityDead(target) then
					Notify('Suspect Has Escaped!!')
					targetSpawned = false
					calloutAccepted = false
					SetEntityAsNoLongerNeeded(target)
					SetEntityAsNoLongerNeeded(polpursuit)
					SetEntityAsNoLongerNeeded(npcofficer)
					SetVehicleSiren(polpursuit, false)
					DecorSetBool(polpursuit, "esc_siren_enabled", false)
					RemoveBlip(targetBlip)
					RemoveBlip(pursuitblip)
					pursuitActive = true
					break
				elseif IsEntityDead(target) then
					RemoveBlip(targetBlip)
					RemoveBlip(pursuitblip)
					SetEntityAsNoLongerNeeded(polpursuit)
					SetEntityAsNoLongerNeeded(npcofficer)
					SetVehicleSiren(polpursuit, false)
					DecorSetBool(polpursuit, "esc_siren_enabled", false)
					targetSpawned = false
					calloutAccepted = false
					pursuitActive = true
					break
				end
			end
			Wait(30000)
			SetEntityAsNoLongerNeeded(stolenVehicle)
		end
		
		function PolExitVeh(target, npcofficer)
			while pursuitActive do
				Wait(500)
				targetCoords = GetEntityCoords(target)
				officerCoords = GetEntityCoords(npcofficer)
				TaskGoToCoordAnyMeans(npcofficer, targetCoords, 3.0, 0, false, false, 10.0)
				local dist = #(officerCoords - targetCoords)
				--print("Cop distance to suspect - "..dist)
				if dist < 2 then
					ClearPedTasks(npcofficer)
					ClearPedTasksImmediately(target)
					ArrestPed(target, npcofficer)
					break
				end
			end
		end
		
		function ArrestPed(target, npcofficer)
			print("Attempt to arrest suspect")
			local polpursuit = GetVehiclePedIsIn(npcofficer, true)
			makeEntityFaceEntity(npcofficer, target)
			SetBlockingOfNonTemporaryEvents(target)
			local newtargetheading = GetEntityHeading(npcofficer)
			TaskAchieveHeading(target, newtargetheading, 1000)
		
			loadAnimDict("mp_arresting")
			
			Wait(1000)
			TaskPlayAnim(npcofficer, "mp_arresting", "a_uncuff", 8.0, -8, -1, 0, 0.0, 0, 0, 0)
			TaskPlayAnim(target, "mp_arresting", "idle", 8.0, 8.0, -1, 51, 1.0, 0, 0, 0)
		
			SetEnableHandcuffs(target, true)
			SetPedCanPlayGestureAnims(target, false)
			SetPedCanPlayAmbientAnims(target, false)
			SetPedCanPlayAmbientBaseAnims(target, false)
			SetPedCanPlayInjuredAnims(target, false)
			SetPedCanPlayVisemeAnims(target, false, 0)
			SetBlockingOfNonTemporaryEvents(target, true)
			Wait(4000)
			EnterPursuitVehicle(target, npcofficer)
			
		end
		function EnterPursuitVehicle(target, npcofficer)
			local polpursuit = GetVehiclePedIsIn(npcofficer, true)
			local purvehCoords = GetEntityCoords(polpursuit)
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(polpursuit)
	
			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(polpursuit, i) then
					freeSeat = i
					break
				end
			end
			
			TaskGoStraightToCoord(target, purvehCoords, 1.0, -1, 0.0, 0.0)
			
			TaskEnterVehicle(target, polpursuit, 20000, freeSeat, 1.0, 0)
			TaskEnterVehicle(npcofficer, polpursuit, 20000, -1, 1.0, 0)
			while pursuitActive do
				Wait(2000)
				if IsPedInVehicle(target, polpursuit, true) then
					DecorSetBool(polbackup, "esc_siren_enabled", false)
					SetVehicleSiren(polbackup, false)
					SetEntityAsNoLongerNeeded(npcofficer)
					SetEntityAsNoLongerNeeded(polbackup)
					--SetEntityAsNoLongerNeeded(target)
					RemoveBlip(pursuitblip)
					RemoveBlip(targetBlip)
					pursuitActive = true
					TriggerServerEvent('cl-police:server:Pay', "assist")
					Notify('Thank you for your assistance.')
					break
				end
			end
		end
	end,
}