###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000  000 
0000000      000     000000000  000       0000000  
     000     000     000   000  000       000  000 
0000000      000     000   000   0000000  000   000
###

{ post, elem, childp, empty, slash, fs, log, $, _ } = require 'kxk'

render = require './render'

class Stack

    constructor: ->
        
        @dir   = null
        @cp    = null
        @obj   = null
        @root  = null
        @stack = []

    goUp: -> 
        
        return if empty @stack
        
        @obj = @stack.pop()
        log 'goUp', @obj.name
        @render()
        
    goDown: (obj) ->
        
        while obj.parent and obj.parent != @obj
            obj = obj.parent
            
        if obj.parent == @obj
            log 'goDown', obj.name
            @stack.push @obj
            @obj = obj
            @render()
        
    render: -> render @obj, $ '#space'
    
    # 000       0000000    0000000   0000000        00000000  000  000      00000000  
    # 000      000   000  000   000  000   000      000       000  000      000       
    # 000      000   000  000000000  000   000      000000    000  000      0000000   
    # 000      000   000  000   000  000   000      000       000  000      000       
    # 0000000   0000000   000   000  0000000        000       000  0000000  00000000  
    
    loadFile: (file, status) ->
        
        fs.readFile file, (err, data) =>
            
            return error if err
            
            if status
                if data.length != status.size
                    log "got #{data.length} bytes of data, expected #{status.size}"
            
            @obj  = JSON.parse data
            
            @root = @obj
                    
            div = @render()
            div.classList.add 'top'
            
    #  0000000   0000000   0000000   000   000  
    # 000       000       000   000  0000  000  
    # 0000000   000       000000000  000 0 000  
    #      000  000       000   000  000  0000  
    # 0000000    0000000  000   000  000   000  
    
    scanDir: (@dir) ->    
        
        @cp?.kill()
        @cp = childp.fork slash.join(__dirname, 'scanner.js'), [@dir], stdio: ['pipe', 'pipe', 'ignore', 'ipc'], execPath: 'node'
        @cp.on 'message', @onStatus
    
    onStatus: (status) =>
            
        if status.time
            div =$ '.status'
            div.appendChild elem class:'time', text:status.time
            @loadFile status.file, status
        else
            post.emit 'tooltip', 'clear'
            space =$ '#space'
            space.innerHTML = ''
            space.appendChild elem class:'status', children: [
                elem class:'dir',   text: @dir
                elem class:'files', text: "#{status.files} files"
                elem class:'dirs',  text: "#{status.dirs} folders"
                elem class:'size',  text: status.short
            ]
            
module.exports = Stack
