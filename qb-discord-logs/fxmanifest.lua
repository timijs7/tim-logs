fx_version 'cerulean'
game 'gta5'

author 'timijs7'
description 'Discord Log System for Qbox/QBCore with per-category webhooks'
version '1.0.0'

shared_script 'config.lua'

server_scripts {
  'server/server.lua'
}

client_scripts {
  'client/client.lua'
}

dependency 'qb-core'