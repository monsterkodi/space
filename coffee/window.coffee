###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, win, tooltip, open, prefs, elem, setStyle, getStyle, pos, popup, first,
  valid, empty, childp, slash, clamp, udp, str, fs, error, log, $, _ } = require 'kxk'

electron = require 'electron'

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    
scanDir = (dir) ->
    
    log 'scanDir', dir
    
#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

openDir = ->

    opts =
        title:      'Open'
        properties: ['openDirectory']

    electron.remote.dialog.showOpenDialog opts, (dirs) =>
        if dir = first dirs
            scanDir dir
    
#  0000000   0000000   00     00  0000000     0000000   
# 000       000   000  000   000  000   000  000   000  
# 000       000   000  000000000  0000000    000   000  
# 000       000   000  000 0 000  000   000  000   000  
#  0000000   0000000   000   000  0000000     0000000   

post.on 'combo', (combo, info) -> log 'combo', combo

    #  0000000   0000000   000   000  000000000  00000000  000   000  000000000  
    # 000       000   000  0000  000     000     000        000 000      000     
    # 000       000   000  000 0 000     000     0000000     00000       000     
    # 000       000   000  000  0000     000     000        000 000      000     
    #  0000000   0000000   000   000     000     00000000  000   000     000     
    
document.body.removeEventListener 'contextmenu', w.onContextMenu

document.body.addEventListener 'contextmenu', (event) ->
    
    absPos = pos event
    if not absPos?
        absPos = pos $("#main").getBoundingClientRect().left, $("#main").getBoundingClientRect().top
       
    items = _.clone window.titlebar.menuTemplate()
        
    popup.menu
        items:  items
        x:      absPos.x
        y:      absPos.y

# 00000000   0000000   000   000  000000000      0000000  000  0000000  00000000
# 000       000   000  0000  000     000        000       000     000   000
# 000000    000   000  000 0 000     000        0000000   000    000    0000000
# 000       000   000  000  0000     000             000  000   000     000
# 000        0000000   000   000     000        0000000   000  0000000  00000000

defaultFontSize = 15

getFontSize = -> prefs.get 'fontSize', defaultFontSize

setFontSize = (s) ->
        
    s = getFontSize() if not _.isFinite s
    s = clamp 4, 44, s

    prefs.set "fontSize", s
    $('#main').style.fontSize = "#{s}px"
    iconSize = clamp 4, 44, parseInt s

changeFontSize = (d) ->
    
    s = getFontSize()
    if      s >= 30 then f = 4
    else if s >= 50 then f = 10
    else if s >= 20 then f = 2
    else                 f = 1
        
    setFontSize s + f*d

resetFontSize = ->
    
    prefs.set 'fontSize', defaultFontSize
    setFontSize defaultFontSize
            
# 00     00  00000000  000   000  000   000   0000000    0000000  000000000  000   0000000   000   000  
# 000   000  000       0000  000  000   000  000   000  000          000     000  000   000  0000  000  
# 000000000  0000000   000 0 000  000   000  000000000  000          000     000  000   000  000 0 000  
# 000 0 000  000       000  0000  000   000  000   000  000          000     000  000   000  000  0000  
# 000   000  00000000  000   000   0000000   000   000   0000000     000     000   0000000   000   000  

post.on 'menuAction', (action) ->
    
    log 'menuAction', action
    switch action
        
        when 'Increase' then changeFontSize +1
        when 'Decrease' then changeFontSize -1
        when 'Reset'    then resetFontSize()
        when 'Open'     then openDir()
        