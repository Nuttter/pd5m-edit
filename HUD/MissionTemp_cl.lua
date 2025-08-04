local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('pd5m:hud:UpdateMissionInformation')
AddEventHandler('pd5m:hud:UpdateMissionInformation', function(AmbientInfo)
  MssAmbientEventTriggered = AmbientInfo
end)

local ShowMissionMenu = false

CreateThread(function()
  while true do
	PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData ~= nil then
      if PlayerData.job ~= nil then
        if PlayerData.job.name ~= nil then
			if PlayerData.job.name == 'police' then
            ShowMissionMenu = true
			else 
				ShowMissionMenu = false
          end
        end
      end
    end
    Wait(5000)
  end
end)



CreateThread(function()
  while true do
    if ShowMissionMenu then
      BeginTextCommandDisplayText("STRING")
      AddTextComponentSubstringPlayerName('Ambient:')
      SetTextCentre(true)
      SetTextColour(255, 255, 255, 255)
      SetTextScale(0.5, 0.35)
      SetTextOutline()
      EndTextCommandDisplayText(0.1808, 0.862)
      if MssAmbientEventTriggered then
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName('running')
        SetTextColour(255, 0, 0, 255)
        SetTextScale(0.5, 0.35)
        SetTextOutline()
        EndTextCommandDisplayText(0.2055, 0.862)
      else
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName('available')
        SetTextColour(0, 255, 0, 255)
        SetTextScale(0.5, 0.35)
        SetTextOutline()
        EndTextCommandDisplayText(0.2055, 0.862)
      end
    end
    Wait(0)
  end
end)
