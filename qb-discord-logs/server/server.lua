local QBCore = exports['qb-core']:GetCoreObject()

local function GetIdentifiers(src)
  local ids = { steam = nil, license = nil, discord = nil }
  for _, id in ipairs(GetPlayerIdentifiers(src)) do
    if id:find('steam:') then ids.steam = id end
    if id:find('license:') then ids.license = id end
    if id:find('discord:') then ids.discord = id:gsub('discord:', '') end
  end
  return ids
end

local function FormatIdentifiers(ids)
  local parts = {}
  if Config.ShowIdentifiers.steam then table.insert(parts, 'steam: ' .. (ids.steam or 'n/a')) end
  if Config.ShowIdentifiers.license then table.insert(parts, 'license: ' .. (ids.license or 'n/a')) end
  if Config.ShowIdentifiers.discord then
    local tag = ids.discord and ('<@' .. ids.discord .. '>') or 'n/a'
    table.insert(parts, 'discord: ' .. tag)
  end
  return table.concat(parts, '\n')
end

local function SendDiscord(category, title, description, fields)
  local url = Config.Webhooks[category]
  if not url or url == '' then return end
  local embed = {
    title = title,
    description = description,
    color = Config.Colors[category] or 0,
    fields = fields or {},
    footer = { text = Config.ServerName },
    timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
  }
  PerformHttpRequest(url, function() end, 'POST', json.encode({ embeds = { embed } }), { ['Content-Type'] = 'application/json' })
end

AddEventHandler('playerJoining', function(name, setKickReason, deferrals)
  local src = source
  SendDiscord('join', 'Player Joined', string.format('**%s** (ID %d) joined.', name, src), {
    { name = 'Identifiers', value = FormatIdentifiers(GetIdentifiers(src)), inline = false }
  })
end)

AddEventHandler('playerDropped', function(reason)
  local src = source
  local name = GetPlayerName(src) or ('ID ' .. src)
  SendDiscord('leave', 'Player Left', string.format('**%s** (ID %d) left. Reason: %s', name, src, reason or 'unknown'), {
    { name = 'Identifiers', value = FormatIdentifiers(GetIdentifiers(src)), inline = false }
  })
end)

AddEventHandler('chatMessage', function(src, name, msg)
  if Config.BlockChatWebhookIfMessageStartsWithSlash and msg:sub(1,1) == '/' then return end
  SendDiscord('chat', 'Chat Message', string.format('**%s** (ID %d): %s', name, src, msg), {
    { name = 'Identifiers', value = FormatIdentifiers(GetIdentifiers(src)), inline = false }
  })
end)

RegisterNetEvent('qb-discord-logs:moneyChange', function(targetSrc, account, oldAmount, newAmount, reason)
  local name = GetPlayerName(targetSrc) or ('ID ' .. targetSrc)
  SendDiscord('player_money', 'Money Change', string.format('**%s** %s: %s -> %s (%s)', name, account, tostring(oldAmount), tostring(newAmount), reason or ''), {
    { name = 'Identifiers', value = FormatIdentifiers(GetIdentifiers(targetSrc)), inline = false }
  })
end)

RegisterNetEvent('qb-discord-logs:cuff', function(cufferSrc, targetSrc, state)
  local cuffer = GetPlayerName(cufferSrc) or ('ID ' .. cufferSrc)
  local target = GetPlayerName(targetSrc) or ('ID ' .. targetSrc)
  SendDiscord('cuffing', state and 'Cuffed' or 'Uncuffed', string.format('**%s** %s **%s**', cuffer, state and 'cuffed' or 'uncuffed', target), {
    { name = 'Officer IDs', value = FormatIdentifiers(GetIdentifiers(cufferSrc)), inline = false },
    { name = 'Target IDs', value = FormatIdentifiers(GetIdentifiers(targetSrc)), inline = false },
  })
end)

RegisterNetEvent('qb-discord-logs:armory', function(officerSrc, action, item, count)
  local officer = GetPlayerName(officerSrc) or ('ID ' .. officerSrc)
  SendDiscord('police_armory', 'Police Armory', string.format('**%s** %s %dx %s', officer, action or 'took', count or 1, item or 'unknown'), {
    { name = 'Officer IDs', value = FormatIdentifiers(GetIdentifiers(officerSrc)), inline = false },
  })
end)

RegisterNetEvent('qb-discord-logs:confiscate', function(officerSrc, targetSrc, items)
  local officer = GetPlayerName(officerSrc) or ('ID ' .. officerSrc)
  local target = GetPlayerName(targetSrc) or ('ID ' .. targetSrc)
  local desc = ('Items confiscated from %s:\n'):format(target)
  for _, it in ipairs(items or {}) do
    desc = desc .. string.format('- %dx %s\n', it.count or 1, it.label or it.name or 'item')
  end
  SendDiscord('police_confiscate', 'Confiscation', string.format('**%s** confiscated items.\n%s', officer, desc), {
    { name = 'Officer IDs', value = FormatIdentifiers(GetIdentifiers(officerSrc)), inline = false },
    { name = 'Target IDs', value = FormatIdentifiers(GetIdentifiers(targetSrc)), inline = false },
  })
end)

RegisterNetEvent('qb-discord-logs:death', function(victimSrc, killerSrc, weapon)
  local victim = GetPlayerName(victimSrc) or ('ID ' .. victimSrc)
  local killer = killerSrc and (GetPlayerName(killerSrc) or ('ID ' .. killerSrc)) or 'Unknown'
  SendDiscord('death', 'Player Death', string.format('Victim: **%s** | Killer: **%s** | Weapon: %s', victim, killer, weapon or 'unknown'), {
    { name = 'Victim IDs', value = FormatIdentifiers(GetIdentifiers(victimSrc)), inline = false },
    { name = 'Killer IDs', value = killerSrc and FormatIdentifiers(GetIdentifiers(killerSrc)) or 'N/A', inline = false },
  })
end)

RegisterNetEvent('qb-discord-logs:shot', function(src, weaponLabel, coords)
  local name = GetPlayerName(src) or ('ID ' .. src)
  local loc = coords and string.format('%.1f, %.1f, %.1f', coords.x, coords.y, coords.z) or 'unknown'
  SendDiscord('shooting', 'Gunshot', string.format('**%s** fired %s at %s', name, weaponLabel or 'unknown', loc), {
    { name = 'Shooter IDs', value = FormatIdentifiers(GetIdentifiers(src)), inline = false }
  })
end)

RegisterNetEvent('qb-discord-logs:combatlog', function(src, context)
  local name = GetPlayerName(src) or ('ID ' .. src)
  SendDiscord('combatlog', 'Combat Log', string.format('**%s** disconnected during combat. Context: %s', name, context or ''), {
    { name = 'Identifiers', value = FormatIdentifiers(GetIdentifiers(src)), inline = false }
  })
end)

RegisterNetEvent('qb-discord-logs:admin', function(adminSrc, action, targetSrc, details)
  local admin = GetPlayerName(adminSrc) or ('ID ' .. adminSrc)
  local target = targetSrc and (GetPlayerName(targetSrc) or ('ID ' .. targetSrc)) or 'N/A'
  SendDiscord('admin', 'Admin Action', string.format('Admin: **%s** | Action: %s | Target: %s', admin, action or 'unknown', target), {
    { name = 'Admin IDs', value = FormatIdentifiers(GetIdentifiers(adminSrc)), inline = false },
    { name = 'Target IDs', value = targetSrc and FormatIdentifiers(GetIdentifiers(targetSrc)) or 'N/A', inline = false },
    { name = 'Details', value = details or 'none', inline = false }
  })
end)