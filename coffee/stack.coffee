###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000  000 
0000000      000     000000000  000       0000000  
     000     000     000   000  000       000  000 
0000000      000     000   000   0000000  000   000
###

{ $, childp, elem, empty, fs, kerror, klog, os, post, slash } = require 'kxk'

render = require './render'

class Stack

    @: ->
        
        @dir   = null
        @cp    = null
        @obj   = null
        @root  = null
        @title = null
        @path  = ''
        @stack = []

    goUp: -> 
        
        return if empty @stack
        @render @stack.pop()
        
    goDown: (obj) ->
        
        while obj.parent and obj.parent != @obj
            obj = obj.parent
            
        if obj.parent == @obj
            @stack.push @obj
            @render obj
    
    objPath: (obj) ->
        
        path = [obj.dir ? obj.name]
        while obj = obj.parent
            path.unshift obj.dir ? obj.name
        slash.tilde path.join '/'
            
    render: (@obj) -> 
    
        # post.emit 'tooltip' 'clear'
        @path = @objPath @obj
        klog "Stack.render #{@path}"
        
        @title?.remove()
        @title = elem class:'stackobj' text:@path
        titlebar =$ '#titlebar'
        titlebar.insertBefore @title, $ '.minimize'
        render @obj, $ '#space'
        post.emit 'tooltip' 'show'
    
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
            
            @root = JSON.parse data
            
            @render @root
            
    #  0000000   0000000   0000000   000   000  
    # 000       000       000   000  0000  000  
    # 0000000   000       000000000  000 0 000  
    #      000  000       000   000  000  0000  
    # 0000000    0000000  000   000  000   000  
    
    scanDir: (@dir) ->
        
        @cp?.kill()
        try
            @cp = childp.fork slash.join(__dirname, 'scanner.js'), [@dir], stdio: ['pipe' 'pipe' 'ignore' 'ipc'], execPath: 'node'
        catch err
            if os.platform() != 'win32'
                @cp = childp.fork slash.join(__dirname, 'scanner.js'), [@dir], stdio: ['pipe' 'pipe' 'ignore' 'ipc'], execPath: '/usr/local/bin/node'
            else
                kerror err
        
        @cp.on 'message' @onStatus
    
    onStatus: (status) =>
            
        if status.done
            @loadFile status.file, status
        else
            post.emit 'tooltip' 'clear'
            space =$ '#space'
            space.innerHTML = ''
            space.appendChild elem class:'status' children: [
                elem class:'dir'   text: @dir
                elem class:'files' text: "#{status.files} files"
                elem class:'dirs'  text: "#{status.dirs} folders"
                elem class:'size'  text: status.short
            ]
            
module.exports = Stack
