###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, win, open, prefs, elem, setStyle, getStyle, pos, popup, first,
  valid, empty, childp, slash, clamp, udp, str, fs, error, log, $, _ } = require 'kxk'

electron    = require 'electron'
render      = require './render'
Tooltip     = require './tooltip'

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    
main =$ '#main'    

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
            scanDir slash.path dir
    
#  0000000   0000000   0000000   000   000  
# 000       000       000   000  0000  000  
# 0000000   000       000000000  000 0 000  
#      000  000       000   000  000  0000  
# 0000000    0000000  000   000  000   000  

cp = null
scanDir = (dir) ->            
    log 'scanDir', dir
    if cp
        cp.kill()
    cp = childp.fork slash.join(__dirname, 'scanner.js'), [dir], stdio: ['pipe', 'pipe', 'ignore', 'ipc'], execPath: 'node'
    cp.on 'message', (msg) -> onStatus dir, msg

onStatus = (dir, status) ->
        
    if status.time
        div =$ '.status'
        div.appendChild elem class:'time', text:status.time
        render status.file, status
    else
        main.innerHTML = ''
        main.appendChild elem class:'status', children: [
            elem class:'dir',   text: dir
            elem class:'files', text: "#{status.files} files"
            elem class:'dirs',  text: "#{status.dirs} folders"
            elem class:'size',  text: status.short
        ]
    
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
        absPos = pos main.getBoundingClientRect().left, main.getBoundingClientRect().top
       
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

defaultFontSize = 44

getFontSize = -> prefs.get 'fontSize', defaultFontSize

setFontSize = (s) ->
        
    s = getFontSize() if not _.isFinite s
    s = clamp 8, 88, s

    prefs.set "fontSize", s
    main.style.fontSize = "#{s}px"

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
    
    switch action
        
        when 'Increase' then changeFontSize +1
        when 'Decrease' then changeFontSize -1
        when 'Reset'    then resetFontSize()
        when 'Open'     then openDir()

tooltip = null
active  = null
onEnter = (event) -> 

    obj = event.target.obj
    return if empty obj
    
    active?.classList.remove 'bordered'
    active = event.target
    active.classList.add 'bordered'
        
    tooltip.showObject obj
    tooltip.position event
      
onMove = (event) -> tooltip.position event
onDown = (event) -> 
    
    log 'onDown', event.target.obj.name
            
window.onload = -> 
    
    setFontSize()
    
    tooltip = new Tooltip()
    
    scanFile = slash.join __dirname, '..', 'scan.json'
    if slash.isFile scanFile
        render scanFile
        
    main.addEventListener 'mouseover', onEnter
    main.addEventListener 'mousemove', onMove
    main.addEventListener 'mousedown', onDown
        
