fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'whip_revive'
author 'Bacon_Space'
description 'Admin revive and heal commands for WHIP'
version '1.0.0'

dependency 'whip_core'
whip_requires '1.0'

shared_scripts {
    '@whip_core/lib/satellite.lua',
    'config.lua',
    'shared/settings.lua',
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}
