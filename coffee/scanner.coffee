###
 0000000   0000000   0000000   000   000  000   000  00000000  00000000 
000       000       000   000  0000  000  0000  000  000       000   000
0000000   000       000000000  000 0 000  000 0 000  0000000   0000000  
     000  000       000   000  000  0000  000  0000  000       000   000
0000000    0000000  000   000  000   000  000   000  00000000  000   000
###

{ post, slash, walkdir, elem, empty, valid, fs, error, log, $, _ } = require 'kxk'

profile     = require './profile'
prettybytes = require 'pretty-bytes'
prettytime  = require 'pretty-ms'
findit      = require 'findit2'

class Scanner

    constructor: (@dir) ->
        
        profile.tag 'scan'
        profile.tag 'dir'

        @dirs = {}
        
        @newDir @dir
        
        try
            @walker = findit @dir, no_recurse:false, track_inodes:false
                                
            @walker.on 'path', @onPath            
            @walker.on 'end', @onEnd               
            @walker.on 'error', (err) -> console.log 'error', err
                
        catch err
            error "Walker.start -- #{err} dir: #{dir} stack:", err.stack

    newDir: (dir) -> 
        
        info = size:0, files:0, name:slash.file dir

        if parent = @dirs[slash.dir dir]
            parent.children ?= []
            parent.children.push info
            
        @dirs[dir] = info
        
        info

    #  0000000  000000000   0000000   000000000  000   000   0000000  
    # 000          000     000   000     000     000   000  000       
    # 0000000      000     000000000     000     000   000  0000000   
    #      000     000     000   000     000     000   000       000  
    # 0000000      000     000   000     000      0000000   0000000   
    
    status: (state='...') =>
        
        info =
            files:  @dirs[@dir].files
            dirs:   Object.keys(@dirs).length
            size:   @dirs[@dir].size
            short:  prettybytes @dirs[@dir].size
                    
        @send info
        
    #  0000000   000   000        00000000    0000000   000000000  000   000  
    # 000   000  0000  000        000   000  000   000     000     000   000  
    # 000   000  000 0 000        00000000   000000000     000     000000000  
    # 000   000  000  0000        000        000   000     000     000   000  
    #  0000000   000   000        000        000   000     000     000   000  
    
    onPath: (p,stat) =>
        
        p = slash.path p
        if stat.isDirectory()
            @newDir p 
        else
            @addFile p, stat.size, slash.dir(p)
            
        if profile.delta('dir') > 300
            
            profile.tag 'dir'
            @status()
            
    #  0000000   0000000    0000000         00000000  000  000      00000000  
    # 000   000  000   000  000   000       000       000  000      000       
    # 000000000  000   000  000   000       000000    000  000      0000000   
    # 000   000  000   000  000   000       000       000  000      000       
    # 000   000  0000000    0000000         000       000  0000000  00000000  
    
    addFile: (file,size,dir) ->

        @dirs[dir]?.files += 1
        @dirs[dir]?.size  += size
        
        if not slash.samePath @dir, dir
            parent = slash.dir dir
            if valid parent
                @addFile file, size, parent

    onEnd: =>
        
        @status ''

        @dirs[@dir].dir = @dir
        
        json = JSON.stringify @dirs[@dir], null, 1
        file = slash.join process.cwd(), 'scan.json'
        
        fs.writeFile file, json, (err) =>
            if valid err
                error err 
                @send error:err.stack
            else
                time = prettytime parseInt profile.delta 'scan'
                @send file:file, time:time, size:json.length
            log.stop()
            
        @walker = null
                
    #  0000000  000000000   0000000   00000000   
    # 000          000     000   000  000   000  
    # 0000000      000     000   000  00000000   
    #      000     000     000   000  000        
    # 0000000      000      0000000   000        
    
    stop: ->
        
        @walker?.stop()
        @walker = null
        
    send: (obj) ->
            
        if _.isFunction process.send
            process.send obj
        else
            console.log JSON.stringify obj, null, 1
        
if not empty process.argv[2]
    dir = process.argv[2]
else
    dir = process.cwd()

new Scanner slash.resolve dir
    
