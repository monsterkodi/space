###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

{ post, args, udp, app, log } = require 'kxk'

# electron = require 'electron'
# electron.app.commandLine.appendSwitch '--disable-background-timer-throttling'

new app
    dir:        __dirname
    pkg:        require '../package.json'
    shortcut:   'Alt+S'
    index:      'index.html'
    icon:       '../img/app.ico'
    tray:       '../img/menu.png'
    about:      '../img/about.png'
    