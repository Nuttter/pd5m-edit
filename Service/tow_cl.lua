-- remember to have services flag cars / peds / dead bodies as NoLongerNeeded
-- optional you can have the service remove the entities directly

-- this flag is used to interrupt any and every executing while-loop if a towtruck is cancelled.
-- When calling multiple towtrucks at the same time, cancelling one will also interrupt every other truck.
-- This is a known bug and needs to be fixed.
GlobalFlagTowCar = true

-- NetEvent to select the car to be towed.
-- Checks if the car can be towed. If yes, starts the event 'pd5m:tow:inittowtruck'.
-- Advise: Do not trigger this since it's already set for player control.



RegisterNetEvent('pd5m:tow:calltowtruck')
AddEventHandler('pd5m:tow:calltowtruck', function()
	local playerped = GetPlayerPed(-1)
	local playerpedcoords = GetEntityCoords(playerped)
	local camcoords = GetGameplayCamCoord()
	local lookingvector = GetPlayerLookingVector(playerped, 30)
	local TargetVehNetID = nil
	local TargetNetID = nil
	local target = nil
	local TargetVehFlagListIndex = nil
	local TargetFlagListIndex = nil
	local flagtowcar = false
	local flagtowing = false
	
	if not IsPedInAnyVehicle(playerped, true) then
		local flag_hasTarget, targetcoords, targetveh = GetVehInDirection(camcoords, lookingvector)
		if flag_hasTarget and GetEntityType(targetveh) == 2 then
			local distanceToTarget = GetDistanceBetweenCoords(playerpedcoords, targetcoords)
			if distanceToTarget <= 4.0 then
				if GetVehicleNumberOfPassengers(targetveh) == 0 and (IsVehicleSeatFree(targetveh, -1) or (GetPedInVehicleSeat(targetveh, -1) == 0)) then

					TargetVehNetID = VehToNet(targetveh)

					_, TargetVehFlagListIndex = SyncPedAndVeh(0, targetveh)

					flagtowing = CheckVehFlag(TargetVehNetID, 'Towing')

					if flagtowing then
						Notify('Towtruck aborted')
						GlobalFlagTowCar = false
						DeleteEntity(towtruck)
						DeleteEntity(towdriver)
						TriggerServerEvent('pd5m:towsv:aborttowtruck', TargetVehNetID)
						TriggerServerEvent('pd5m:syncsv:RemoveVehFlagEntry', TargetVehNetID, 'Towing')
					else
						TargetNetID = ClientVehConfigList[TargetVehFlagListIndex].PedNetID
						loadAnimDict("random@arrests")
						RequestAnimDict(arrests)
						TaskPlayAnim(playerped, "random@arrests", "generic_radio_enter", 1.5, 2.0, -1, 50, 2.0, 0, 0, 0 )
						print('radio call anim')
						PlaySound(-1, "Radio_On", "TAXI_SOUNDS", 0, 0)
						Wait(100)
						PlaySound(-1, "Radio_Off", "TAXI_SOUNDS", 0, 0)
						Citizen.Wait(6000)
						ClearPedTasks(playerped)
						TriggerServerEvent("InteractSound_SV:PlayOnSource", "TOWTRUCK_01", 0.2)
						if TargetNetID ~= 0 and TargetNetID ~= nil then
							target = NetToPed(TargetNetID)
							if DoesEntityExist(target) and not IsEntityDead(target) then
								TargetFlagListIndex, _ = SyncPedAndVeh(target, 0)
								flagtowcar = ClientPedConfigList[TargetFlagListIndex].flagallowcarseizure
								if flagtowcar then
									TriggerServerEvent('pd5m:syncsv:ChangePedEntry', TargetNetID, 'VehicleNetID', nil)
									TriggerServerEvent('pd5m:syncsv:ChangeVehEntry', TargetVehNetID, 'PedNetID', nil)
								end
							else
								TriggerServerEvent('pd5m:syncsv:ChangeVehEntry', TargetVehNetID, 'PedNetID', nil)
								flagtowcar = true
							end
						else
							flagtowcar = true
						end

						if flagtowcar then
							TriggerServerEvent('pd5m:syncsv:AddVehFlagEntry', TargetVehNetID, 'Towing')
							TriggerEvent('pd5m:tow:inittowtruck', TargetVehNetID)
						else
							Notify('You cannot have this car towed.')
						end
					end
				else
					Notify('Car is not empty.')
				end
			else
				Notify('Too far away.')
			end
		else
			Notify('No car found.')
		end
	end
end)

local function getStartingLocation(coords)
    local dist, vector, nNode, heading = 0, vector3(0, 0, 0), math.random(10, 20), 0

    while dist < math.random(50.0, 80.0) do
        nNode = nNode + math.random(10, 20)
        _, vector, heading = GetNthClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, nNode, 9, 3.0, 2.5)
        dist = #(coords - vector)
    end

    return vector, heading
end

-- Initializes the towtruck. Selects the station to dispatch the truck from.
-- Checks for the vehicle class and selects the appropriate truck.
-- Triggers the event 'pd5m:tow:towtruckapproach'.
-- Don't use this, trigger 'pd5m:tow:calltowtruck'.
AddEventHandler('pd5m:tow:inittowtruck', function(TargetVehNetID)
	local TowTruckNetID = 0
	local availableTrucks = {1} -- remove the 1 when reinstating the below checks
	local towtruckid = 1
	local targetveh = NetToVeh(TargetVehNetID)
	local pmodels = TowTruckDrivers
	local vehicles = {"muler"}
	local playerped = GetPlayerPed(-1)

	local tarx, tary, tarz = table.unpack(GetEntityCoords(targetveh))
	local station = nil
	local shortestdistance = 999999999
	for i, location in ipairs(list_towtruck_spawns) do
		local distance = CalculateTravelDistanceBetweenPoints(location.x, location.y, location.z, tarx, tary, tarz)
		if distance < shortestdistance then
			station = location
			shortestdistance = distance
		end
	end

	local stx = station.x
	local sty = station.y
	local stz = station.z
	local sta = station.angle

	local offx = tarx - station.x
	local offy = tary - station.y

	local VecAngle = GetHeadingFromVector_2d(offx, offy)-sta

	while VecAngle < 0 or VecAngle > 360 do
		if VecAngle < 0 then
			VecAngle = VecAngle + 360
		elseif VecAngle > 360 then
			VecAngle = VecAngle - 360
		end
		Wait(200)
	end

	if VecAngle < 270 and VecAngle > 90 then
		stx = station.xa
		sty = station.ya
		stz = station.za
		sta = station.aa
	end

	local stationvec = {x=stx, y=sty, z=stz, angle=sta}


	if #availableTrucks == 0 then
		Notify('This vehicle cannot be towed.')
		TriggerServerEvent('pd5m:syncsv:RemoveVehFlagEntry', TargetVehNetID, 'Towing')
	else
		local traveldistance = CalculateTravelDistanceBetweenPoints(stationvec.x, stationvec.y, stationvec.z, tarx, tary, tarz)
		local traveltime = 2*math.ceil(traveldistance/1000)
		

		towtruckid = availableTrucks[math.random(#availableTrucks)]
		local vehiclehash = GetHashKey(vehicles[towtruckid])
		local drivermodel = GetHashKey(pmodels[math.random(#pmodels)])

		RequestModel(vehiclehash)
		while not HasModelLoaded(vehiclehash) do
			RequestModel(vehiclehash)
			Wait(50)
		end

		RequestModel(drivermodel)
		while not HasModelLoaded(drivermodel) do
			RequestModel(drivermodel)
			Wait(50)
		end
		local plyCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords, spawnHeading = getStartingLocation(plyCoords)
		local towtruck = CreateVehicle(vehiclehash, spawnCoords, spawnHeading, true, true)
		--local towtruck = CreateVehicle(vehiclehash, stationvec.x, stationvec.y, stationvec.z, stationvec.angle, true, false)
		
		SetVehicleColours(towtruck, 38, 0)
		--local towdriver = CreatePed(26, drivermodel, stationvec.x, stationvec.y, stationvec.z+2.0, stationvec.angle, true, true)
		local towdriver = CreatePedInsideVehicle(towtruck, 26, drivermodel, -1, true, true)
		--SetPedIntoVehicle(towdriver, towtruck, -1)
		SetVehicleFixed(towtruck)
		SetVehicleOnGroundProperly(towtruck)
		SetEntityAsMissionEntity(towdriver, true, true)
		local towblip = AddBlipForEntity(towtruck)
		SetBlipColour(towblip, 9)
		SetBlipSprite(towblip, 68)
		SetBlipFlashes(towblip, true)
		SetBlockingOfNonTemporaryEvents(towdriver, true)
		ShowHeadingIndicatorOnBlip(towblip, true)

		TowTruckNetID = VehToNet(towtruck)
		table.insert(ClientSelfVehTowingList, TargetVehNetID)
		table.insert(ClientSelfTowTruckList, TowTruckNetID)
		TriggerEvent('pd5m:tow:towtruckapproach', towtruck, towtruckid, towdriver, towblip, station, targetveh)
		local NpcCoords = GetEntityCoords(towtruck)
		local streetcode = GetStreetNameAtCoord(NpcCoords.x, NpcCoords.y, NpcCoords.z)
		local streetname = GetStreetNameFromHashKey(streetcode)
		BeginTextCommandThefeedPost("TWOSTRINGS")

		AddTextComponentSubstringPlayerName("A towtruck is on ~o~" .. streetname .. "~s~.")
		AddTextComponentSubstringPlayerName("It will arrive in approximately ~o~" .. traveltime .. "~s~ minutes.")

		EndTextCommandThefeedPostMessagetext("CHAR_PROPERTY_TOWING_IMPOUND", "CHAR_PROPERTY_TOWING_IMPOUND", false, 4, 'Department of', 'Public Order and Safety')
		EndTextCommandThefeedPostTicker(false, false)
	end
end)

-- Event that is used to have a dispatched towtruck approach the car to be towed.
-- Do not use this, trigger 'pd5m:tow:calltowtruck'.
AddEventHandler('pd5m:tow:towtruckapproach', function(towtruck, towtruckid, towdriver, towblip, station, targetveh)
	local tarx, tary, tarz = table.unpack(GetEntityCoords(targetveh))
	local vehiclehash = GetHashKey(towtruck)

	--TaskVehicleDriveToCoordLongrange(towdriver, towtruck, tarx, tary, tarz, 17.0, 830, 5.0)

	local towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
	local distance = Vdist2(towx, towy, towz, tarx, tary, tarz)

	ArePathNodesLoadedInArea(towx-100.0, towy-100.0, towx+100.0, towy+100.0)

	while distance > 1500.0 and GlobalFlagTowCar do
		----print('Arriving')
		----print(distance)
		towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
		distance = Vdist2(towx, towy, towz, tarx, tary, tarz)

		if IsVehicleStopped(towtruck) and not IsVehicleStoppedAtTrafficLights(towtruck) then
			--print('I have stopped')
			if IsPointOnRoad(towx, towy, towz, towtruck) then
				--print("I'm on the road")
				local n = 0
				while IsVehicleStopped(towtruck) and n < 500 do
					--print(n)
					n = n + 1
					Wait(10)
				end
				--print('While ended')
				if n > 400 then
					--print('Changing position')
					local towpos = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, 100.0, 0.0)
					local _, pos, heading = GetClosestVehicleNodeWithHeading(towpos.x, towpos.y, towpos.z, 0, 3.0, 0)

					local offx = tarx - pos.x
					local offy = tary - pos.y
					local VecAngle = GetHeadingFromVector_2d(offx, offy)-heading

					if VecAngle < 270 and VecAngle > 90 then
						heading = heading + 180.00
					end
					SetEntityCoords(towtruck, pos.x, pos.y, pos.z, 1, 0, 0, 1)
					SetEntityCoords(towdriver, pos.x, pos.y, pos.z+2.0, 1, 0, 0, 0)
					SetEntityHeading(towtruck, heading)
					SetPedIntoVehicle(towdriver, towtruck, -1)
					SetVehicleFixed(towtruck)
					SetVehicleOnGroundProperly(towtruck)
					TaskVehicleDriveToCoordLongrange(towdriver, towtruck, tarx, tary, tarz, 17.0, 830, 5.0)
					--TaskVehicleDriveToCoord(towdriver, towtruck, tarx, tary, tarz, 5.0, 0, vehiclehash, 830, 5.0, true)
				end
			else
				--print("I'm off the road.")
				local n = 0
				while IsVehicleStopped(towtruck) and n < 500 do
					--print(n)
					n = n + 1
					Wait(10)
				end
				--print('While ended')
				if n > 400 then
					--print('Changing position')
					local _, pos, heading = GetClosestVehicleNodeWithHeading(towx, towy, towz, 0, 3.0, 0)

					local offx = tarx - pos.x
					local offy = tary - pos.y
					local VecAngle = GetHeadingFromVector_2d(offx, offy)-heading

					if VecAngle < 270 and VecAngle > 90 then
						heading = heading + 180.00
					end
					SetEntityCoords(towtruck, pos.x, pos.y, pos.z, 1, 0, 0, 1)
					SetEntityCoords(towdriver, pos.x, pos.y, pos.z+2.0, 1, 0, 0, 0)
					SetEntityHeading(towtruck, heading)
					SetPedIntoVehicle(towdriver, towtruck, -1)
					SetVehicleFixed(towtruck)
					SetVehicleOnGroundProperly(towtruck)
					TaskVehicleDriveToCoordLongrange(towdriver, towtruck, tarx, tary, tarz, 17.0, 830, 5.0)
					--TaskVehicleDriveToCoord(towdriver, towtruck, tarx, tary, tarz, 5.0, 0, vehiclehash, 830, 5.0, true)
				end
			end
		end
		Wait(1000)
	end

	if GlobalFlagTowCar then
		TriggerEvent('pd5m:tow:towtruckatscene', towtruck, towtruckid, towdriver, towblip, station, targetveh)
	else
		GlobalFlagTowCar = true
	end
end)

-- Event that is used to control the behavior of the towtruck at the seized car.
-- Do not use this, trigger 'pd5m:tow:calltowtruck'.
AddEventHandler('pd5m:tow:towtruckatscene', function(towtruck, towtruckid, towdriver, towblip, station, targetveh)
	--print('At scene')
	local tarx, tary, tarz = table.unpack(GetEntityCoords(targetveh))
	local tardimensionMin, tardimensionMax = GetModelDimensions(GetEntityModel(targetveh))
	local tarsize = tardimensionMax - tardimensionMin

	local towdimensionMin, towdimensionMax = GetModelDimensions(GetEntityModel(towtruck))
	local towsize = towdimensionMax - towdimensionMin

	local vehiclehash = GetHashKey(towtruck)
	SetVehicleIndicatorLights(towtruck, 2, true)
	SetVehicleIndicatorLights(towtruck, 1, true)

	TaskVehicleDriveToCoord(towdriver, towtruck, tarx, tary, tarz, 5.0, 0, vehiclehash, 830, 5.0, true)

	

	while true do
		Wait(500)
		local towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
		local distance = Vdist2(towx, towy, towz, tarx, tary, tarz)
		if distance < 200 then
			inrange = true
			break
		end
	end

	if inrange then

		local towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
		Wait(6000)

		local TargetVehNetID = VehToNet(targetveh)
		local TowNetID = VehToNet(towtruck)
		
		TaskVehicleTempAction(towdriver, towtruck, 24, 10000)
		TriggerServerEvent('pd5m:towsv:flatbedpickup', TargetVehNetID, TowNetID)
		
		Wait(500)
		
		TriggerEvent('pd5m:tow:towtruckdepart', towtruck, towtruckid, towdriver, towblip, station, targetveh)
		TriggerServerEvent('cl-police:server:Pay', "tow")


		--while distance > 100.0 and GlobalFlagTowCar do
		--	----print('At scene closing in')
		--	----print(distance)
		--	towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
		--	distance = Vdist2(towx, towy, towz, tarx, tary, tarz)
		--	Wait(100)
		--end
		--print('Attach Vehicle? - 2')
		--if GlobalFlagTowCar then
		--	TaskVehicleTempAction(towdriver, towtruck, 27, 10000)
		--
		--	Wait(3000)
		--
		--	local TargetVehNetID = VehToNet(targetveh)
		--	local TowNetID = VehToNet(towtruck)
		--	print('Attach Vehicle? - 3')
		--	TriggerServerEvent('pd5m:towsv:flatbedpickup', TargetVehNetID, TowNetID)
		--
		--	Wait(1000)
		--
		--	TriggerEvent('pd5m:tow:towtruckdepart', towtruck, towtruckid, towdriver, towblip, station, targetveh)
		--	TriggerServerEvent('cl-police:server:Pay', "tow")
		--else
		--	GlobalFlagTowCar = true
		--end
	else
		GlobalFlagTowCar = true
	end
end)

-- Event to control the behaviour of the towtruck departing.
-- Do not use this, trigger 'pd5m:tow:calltowtruck'.
AddEventHandler('pd5m:tow:towtruckdepart', function(towtruck, towtruckid, towdriver, towblip, station, targetveh)
	--print('Departing')
	local TargetVehNetID = VehToNet(targetveh)
	TriggerServerEvent('pd5m:syncsv:RemoveVehFlagEntry', TargetVehNetID, 'Towing')
	local vehiclehash = GetHashKey(towtruck)
	RemoveBlip(towblip)
	TaskVehicleDriveToCoordLongrange(towdriver, towtruck, station.x, station.y, station.z, 17.0, NormalDrivingBehavior, 2.0)
	--SetEntityAsNoLongerNeeded(towtruck)
	--SetEntityAsNoLongerNeeded(towdriver)
	--SetEntityAsNoLongerNeeded(targetveh)
	Wait(15000)
	DeleteEntity(targetveh)
	DeleteEntity(towtruck)
	DeleteEntity(towdriver)
	
	--local towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
	--local distance = Vdist2(towx, towy, towz, tarx, tary, tarz)
	--
	--while distance > 50.0 and DoesEntityExist(towtruck) do
	--	local towx, towy, towz = table.unpack(GetEntityCoords(towtruck))
	--	local distance = Vdist2(towx, towy, towz, tarx, tary, tarz)
	--	Wait(1000)
	--end
	--if DoesEntityExist(towtruck) then
	--	DeleteEntity(targetveh)
	--	TaskVehicleDriveWander(towdriver, towtruck, 30.0, NormalDrivingBehavior)
	--	SetVehicleIndicatorLights(towtruck, 2, false)
	--	SetVehicleIndicatorLights(towtruck, 1, false)
	--end
	
end)

-- Event to abort a dispatched towtruck.
-- Do not use this, trigger 'pd5m:towsv:aborttowtruck'.
RegisterNetEvent('pd5m:tow:aborttowtruck')
AddEventHandler('pd5m:tow:aborttowtruck', function(TargetVehNetID)
	local SelfTowTruck = false
	local TowTruckNetID = 0
	for i, NetID in ipairs(ClientSelfVehTowingList) do
		if NetID == TargetVehNetID then
			SelfTowTruck = true
			TowTruckNetID = ClientSelfTowTruckList[i]
			break
		end
	end
	if TowTruckNetID ~= 0 then
		TriggerServerEvent('pd5m:syncsv:RemoveVehFlagEntry', TargetVehNetID, 'Towing')
		towtruck = NetToVeh(TowTruckNetID)
		towdriver = GetPedInVehicleSeat(towtruck, -1)
		towblip = GetBlipFromEntity(towtruck)
		GlobalFlagTowCar = false
		RemoveBlip(towblip)
		SetVehicleIndicatorLights(towtruck, 2, false)
		SetVehicleIndicatorLights(towtruck, 1, false)
		TaskVehicleDriveWander(towdriver, towtruck, 30.0, NormalDrivingBehavior)
		SetEntityAsNoLongerNeeded(towtruck)
		SetEntityAsNoLongerNeeded(towdriver)
	end
end)

-- player used handler to get the variables the flatbedpickup-handler needs.

-- handler to have flatbed pick up cars that are beside it.
RegisterNetEvent('pd5m:tow:flatbedpickup')
AddEventHandler('pd5m:tow:flatbedpickup', function(TargetVehNetID, TowNetID)
	local targetveh = NetToVeh(TargetVehNetID)
	local towtruck = NetToVeh(TowNetID)
	AttachEntityToEntity(targetveh, towtruck, GetEntityBoneIndexByName(targetveh, "chassis"), 0.0, -2.0, 0.35, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
end)

-- Player-version of a pushcar-function. Do not use this for NPCs.
-- needs a different approach to controls than the NPC function. Don't code one as a feature of the other.
RegisterNetEvent('pd5m:tow:playerpushcar')
AddEventHandler('pd5m:tow:playerpushcar', function() -- no variables allowed

end)
