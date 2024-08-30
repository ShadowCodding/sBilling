-- Generated automaticly by RB Generator.
fx_version('cerulean')
games({ 'gta5' })

ui_page "lib/web/build/index.html"

files {
    "lib/web/build/index.html",
    "lib/web/build/**/*"
}

shared_script({
    "shared/*.lua"
});

server_scripts({
    -- LIBRAIRIE
    "@mysql-async/lib/MySQL.lua",
    -- SCRIPT
    "server/*.lua"
});

client_scripts({
    -- LIBRAIRIE
    "lib/config.lua",
    "lib/functions/*.lua",
    "lib/menu.lua",
    "lib/menuController.lua",
    "lib/utils/*.lua",
    "lib/items/*.lua",

    -- SCRIPT
    "client/*.lua"
});