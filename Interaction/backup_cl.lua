local BackupChance = 50 -- 50% chance for backup 
local PoliceVehicles = {
	"police02",
	"polnscout",
	"pgranger2",
	"buffsxpol",
}

RegisterNetEvent('pd5m:int:backupcancel')
AddEventHandler('pd5m:int:backupcancel', function()
	ClearPedTasks(npcofficer)
	DecorSetBool(polbackup, "esc_siren_enabled", false)
	SetVehicleSiren(polbackup, false)
	SetEntityAsNoLongerNeeded(npcofficer)
	SetEntityAsNoLongerNeeded(polbackup)
	RemoveBlip(backupblip)
	backup = false
	if backup then
		Notify('Police Backup Cancelled.')
	end
end)

RegisterNetEvent('pd5m:client:initbackup')
AddEventHandler('pd5m:client:initbackup', function(TargetInVeh)
	local chance = math.random(1,100)
	Wait(math.random(1000, 5000))
	if chance < BackupChance then
		Notify('Police Backup is ~g~Available.')
		print('Backup Available')
		backup = true
		
		CreateThread (function()
			while backup do
				Wait(0)
				SetTextFont(0)
				SetTextCentre(true)
				SetTextColour(255, 255, 255, 255)
				SetTextScale(0.6, 0.45)
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString("Press [~g~B~s~] To Call For Police Backup")
				DrawText(0.5, 0.9)
				if IsControlJustReleased(0, 29) then
					TriggerEvent('pd5m:client:backup', TargetInVeh)
					break
				end
			end
		end)
	else
		print('No Backup chance = '..chance)
		request = true
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

 --- Not used, I messed with a request backup function but the backup would not find the target
RegisterNetEvent('pd5m:client:requestbackup')
AddEventHandler('pd5m:client:requestbackup', function(TargetInVeh)
	if request then
		requested = true
		Notify('~b~(TEST) ~w~Backup Called.')
		TriggerEvent('pd5m:client:backup', TargetInVeh)
	else
		Notify('~r~(ERROR) ~w~No Pursuit Detected.')
	end
end)

RegisterNetEvent('pd5m:client:backup')
AddEventHandler('pd5m:client:backup', function(TargetInVeh)
	DecorRegister("esc_siren_enabled", 2)
	if backup or requested then
		local playerped = PlayerPedId()
		local polcar = PoliceVehicles[math.random(#PoliceVehicles)]
		local polmodel = "s_m_y_cop_01"
		local vehiclehash = GetHashKey(polcar)
		local polhash = GetHashKey(polmodel)
		--Notify('~r~TEST: ~w~Backup Called.')
		
		RequestModel(vehiclehash)
		
		RequestModel(polhash)
		local plyCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords, spawnHeading = getStartingLocation(plyCoords)
		polbackup = CreateVehicle(vehiclehash, spawnCoords, spawnHeading, true, true)
		npcofficer = CreatePedInsideVehicle(polbackup, 26, polhash, -1, true, true)
		SetVehicleFixed(polbackup)
		SetVehicleDirtLevel(polbackup, 0.0)
		SetVehicleSiren(polbackup, true)
		SetVehicleEngineOn(polbackup, true, false)
		DecorSetBool(polbackup, "esc_siren_enabled", true)
		SetVehicleOnGroundProperly(polbackup)
		SetEntityAsMissionEntity(npcofficer, true, true)
		backupblip = AddBlipForEntity(polbackup)
		SetBlipSprite(backupblip, 42)
		SetBlipScale(backupblip, 0.6)
		SetBlockingOfNonTemporaryEvents(npcofficer, true)
		local streetcode = GetStreetNameAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
		local streetname = GetStreetNameFromHashKey(streetcode)
		Wait(500)
		local spawned = DoesEntityExist(polbackup)
		if spawned then
			backup = false
			--Notify('~r~TEST: ~w~Backup Spawned.')
			
			BeginTextCommandThefeedPost("TWOSTRINGS")
			AddTextComponentSubstringPlayerName("A police unit is en route. Nearest unit is at ~o~"..streetname.."~s~.")
			AddTextComponentSubstringPlayerName("~n~ETA ~o~30~s~ Seconds.")
			EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "")
			EndTextCommandThefeedPostTicker(false, false)
			CreateThread (function()
				while true do
					Wait(2000)
					if IsEntityDead(TargetInVeh) then
						ClearPedTasks(npcofficer)
						DecorSetBool(polbackup, "esc_siren_enabled", false)
						SetVehicleSiren(polbackup, false)
						SetEntityAsNoLongerNeeded(npcofficer)
						SetEntityAsNoLongerNeeded(polbackup)
						RemoveBlip(backupblip)
						break
					else
						TaskVehicleChase(npcofficer, TargetInVeh)
					end
				end
			end)
		else
			--Notify('~r~(ERROR) ~w~Backup Did Not Spawn.')
			TriggerEvent('pd5m:client:backup', TargetInVeh)
		end
	else
		--Notify('~r~(ERROR) ~w~Backup Not Available.')
		BeginTextCommandThefeedPost("TWOSTRINGS")
		AddTextComponentSubstringPlayerName("There are no units available in your area.")
		EndTextCommandThefeedPostMessagetext("CHAR_CALL911", "CHAR_CALL911", false, 4, "Police Dispatch", "")
		EndTextCommandThefeedPostTicker(false, false)
	end
	
end)