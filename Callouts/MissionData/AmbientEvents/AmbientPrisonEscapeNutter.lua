Mss_Amb_PrisonEscape_Nutter = {
	Weight = 100,
	Main = function()
		
		local locations = {
			vector3(1835.96, 3028.39, 47.27),
			vector3(1035.9, 2350.19, 47.58)
		}
		
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
					AddTextComponentString("Press [~g~Y~w~] ~o~~italic~"..timer.."~italic~~w~  Seconds to Respond ~o~Prisoner Escape.")
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
		callid = math.random(75, 130)
		streetcode = GetStreetNameAtCoord(selected.x, selected.y, selected.z)
		streetname = GetStreetNameFromHashKey(streetcode)
		BeginTextCommandThefeedPost("TWOSTRINGS")
		AddTextComponentSubstringPlayerName("A prisoner has escaped Near from Bolingbroke Penitentiary search the ~o~marked~s~ area")
		AddTextComponentSubstringPlayerName("~n~ and take him back to the station!! ~o~30~s~ Seconds to Respond.")
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
				--StartEvent()
				setSearchArea()
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
		
					if distance < 200 then
						RemoveBlip(blip)
						setSearchArea()
						break
					end
				end
			end)
		end
		
		function setSearchArea()
			searchBlip = AddBlipForRadius(selected.x, selected.y, selected.z, 300.0)
			SetBlipAlpha(searchBlip, 128)
			SetBlipColour(searchBlip, 1)
			
			while true do
				Wait(1000)
				local pedcoords = GetEntityCoords(PlayerPedId())
				local dist = #(pedcoords - vector3(selected.x, selected.y, selected.z))
				if dist < 300 then
					spawnPrisoner(selected)
					Notify('Search the ~o~Marked Area~s~ for the Prisoner')
					break
				end
			end
		
		end
		
		-- Function to spawn and hide the prisoner
		function spawnPrisoner(coords)
			local pedModel = GetHashKey("s_m_y_prismuscl_01") -- Prisoner model
			RequestModel(pedModel)
		
			while not HasModelLoaded(pedModel) do
				Wait(100)
			end
		
			-- Random hide spots in the zone
			local hideSpots = {
				vector3(coords.x + 50, coords.y + 30, coords.z),
				vector3(coords.x - 100, coords.y - 10, coords.z),
				vector3(coords.x + 75, coords.y - 180, coords.z)
			}
		
			local hideSpot = hideSpots[math.random(#hideSpots)]
			prisonerPed = CreatePed(4, pedModel, hideSpot.x, hideSpot.y, hideSpot.z, 0.0, true, false)
			SetEntityAsMissionEntity(prisonerPed, true, true)
			TaskStartScenarioInPlace(prisonerPed, "WORLD_HUMAN_SMOKING", 0, true)
		
			-- Check distance from player
			CreateThread(function()
				while true do
					Wait(500)
		
					local playerPed = PlayerPedId()
					local playerCoords = GetEntityCoords(playerPed)
					local distance = #(playerCoords - GetEntityCoords(prisonerPed))
		
					if distance < 50.0 then
						TaskSmartFleePed(prisonerPed, playerPed, 200.0, -1, false, false)
						Notify("🚨 The prisoner spotted you and is fleeing!")
						RemoveBlip(searchBlip)
						searchZone:destroy()
						break
					end
				end
			end)
		end
	end,
}