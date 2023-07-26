fx_version 'adamant'
game 'gta5'

server_script {
    '@mysql-async/lib/MySQL.lua',
} 

shared_script {
    'config.lua',
}


client_scripts {
    'src/RageUI/RMenu.lua',
    'src/RageUI/menu/RageUI.lua',
    'src/RageUI/menu/Menu.lua',
    'src/RageUI/menu/MenuController.lua',
    'src/RageUI/components/*.lua',
    'src/RageUI/menu/elements/*.lua',
    'src/RageUI/menu/items/*.lua',
    'src/RageUI/menu/panels/*.lua',
    'src/RageUI/menu/panels/*.lua',
    'src/RageUI/menu/windows/*.lua',
}

client_scripts {
    'functions.lua',
    'cl.lua',
}

server_scripts {
    'srv.lua',
    'src/RageUI/menu/newimport.lua',
}

