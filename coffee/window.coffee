###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, win, open, prefs, first, slash, clamp, $, _ } = require 'kxk'

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
            space.innerHTML = ''
            tooltip.hide()
            stack.scanDir slash.path dir
            
# 00000000  000   000  00000000   000       0000000   00000000   00000000  
# 000        000 000   000   000  000      000   000  000   000  000       
# 0000000     00000    00000000   000      000   000  0000000    0000000   
# 000        000 000   000        000      000   000  000   000  000       
# 00000000  000   000  000        0000000   0000000   000   000  00000000  

explore     = -> open slash.unslash slash.untilde tooltip.objPath tooltip.obj
exploreRoot = -> 
    log 'exploreRoot', slash.unslash slash.untilde tooltip.objPath stack.obj
    open slash.unslash slash.untilde tooltip.objPath stack.obj
            
#  0000000   0000000   00     00  0000000     0000000   
# 000       000   000  000   000  000   000  000   000  
# 000       000   000  000000000  0000000    000   000  
# 000       000   000  000 0 000  000   000  000   000  
#  0000000   0000000   000   000  0000000     0000000   

post.on 'combo', (combo, info) -> 

    switch combo
        when 'r'   then exploreRoot()
        when 'e'   then explore()
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
         text: ''
    ,
         text:'Explore', accel:'e'
    ,
         text:'Explore Root', accel:'r'
    ,
         text: ''
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
        
        when 'Increase'      then changeFontSize +1
        when 'Decrease'      then changeFontSize -1
        when 'Reset'         then resetFontSize()
        when 'Explore'       then explore()
        when 'Explore Root'  then exploreRoot()
        when 'Open'          then openDir()
        when 'Rescan'        then stack.scanDir tooltip.objPath stack.obj
        when 'Up'            then stack.goUp()

onMouseEnter = (event) -> tooltip.showObject event
onMouseMove  = (event) -> tooltip.position   event

# 0000000     0000000   000   000  000   000  
# 000   000  000   000  000 0 000  0000  000  
# 000   000  000   000  000000000  000 0 000  
# 000   000  000   000  000   000  000  0000  
# 0000000     0000000   00     00  000   000  

onMouseDown = (event) ->
    
    switch event.button
        when 0
            if obj = event.target.obj
                stack.goDown obj
        when 1
            post.emit 'menuAction', 'Up'
            
    onMouseEnter event
            
window.onload = -> 
    
    setFontSize()
    
    tooltip = new Tooltip()
    
    scanFile = slash.join __dirname, '..', 'scan.json'
    if slash.isFile scanFile
        stack.loadFile scanFile
        
    main.addEventListener 'mouseover', onMouseEnter
    main.addEventListener 'mousemove', onMouseMove
    main.addEventListener 'mouseup', onMouseDown
        
