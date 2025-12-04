local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
  while true do
    Wait(0)
    if IsPedShooting(PlayerPedId()) then
      local weaponHash = GetSelectedPedWeapon(PlayerPedId())
      local weaponLabel = tostring(weaponHash)
      local coords = GetEntityCoords(PlayerPedId())
      TriggerServerEvent('qb-discord-logs:shot', GetPlayerServerId(PlayerId()), weaponLabel, { x = coords.x, y = coords.y, z = coords.z })
      Wait(500)
    end
  end
end)

AddEventHandler('baseevents:onPlayerDied', function(killerType, deathData)
  TriggerServerEvent('qb-discord-logs:death', GetPlayerServerId(PlayerId()), nil, deathData and deathData.weapon or nil)
end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
  TriggerServerEvent('qb-discord-logs:death', GetPlayerServerId(PlayerId()), killerId, deathData and deathData.weapon or nil)
end)

RegisterNetEvent('police:client:CuffAction', function(targetServerId, state)
  TriggerServerEvent('qb-discord-logs:cuff', GetPlayerServerId(PlayerId()), targetServerId, state)
end)