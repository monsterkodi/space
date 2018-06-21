###
00000000   00000000  000   000  0000000    00000000  00000000 
000   000  000       0000  000  000   000  000       000   000
0000000    0000000   000 0 000  000   000  0000000   0000000  
000   000  000       000  0000  000   000  000       000   000
000   000  00000000  000   000  0000000    00000000  000   000
###

{ elem, empty, valid, slash, randInt, fs, error, log, $, _ } = require 'kxk'

renderObj = (obj, div, depth=0, dir='vert') ->
    
    r = parseInt (64+randInt(128)) / (1+depth/4) 
    g = parseInt (64+randInt(128)) / (1+depth/4) 
    b = parseInt (64+randInt(128)) / (1+depth/4)
    a = 0.8
    
    objDiv = elem class:"folder #{dir}", style:"flex: 0 0 #{obj.scale*100}%; background-color:rgba(#{r}, #{g}, #{b}, #{a});"
    obj.depth = depth
    objDiv.obj = obj
    
    div.appendChild objDiv
    
    return objDiv if empty obj.children
    
    for child in obj.children
        child.parent = obj
        child.scale = child.size / obj.size
        renderObj child, objDiv, depth+1, if dir == 'vert' then 'horz' else 'vert'
        
    objDiv

render = (file, status) ->

    fs.readFile file, (err, data) ->
        
        return error if err
        
        if status
            if data.length != status.size
                log "got #{data.length} bytes of data, expected #{status.size}"
        
        obj = JSON.parse data
        obj.scale = 1
        
        main =$ '#main' 
        main.innerHTML = ''
        
        div = renderObj obj, main
        div.classList.add 'top'
        
module.exports = render
