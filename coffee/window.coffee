###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, win, open, prefs, elem, setStyle, getStyle, pos, popup, first,
  valid, empty, childp, slash, clamp, udp, str, fs, error, log, $, _ } = require 'kxk'

electron = require 'electron'
Tooltip  = require './tooltip'
Stack    = require './stack'

w = new win 
    dir:     __dirname
    pkg:     require '../package.json'
    menu:    '../coffee/menu.noon'
    icon:    '../img/menu@2x.png'
    context: (items) -> onContext items
    
main  =$ '#main'    
space =$ '#space'    

stack   = new Stack()
tooltip = null
active  = null

#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

openDir = ->

    opts =
        title:      'Open'
        properties: ['openDirectory']

    electron.remote.dialog.showOpenDialog opts, (dirs) ->
        if dir = first dirs
            stack.scanDir slash.path dir
    
#  0000000   0000000   00     00  0000000     0000000   
# 000       000   000  000   000  000   000  000   000  
# 000       000   000  000000000  0000000    000   000  
# 000       000   000  000 0 000  000   000  000   000  
#  0000000   0000000   000   000  0000000     0000000   

post.on 'combo', (combo, info) -> 

    switch combo
        when 'esc' then stack.goUp()
        else log 'combo', combo

#  0000000   0000000   000   000  000000000  00000000  000   000  000000000  
# 000       000   000  0000  000     000     000        000 000      000     
# 000       000   000  000 0 000     000     0000000     00000       000     
# 000       000   000  000  0000     000     000        000 000      000     
#  0000000   0000000   000   000     000     00000000  000   000     000     
    
onContext = (items) ->
    [    
         text:'Up',   accel:'esc'
    ,
         text:'Open', accel:'ctrl+o'
    ].concat items
    
post.on 'popup', (msg) -> 
    
    switch msg 
        when 'opened' then tooltip.hide()
        when 'closed' then tooltip.show()

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
        when 'Up'       then stack.goUp()

onEnter = (event) -> 

    obj = event.target.obj
    return if empty obj
    
    active?.classList.remove 'bordered'
    active = event.target
    active.classList.add 'bordered'
        
    tooltip.showObject obj
    tooltip.position event
      
onMove = (event) -> tooltip.position event

# 0000000     0000000   000   000  000   000  
# 000   000  000   000  000 0 000  0000  000  
# 000   000  000   000  000000000  000 0 000  
# 000   000  000   000  000   000  000  0000  
# 0000000     0000000   00     00  000   000  

onClick = (event) -> 
    
    if event.button == 0
        if obj = event.target.obj
            stack.goDown obj
            
window.onload = -> 
    
    setFontSize()
    
    tooltip = new Tooltip()
    
    scanFile = slash.join __dirname, '..', 'scan.json'
    if slash.isFile scanFile
        stack.loadFile scanFile
        
    main.addEventListener 'mouseover', onEnter
    main.addEventListener 'mousemove', onMove
    main.addEventListener 'click',     onClick
        
