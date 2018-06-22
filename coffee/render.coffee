###
00000000   00000000  000   000  0000000    00000000  00000000 
000   000  000       0000  000  000   000  000       000   000
0000000    0000000   000 0 000  000   000  0000000   0000000  
000   000  000       000  0000  000   000  000       000   000
000   000  00000000  000   000  0000000    00000000  000   000
###

{ elem, clamp, empty, valid, slash, randInt, fs, error, log, $, _ } = require 'kxk'

render = (obj, div, depth=0, direction='vert') ->

    if depth == 0
        obj.scale = 1
        obj.accum = 1
        space =$ '#space' 
        space.innerHTML = ''
    
    r = 255 - clamp 0, 255, depth*16
    g = 0
    b = clamp 0, 255, depth*16
    
    if depth == 0
        r = 32
        g = 32
        b = 32
    
    r = clamp 0, 255, r + randInt(16)-8
    b = clamp 0, 255, b + randInt(16)-8
    a = 1
    
    obj.direction ?= direction
    
    objDiv = elem class:"folder #{obj.direction}", style:"flex: 0 0 #{obj.scale*100}%; background-color:rgba(#{r}, #{g}, #{b}, #{a});"
    obj.depth = depth
    objDiv.obj = obj
    
    div.appendChild objDiv
    
    return objDiv if empty obj.children
    
    return objDiv if obj.accum < 0.000005
    
    for child in obj.children
        child.parent = obj
        child.scale = child.size / obj.size
        child.accum = child.scale * obj.accum

        render child, objDiv, depth+1, if obj.direction == 'horz' then 'vert' else 'horz'
        
    objDiv
      
module.exports = render
