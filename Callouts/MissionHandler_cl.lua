local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('pd5m:mss:TriggerAmbientEvent')
AddEventHandler('pd5m:mss:TriggerAmbientEvent', function(AmbientEventID)
	PlayerData = QBCore.Functions.GetPlayerData()
	if PlayerData.job.name == 'police' then
		TriggerServerEvent('pd5m:msssv:RegisterAmbientEventTimer', AmbientEventID)
		ListOfAmbientEvents[AmbientEventID]:Main()
	end
end)
--print(GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPlayerPed(-1))))
