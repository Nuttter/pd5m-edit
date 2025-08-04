Mss_Amb_RoadRTC_Nutter = {
	Weight = 100,
	Main = function()
		
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
			"coquetted7",
			"elegyx",
			"arbiterx",
			"niner",
			"raidenz",
			"benefacgt",
			"flash",
			"elegyheritage",
			"windsor2c",
			"sunrise1",
			"pentro2",
			"argento",
			"jester5",
			"asteropers",
			"tfdominator",
			"steed2",
			"stanley", -- remove if wanted, just funny
			"ems3",
			"victortaxi",
			"banshee3c",
			"eurosc",
			"jester4c",
			"tailgater2c",
		}
		
		local TriggerDistance = 250.0
		
		local selected = locations[math.random(#locations)]
		local displayText = true
		-- Function to draw text on HUD
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
					AddTextComponentString("Press [~g~Y~w~] ~o~~italic~"..timer.."~italic~~w~ Seconds to Respond ~o~Road Traffic Collision.")
					DrawText(0.5, 0.9)
					if IsControlJustPressed(0, 246) then -- Y Key (default 246)
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
		callid = math.random(131, 155)
		streetcode = GetStreetNameAtCoord(selected.x, selected.y, selected.z)
		streetname = GetStreetNameFromHashKey(streetcode)
		BeginTextCommandThefeedPost("TWOSTRINGS")
		AddTextComponentSubstringPlayerName("Road Traffic Collision Reported at ~o~"..streetname.."~s~.")
		AddTextComponentSubstringPlayerName("~n~~o~30~s~ Seconds to Respond.")
		EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
		EndTextCommandThefeedPostTicker(false, false)
		local blip = AddBlipForCoord(selected)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 1.2)
		SetBlipColour(blip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Stolen Vehicle")
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
						SpawnCollisionScene()
						break
					end
				end
			end)
		end
		
		local SpawnedScenes = {}
		
		function SpawnCollisionScene()
			BeginTextCommandThefeedPost("TWOSTRINGS")
			AddTextComponentSubstringPlayerName("Run driver ~o~ID's~s~ and check drivers for ~o~Alcohol~s~ or ~o~Drugs~s~.")
			AddTextComponentSubstringPlayerName("~n~Seize Vehicles and act accordingly with the drivers.")
			EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "Callout ID ~o~"..callid)
			EndTextCommandThefeedPostTicker(false, false)
			local vehicle1 = vehicleModels[math.random(#vehicleModels)]
			local vehicle2 = vehicleModels[math.random(#vehicleModels)]
			
			local ped1 = pedModels[math.random(#pedModels)]
			local ped2 = pedModels[math.random(#pedModels)]
			
			local veh1 = CreateVehicle(GetHashKey(vehicle1), selected.x + 2, selected.y, selected.z, math.random(0, 360), true, false)
			local veh2 = CreateVehicle(GetHashKey(vehicle2), selected.x - 2, selected.y, selected.z, math.random(0, 360), true, false)
			
			local TargetVehNetID1 = VehToNet(veh1)
			local TargetVehNetID2 = VehToNet(veh2)
			TriggerServerEvent('pd5m:syncsv:SetEntityAsMissionEntity', TargetNetID1)
			TriggerServerEvent('pd5m:syncsv:SetEntityAsMissionEntity', TargetNetID2)
			
			
			SetVehicleEngineHealth(veh1, 200.0)
			SetVehicleEngineHealth(veh2, 200.0)
			SetVehicleBodyHealth(veh1, 150.0)
			SetVehicleBodyHealth(veh2, 150.0)
			SetVehicleDeformationFixed(veh1)
			SetVehicleDeformationFixed(veh2)
			
			local npc1 = CreatePed(4, GetHashKey(ped1), selected + 3, selected.y, selected.z, 0.0, true, true)
			local npc2 = CreatePed(4, GetHashKey(ped2), selected.x - 3, selected.y, selected.z, 0.0, true, true)
			
			local TargetNetID1 = PedToNet(npc1)
			local TargetNetID2 = PedToNet(npc2)
			if math.random(1,100) < 20 then
				TriggerServerEvent('pd5m:syncsv:ChangePedEntry', TargetNetID1, 'flagdrunk', true)
			end
			if math.random(1,100) < 20 then
				TriggerServerEvent('pd5m:syncsv:ChangePedEntry', TargetNetID2, 'flagdrunk', true)
			end
			
			TaskStartScenarioInPlace(npc1, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
			TaskStartScenarioInPlace(npc2, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
			
			table.insert(SpawnedScenes, {veh1 = veh1, veh2 = veh2, npc1 = npc1, npc2 = npc2})
			Wait(5000)
			RemoveBlip(blip)
		end
	end,
}