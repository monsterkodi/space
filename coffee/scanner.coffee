###
 0000000   0000000   0000000   000   000  000   000  00000000  00000000 
000       000       000   000  0000  000  0000  000  000       000   000
0000000   000       000000000  000 0 000  000 0 000  0000000   0000000  
     000  000       000   000  000  0000  000  0000  000       000   000
0000000    0000000  000   000  000   000  000   000  00000000  000   000
###

{ post, slash, walkdir, elem, empty, valid, fs, error, log, $, _ } = require 'kxk'

profile = require './profile'

findit = require 'findit2'

class Scanner

    constructor: (dir) ->
        
        @dir = slash.resolve dir
        
        profile.tag 'scan'
        profile.tag 'dir'

        @dirs       = {}
        @dirs[@dir] = @newDir @dir
        
        try
            @walker = findit @dir, no_recurse:false, track_inodes:false
                                
            @walker.on 'path', @onPath
            
            @walker.on 'end', => 
                log "scanned #{@dir} files:#{@dirs[@dir].files} dirs:#{Object.keys(@dirs).length} size:#{@dirs[@dir].size}"
                @status ''
                @walker = null
                
            @walker.on 'error', (err) -> console.log 'error', err
                
        catch err
            error "Walker.start -- #{err} dir: #{dir} stack:", err.stack

    newDir: (dir) -> size:0, files:0, name:slash.file(dir), parent:slash.dir(dir)

    #  0000000  000000000   0000000   000000000  000   000   0000000  
    # 000          000     000   000     000     000   000  000       
    # 0000000      000     000000000     000     000   000  0000000   
    #      000     000     000   000     000     000   000       000  
    # 0000000      000     000   000     000      0000000   0000000   
    
    status: (state='...') ->
        
        post.toWins 'status',
            dir:    @dir 
            files:  @dirs[@dir].files
            dirs:   Object.keys(@dirs).length
            size:   @dirs[@dir].size
            time:   parseInt profile.delta('scan')/1000
            state:  state
                    
    #  0000000   000   000        00000000    0000000   000000000  000   000  
    # 000   000  0000  000        000   000  000   000     000     000   000  
    # 000   000  000 0 000        00000000   000000000     000     000000000  
    # 000   000  000  0000        000        000   000     000     000   000  
    #  0000000   000   000        000        000   000     000     000   000  
    
    onPath: (p,stat) =>
        
        if stat.isDirectory()
            @dirs[p] = @newDir p 
        else
            @addFile p, stat.size, slash.dir(p)
            
        if profile.delta('dir') > 1000
            
            console.log profile.delta('dir'), parseInt profile.delta('scan')/1000
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
        
    #  0000000  000000000   0000000   00000000   
    # 000          000     000   000  000   000  
    # 0000000      000     000   000  00000000   
    #      000     000     000   000  000        
    # 0000000      000      0000000   000        
    
    stop: ->
        
        @walker?.stop()
        @walker = null
        
module.exports = Scanner
