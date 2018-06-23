###
000000000   0000000    0000000   000      000000000  000  00000000 
   000     000   000  000   000  000         000     000  000   000
   000     000   000  000   000  000         000     000  00000000 
   000     000   000  000   000  000         000     000  000      
   000      0000000    0000000   0000000     000     000  000      
###

{ post, slash, empty, elem, pos, log, $, _ } = require 'kxk'

prettybytes = require 'pretty-bytes'

class Tooltip

    constructor: ->

        @div = elem id:'tooltip', children:[
            elem class:'names', children: [
                    elem class:'name base'
                ,
                    elem class:'name active'
                ]
            elem class:'path'
            elem class:'sizes', children: [
                    elem class:'size base'
                ,
                    elem class:'size active'
                ]
            ]
        
        main =$ "#main"

        @base = elem id:'base', class:'rect'
        main.appendChild @base
        
        @rect = elem id:'active', class:'rect'
        main.appendChild @rect
        
        main.appendChild @div
        
        post.on 'tooltip', (msg) => 
            switch msg 
                when 'clear' then @clear()
                when 'show'  then @show()
    
    show: -> 
        @div.style.display = 'initial'
        @rect.style.display = 'initial'
        @base.style.display = 'initial'
        
    hide: -> 
        @div.style.display = 'none'
        @rect.style.display = 'none'
        @base.style.display = 'none'
        
    clear: -> 
        
        @hide()
        $('.base.name',     @div).innerHTML = ''
        $('.active.name',   @div).innerHTML = ''
        $('.path',          @div).innerHTML = ''
        $('.base.size',     @div).innerHTML = ''
        $('.active.size',   @div).innerHTML = ''
        
        @rect.style.width = '0'
        @base.style.width = '0'
    
    objPath: (obj) ->
        
        path = [obj.dir ? obj.name]
        while obj = obj.parent
            path.unshift obj.dir ? obj.name
        slash.tilde path.join '/'
        
    showObject: (event) ->
        
        x = event.clientX 
        y = event.clientY
        
        target = document.elementFromPoint x, y
        
        obj = target.obj
        return if empty obj
        
        br = target.getBoundingClientRect()

        space =$ '#space'
        sr = space.getBoundingClientRect()
        
        @rect.style.left   = "#{br.x-sr.x}px"
        @rect.style.top    = "#{br.y-sr.y}px"
        @rect.style.width  = "#{br.width}px"
        @rect.style.height = "#{br.height}px"
        
        base = target
        while base.parentNode != space and base.parentNode.parentNode != space
            base = base.parentNode
            
        br = base.getBoundingClientRect()
        @base.style.left   = "#{br.x-sr.x}px"
        @base.style.top    = "#{br.y-sr.y}px"
        @base.style.width  = "#{br.width}px"
        @base.style.height = "#{br.height}px"
        
        $('.base.name',     @div).innerText = base.obj.name
        $('.active.name',   @div).innerText = obj.name
        $('.path',          @div).innerText = @objPath obj
        $('.base.size',     @div).innerText = prettybytes base.obj.size
        $('.active.size',   @div).innerText = prettybytes obj.size
        
        @position event
        
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
