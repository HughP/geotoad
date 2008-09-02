# $Id$

class Filter
  include Common
  include Display
    
  @@sizes = {
    'virtual' => 0,
    'micro'   => 1,
    'small' => 2,
    'other' => 2,
    'not chosen' => 2,
    'regular' => 3,
    'large' => 4
  }
    
  def initialize(data)
    @waypointHash = data
  end
    
  def waypoints
    @waypointHash
  end
    
  def totalWaypoints
    @waypointHash.entries.length
  end
    
  def difficultyMin(num)
    debug "filtering by difficultyMin: #{num}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['difficulty'] < num
    }
  end
    
  def difficultyMax(num)
    debug "filtering by difficultyMax: #{num}"
        
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['difficulty'] > num
    }
  end
    
    
  def terrainMin(num)
    debug "filtering by terrainMin: #{num}"
        
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['terrain'] < num
    }
  end
    
  def terrainMax(num)
    debug "filtering by terrainMax: #{num}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['terrain'] > num
    }
  end
    
  def funFactorMin(num)
    debug "filtering by funFactorMin: #{num}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['funfactor'] < num
    }
  end
    
  def funFactorMax(num)
    debug "filtering by funFactorMax: #{num}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['funfactor'] > num
    }
  end

  def sizeMin(size_name)
    debug "filtering by sizeMin: #{size_name} (#{@@sizes[size_name]})"        
    @waypointHash.delete_if { |wid, values|
      debug "size check for #{wid}: #{@waypointHash[wid]['size']}"
      @@sizes[@waypointHash[wid]['size']] < @@sizes[size_name]
    }
  end
  
  def cacheType(typestr)
    typestr.gsub!('regular', 'traditional')
    typestr.gsub!('puzzle', 'unknown')
    typestr.gsub!('mystery', 'unknown')
    types = typestr.split(/[:\|]/)
    debug "filtering by types: #{types}"
    @waypointHash.delete_if { |wid, values|
      not types.include?(@waypointHash[wid]['type'])
    }
  end  

  def sizeMax(size_name)
    debug "filtering by sizeMax: #{size_name} (#{@@sizes[size_name]})"        
    @waypointHash.delete_if { |wid, values|
      debug "size check for #{wid}: #{@waypointHash[wid]['size']}"
      @@sizes[@waypointHash[wid]['size']] > @@sizes[size_name]
    }
  end
    
  def notFound
    debug "filtering by notFound"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['mdays'].to_i > -1
    }
  end
    
  def foundDateInclude(days)
    debug "filtering by foundDateInclude: #{days}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['mdays'].to_i >= days.to_i
    }
  end
    
  def foundDateExclude(days)
    debug "filtering by foundDateExclude: #{days}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['mdays'].to_i < days.to_i
    }
  end
    
  def placeDateInclude(days)
    debug "filtering by placeDateInclude: #{days}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['cdays'].to_i >= days.to_i
    }
  end
    
  def placeDateExclude(days)
    debug "filtering by placeDateExclude: #{days}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['cdays'].to_i < days.to_i
    }
  end
    
  def travelBug
    debug "filtering by travelBug"
        
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['travelbug'].to_s.length < 1
    }
  end
    
    
  def ownerExclude(nick)
    debug "filtering by ownerExclude: #{nick}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['creator'] =~ /#{nick}/i
    }
  end
    
  def ownerInclude(nick)
    debug "filtering by ownerInclude: #{nick}"
    @waypointHash.delete_if { |wid, values|
      @waypointHash[wid]['creator'] !~ /#{nick}/i
    }
  end
    
  def userExclude(nick)
    nick.downcase!
    debug "filtering by notUser: #{nick}"
        
    @waypointHash.each_key { |wid|
      if (@waypointHash[wid]['visitors'].include?(nick))
        debug " - #{nick} has visited #{@waypointHash[wid]['name']}, filtering."
        @waypointHash.delete(wid)
      end
    }
  end
    
  def userInclude(nick)
    nick.downcase!
    debug "filtering by User: #{nick}"
        
    @waypointHash.each_key { |wid|
      debug "notUser #{nick}: #{wid}"
      if (! @waypointHash[wid]['visitors'].include?(nick))
        debug " - #{nick} has not visited #{@waypointHash[wid]['name']}, filtering."
        @waypointHash.delete(wid)
      end
    }
  end
    
  def titleKeyword(string)
    debug "filtering by title keyword: #{string}"
    @waypointHash.each_key { |wid|
      # I wanted to use delete_if, but I had run into a segfault in ruby 1.6.7/8
      if (! (@waypointHash[wid]['name'] =~ /#{string}/i) )
        @waypointHash.delete(wid)
      end
    }
  end
    
    
  def descKeyword(string)
    debug "filtering by desc keyword: #{string}"
    @waypointHash.each_key { |wid|
      # I wanted to use delete_if, but I had run into a segfault in ruby 1.6.7/8
      if (! ( (@waypointHash[wid]['details'] =~ /#{string}/i) || (@waypointHash[wid]['name'] =~ /#{string}/i)) )
        @waypointHash.delete(wid)
      end
    }
  end
     
  def removeByElement(element)
    debug "filtering by removeByElement: #{element}"
        
    @waypointHash.each_key { |wid|
      if @waypointHash[wid][element]
        @waypointHash.delete(wid)
        debug " - #{wid} has #{element}, filtering."
      end
    }
  end
    
    
  # add a visitor to a cache. Used by the userlookup feeder.
  def addVisitor(wid, visitor)
    if (@waypointHash[wid])
      debug "Added visitor to #{wid}: #{visitor}"
      # I don't believe we should downcase the visitors at this stage,
      # since we really are losing data for the templates. I need to
      # modify userInclude() and userExclude() to be case insensitive
      # first.
            
      @waypointHash[wid]['visitors'] << visitor.downcase
    else
      return 0
    end
  end
end
