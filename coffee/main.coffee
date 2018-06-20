###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

{ post, args, udp, app, log } = require 'kxk'

new app
    dir:        __dirname
    pkg:        require '../package.json'
    shortcut:   'Alt+S'
    index:      'index.html'
    icon:       '../img/app.ico'
    tray:       '../img/menu.png'
    about:      '../img/about.png'
    
#  0000000   0000000   0000000   000   000  
# 000       000       000   000  0000  000  
# 0000000   000       000000000  000 0 000  
#      000  000       000   000  000  0000  
# 0000000    0000000  000   000  000   000  

Scanner = require './scanner'    
scanner = null
scanDir = (dir) ->
    
    scanner?.stop()
    scanner = new Scanner dir
    
post.on 'scanDir', scanDir

# log 'scan...'
# scanDir 'C:/Users/kodi/s/space'         