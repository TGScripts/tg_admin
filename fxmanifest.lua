fx_version 'cerulean'
games { 'gta5' }

author 'Tiger (Discord: lets_tiger)'
description 'Admin Script'
version '1.3.0'

lua54 'yes'

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'server/version_check.lua'
}

shared_script {
	'config.lua',
	'locales.lua',
	'locales/*.lua'
}

dependencies {
	'es_extended'
}