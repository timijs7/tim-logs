Config = {
  ServerName = 'Your Server Name',
  ShowIdentifiers = { steam = true, license = true, discord = true },
  Webhooks = {
    join = 'https://discord.com/api/webhooks/REPLACE_JOIN',
    leave = 'https://discord.com/api/webhooks/REPLACE_LEAVE',
    chat = 'https://discord.com/api/webhooks/REPLACE_CHAT',
    player_money = 'https://discord.com/api/webhooks/REPLACE_PLAYER_MONEY',
    combatlog = 'https://discord.com/api/webhooks/REPLACE_COMBATLOG',
    death = 'https://discord.com/api/webhooks/REPLACE_DEATH',
    shooting = 'https://discord.com/api/webhooks/REPLACE_SHOOTING',
    police_armory = 'https://discord.com/api/webhooks/REPLACE_POLICE_ARMORY',
    police_confiscate = 'https://discord.com/api/webhooks/REPLACE_POLICE_CONFISCATE',
    cuffing = 'https://discord.com/api/webhooks/REPLACE_CUFFING',
    admin = 'https://discord.com/api/webhooks/REPLACE_ADMIN'
  },
  Colors = {
    join = 3066993, leave = 3066993, chat = 10181046, player_money = 3447003,
    combatlog = 15158332, death = 10038562, shooting = 15105570,
    police_armory = 7506394, police_confiscate = 7506394, cuffing = 7506394, admin = 16776960
  },
  BlockChatWebhookIfMessageStartsWithSlash = true
}