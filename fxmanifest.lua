fx_version 'cerulean'
game 'gta5'

author 'Benourson#9496'
description 'ESX Banker Job Upgraded'
version '1.0.0'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'client/main.lua'
}

dependencies {
    'es_extended',
    'async',
	'mysql-async'
}


