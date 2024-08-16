local isOpenUi = false

function ShowUi(action, shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendNUIMessage({ action = action, data = shouldShow })
  if action == 'OpenSpawnSelector' then
    isOpenUi = true
  end
end

function SendNUI(action, data)
  SendNUIMessage({ action = action, data = data })
end

RegisterNuiCallback('ui:Close', function(data, cb)
  ShowUi(data.name, false)
  if data.name == 'OpenSpawnSelector' then
    isOpenUi = false
  end
  cb(true)
end)

function KrsSpawn(state)
  ShowUi('OpenSpawnSelector', state)
end

exports('OpenSpawnSelector', function(state)
  print(state)
  return KrsSpawn(state)
end)

RegisterNuiCallback('krs_spawnselector.SendSpawnPositionData', function(data, cb)
  local positionData = Config.SpawnPoint
  local posData = {}

  for k, v in pairs(positionData) do
    if v.positionSpawn and v.positionSpawn.xyzw then
      local DATA = {
        positionSpawn = {
          x = v.positionSpawn.xyzw.x,
          y = v.positionSpawn.xyzw.y,
          z = v.positionSpawn.xyzw.z,
          w = v.positionSpawn.xyzw.w
        },
        NameSpawnPoint = v.NameSpawnPoint,
        Description = v.Description,
        ZoneName = k
      }
      -- print("Constructed DATA: " .. json.encode(DATA, {indent = true}))
      table.insert(posData, DATA)
    else
      -- print("Error: positionSpawn or positionSpawn.xyzw is missing for key " .. k)
    end
  end

  -- print("Final posData: " .. json.encode(posData, {indent = true}))
  cb(posData)
end)

RegisterNuiCallback('krs_spawnselector.SendPlayerAction', function(data, cb)
  print(json.encode(data, {indent = true}))
  local zoneName = data.zoneName
  local zoneData = Config.SpawnPoint[zoneName]

  if not zoneData then
      print('Error: Zone data not found for zoneName:', zoneName)
      cb('error')
      return
  end

  local spawnZone = zoneData.positionSpawn
  local playerPed = cache.ped
  SetEntityCoords(playerPed, spawnZone.x, spawnZone.y, spawnZone.z, true, false)
  SetEntityHeading(playerPed, spawnZone.w)
  
  print(json.encode(spawnZone, {indent = true}))
  ShowUi('OpenSpawnSelector', false)
  SetNuiFocus(false, false)

  cb('ok')
end)


RegisterNuiCallback('krs_spawnselector.SendLastPosition', function(data, cb)
  local data = lib.callback.await('krs_spawnselector:GetPlayerLastCoords', 100)
  local decodedData = json.decode(data[1].position)
  local coords = vector3(decodedData.x, decodedData.y, decodedData.z)
  local heading = decodedData.heading
  local playerPed = cache.ped
  SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
  SetEntityHeading(playerPed, heading)
  ShowUi('OpenSpawnSelector', false)
  cb(true)
end)

-- RegisterCommand('cia', function()
--   exports['krs_spawnselector']:OpenSpawnSelector(true)
-- end)

function OpenUi()
  return isOpenUi
end
