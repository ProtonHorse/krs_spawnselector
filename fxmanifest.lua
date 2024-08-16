fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'karos7804'
name 'krs_spawnselector'
version '1.0.0'


shared_scripts {
  'shared/*.lua',
  '@ox_lib/init.lua',

}

client_scripts {
  'client/**/*',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/**/*'
}

files {
  'locales/*.json',
  'web/build/index.html',
  'web/build/**/*',
}

ox_libs { 'locale' }

ui_page 'web/build/index.html'