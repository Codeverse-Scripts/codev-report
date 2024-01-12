fx_version 'cerulean'
game 'gta5'
author 'CodeVerse'
description 'CodeV Report'
lua54 'yes'

shared_script 'config.lua'

client_scripts{
    'client/client.lua',
}

server_scripts{
    'server/utils.lua',
    'server/server.lua',
}

ui_page 'ui/index.html'

files {
    'ui/**/*.*',
    'ui/*.*',
}