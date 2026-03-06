shared_script "@bt_defender/module/shared.lua"










fx_version 'cerulean'
game 'gta5'
author "SM-Team"
version "1.0.0"

-- shared_script '@es_extended/imports.lua'

client_scripts {
	'config.lua',
	'@PolyZone/client.lua',
	'@PolyZone/ComboZone.lua',
	'@PolyZone/CircleZone.lua',
	'client/*.lua',
}

server_scripts {
	'server/*.lua'
}

lua54 'yes'

exports {
    'CheckPlayerZoneStatus'
}
