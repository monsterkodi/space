###
000000000   0000000    0000000   000      000000000  000  00000000 
   000     000   000  000   000  000         000     000  000   000
   000     000   000  000   000  000         000     000  00000000 
   000     000   000  000   000  000         000     000  000      
   000      0000000    0000000   0000000     000     000  000      
###

{ post, slash, elem, pos, log, $, _ } = require 'kxk'

prettybytes = require 'pretty-bytes'

class Tooltip

    constructor: ->

        @div = elem id:'tooltip', class:'tooltip', children:[
            elem class:'name'
            elem class:'path'
            elem class:'size'
            ]
        
        main =$ "#main"
        main.appendChild @div
        
        post.on 'tooltip', (msg) => 
            switch msg 
                when 'clear' then @clear()
                when 'show'  then @show()
    
    show: -> @div.style.display = 'initial'
    hide: -> @div.style.display = 'none'
        
    clear: -> 
        
        @hide()
        $('.name',  @div).innerHTML = ''
        $('.path',  @div).innerHTML = ''
        $('.size',  @div).innerHTML = ''
    
    showObject: (obj) ->
        
        paths = []
        p = obj
        while p = p.parent
            paths.unshift p.dir ? p.name
        path = slash.tilde paths.join '/'
            
        $('.name',  @div).innerText = obj.name 
        $('.path',  @div).innerText = path
        $('.size',  @div).innerText = prettybytes obj.size
        
    position: (event) ->
        
        absPos = pos event
        
        left = absPos.x
        top  = absPos.y
        
        br = @div.getBoundingClientRect()
        
        xoff = 20
        yoff = 40
        
        if left+br.width+xoff > document.body.clientWidth 
            left = document.body.clientWidth - br.width - xoff
           
        if top+br.height+yoff > document.body.clientHeight
            top = absPos.y - br.height - yoff
        
        @div.style.left = "#{left}px"
        @div.style.top  = "#{top}px"
        
module.exports = Tooltip
