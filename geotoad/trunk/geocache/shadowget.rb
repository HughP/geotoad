# $Id: shadowget.rb,v 1.3 2002/08/05 03:42:24 strombt Exp $

require 'digest/md5'
require 'net/http'
require 'ftools'
require 'uri'

# find out where we want our cache #############################
cacheDir = nil
# we'll make this more dynamic in the future. Lets start out badly though.
$shadowHosts = [
	# This functionality disabled by request of Geocaching.com. 
	#'http://toadstool.se/hacks/shadowfetch/get.php'
]



# Does a webget, but stores a local directory with cached results ###################
class ShadowFetch
    include Common
    include Display
    @@downloadErrors = 0


	# gets a URL, but stores it in a nice webcache
	def initialize (url)
		@url = url
		@remote = 0
        @shadowExpiry=345600	# 4 days
        @localExpiry=432000		# 4 days
        @useShadow = 1
        @maxFailures = 4
        debug "new fetch: #{url}"
        $Header = {
          'User-Agent'      => "Mozilla/5.0 (Windows; U; Windows NT 5.0; rv:1.7.3) Gecko/20040913 Firefox/0.10",
          'Accept'          => 'image/gif, image/jpeg, image/png, multipart/x-mixed-replace, */*',
          'Accept-Language' => 'en',
          'Accept-Charset'  => 'iso-8859-1, utf-8, iso-10646-ucs-2, macintosh, windows-1252, *'
        }
	end

    def useShadow=(toggle)
        @useShadow = toggle.to_i
        debug "set useShadow to #{toggle}"
    end

	# to change the URL
	def url=(url)
		@url = url
        debug "set url to #{url}"
	end

    def shadowExpiry=(expiry)
        debug "setting shadow expiry to #{expiry}"
        @shadowExpiry=expiry
    end

    def maxFailures=(maxfail)
        debug "setting max failures to #{maxfail}"
        @maxFailures=maxfail
    end


    def localExpiry=(expiry)
        debug "setting local expiry to #{expiry}"
        @localExpiry=expiry
    end

    def postVars=(vars)
        vars.each_key {|key|
            if (@postString)
                @postString = @postString + "&"
            else
                @postString = ''
            end
            @postString = @postString + key + "=" + CGI.escape(vars[key])
        }
        @postVars=vars
        debug "Set post to: #{@postString}"
    end

	# to get the data returned back to you.
	def data
		@data
	end

	def waypoints
		@waypoints
	end

	def src
		debug "src of last get was #{@@src}"
		@@src
	end

	# returns the cache filename that the URL will be stored as
	def cacheFile(url)
        if (@postVars)
	    postdata=''
            @postVars.each_key { |key|
                postdata = postdata + "#{key}=#{@postVars[key]}"
            }

	    # we used to just keep the postdata in the filename, but DOS has
            # a 255 character limit on filenames. Lets hash it instead.

	    url = url + "-P=" + Digest::MD5.hexdigest(postdata)
            debug "added post vars to url: #{url}"
        else
            debug "no post vars to add to filename"
        end

		fileParts = url.split('/')
		host = fileParts[2]


		if fileParts[3]
			dir = fileParts[3..-2].join('/')
			file = fileParts[-1]
			localfile = '/' + host + '/' + dir + '/' + file
        end
		#else
		#    puts "XX should use index.html"
	#		localfile = '/' + host + '/' + 'index.html'
	#	end
        if url =~ /\/$/
            localfile = localfile + '/index.html'
        end

		# make a friendly filename
		localfile.gsub!(/[=\?\*\%\&\$:\-\.]/, "_")
		localfile.gsub!(/_+/, "_")
		localfile = $TEMP_DIR + localfile;

		# Windows users have a max of 255 characters I believe.
		if (localfile.length > 250)
			debug "truncating #{localfile} -- too long"
			localfile = localfile.slice(0,250)
		end

		debug "cachefile: #{localfile}"
		return localfile
	end






	# gets the file
	def fetch
		@@src = nil
		time = Time.now
		localfile = cacheFile(@url)
		localparts = localfile.split(/[\\\/]/)
		localdir = localparts[0..-2].join("/")		# basename sucks in Windows.

        debug "Checking to see if #{localfile} exists"

		# expiry?
		if (File.exists?(localfile))
			age = time.to_i - File.mtime(localfile).to_i
			if (age > @localExpiry)
				debug "local cache is #{age} old, older than #{@localExpiry}"
			elsif (File.size(localfile) < 6)
				debug "local cache appears corrupt. removing.."
				File.unlink(localfile)
			else
            debug "local cache is only #{age} old (#{@localExpiry}), using local file."
                @data = fetchLocal(localfile)
                @@src='local'
				# short-circuit out of here!
				return @data
			end
		else
			debug "no local cache file found for #{localfile}"
		end

		## this assumes there was no local cache that was useable ############
		# check shadow
        if (@useShadow > 0)
            (size, mtime) = checkShadow
        else
            # anyone know what the heck this is?
            size = 5
            mtime = 3000
        end

        # if we got back a valid result of some kind.
		if (size)
			age = time.to_i - mtime
			if ((size > 128) && (age < @shadowExpiry))
            debug "shadow has cache entry #{age} old, using."
				@data = fetchShadow
                @@src='shadow'
			else
                debug "shadow gave results we don't like (s:#{size} a:#{age} e:#{@shadowExpiry})"
				#(size, mtime) = checkGoogle(url)
				#age = time.to_i - mtime
				@data = fetchRemote
                if (@data)
                    @@src='remote'
                    if (@useShadow > 0)
                        updateShadow
                    end
                else
                    size=nil
                end
			end
        end

        # normally, this is an else, but I do that evil size=nil trick above.
		if (! size)
			debug "shadow servers gave back garbarge. shadowing disabled"
			# we could not reach a local shadow server!
			@data = fetchRemote
            @@src='remote'

            if (! @data)
                debug "we must not have a net connection, uh no"
                if (File.exists?(localfile))
                    debug "using local cache instead"
                    @data = fetchLocal(localfile)
                    @@src = "local <offline>"
                    return @data
                end
                @@src=nil
                debug "ERROR: #{@url} could not be fetched, even by cache"
                return nil
            end
		end


		if (! File.exists?(localdir))
			debug "creating #{localdir}"
			File.makedirs(localdir)
		end


		debug "outputting #{localfile}"
		cache = File.new(localfile, "w")
		cache.puts @data

		debug "Returning #{@data.length} bytes worth of data"
		return @data
	end





	## the real fetch methods ########################################################

	def fetchLocal(file)
		debug "fetching local data from #{file}"
		data = IO.readlines(file).join
		debug "#{data.length} bytes retrieved from local cache"
		return data
	end


	def fetchRemote
		debug "fetching remote data from #{@url}"
        $Header['Referer'] = @url
 		data = fetchURL(@url)
	end


	def fetchURL (url)  # full http:// string!
		fileParts = url.split('/')
		host = fileParts[2]
		file = '/' + fileParts[3..-1].join('/')
		if url =~ /\/$/
            file = file + '/'
        end

		debug "Connecting to #{host} to retrieve #{file}"
		w = Net::HTTP.new(host, 80)
		resp = nil
        if (@@downloadErrors >= @maxFailures)
            debug "#{@@downloadErrors} download errors so far, no more retries will be attempted."
            disableRetry = 1
        else
            debug "Only #{@@downloadErrors} download errors so far, enabling retry."
            disableRetry = nil
        end

		begin
			if (@postVars)
	            debug "post #{host}#{file}/?#{@postString}"
				$Header['Content-Type'] =  "application/x-www-form-urlencoded";
				resp, data = w.post(file, @postString, $Header)
			else
				debug "get #{host}#{file}"
				resp, data = w.get(file, $Header)
                debug "received file. code is #{resp.code}"
			end
		rescue Net::ProtoRetriableError => detail
			head = detail.data

			if head.code == "301"
			    debug "Following redirect to #{head['location']}"
			    uri = URI.parse(head['location'])

			    host = uri.host if uri.host
			    url  = uri.path if uri.path
			    port = uri.port if uri.port

			    w.finish if w.active?
			    w = Net::HTTP.new(host,port)
			    retry
			end
		rescue SocketError, Errno::EINVAL, EOFError, TimeoutError, StandardError => detail
            @@downloadErrors = @@downloadErrors + 1

            if (disableRetry)
                # only show the first few failures..
                if @@downloadErrors < @maxFailures
                    displayWarning "Could not fetch #{url}, no more retries available. (failures=#{@@downloadErrors})"
                end
                return nil
            else
                disableRetry = 1
                displayWarning "Could not fetch #{url}, retrying in 10 seconds.. (failures=#{@@downloadErrors}, max=#{@maxFailures})"
                sleep(10)
                retry
            end
        rescue
            debug "Unknown error fetching!"
            return nil
		end

		if resp
            # ruby 1.8.0 compatibility
            if VERSION =~ /1.[789]/
                data = resp.body
            end

            # I've noticed that sometimes IIS.net gives back error messages as normal HTML documents.
            # This should handle this RFC violation. You may want to remove this if you use shadowfetch
            # outside of geotoad.
            data.each { |line|
                if line =~ /\[HttpException \(0x\w+\): (.*?)\]/
                    displayWarning "IIS.net HttpException: #{$1}"
                    return nil
                end
            }
            return data
        end
	end

	def fetchGoogle
		debug "fetching google data of #{@url}"
		data = fetchURL 'http://216.239.37.100/search?q=cache:FsU-6uPWmo4C:#{url}%&hl=en&ie=UTF-8'
		return data
	end

	def fetchShadow
		debug "fetching shadow data of #{@url}"
		parsed = CGI.escape(@url)
		data = fetchURL $shadowHosts[0] + "?c=return&p=" + parsed
	end

	def checkShadow
		parsed = CGI.escape(@url)
		size = 0
		mtime = 0

		$shadowHosts.each { |host|
			debug "checking shadow entry on #{host}"
			ret = fetchURL "#{host}?c=check&p=#{parsed}"
			if (ret)
				if (ret =~ /^(\d+) (\d+)/)
					size = $1.to_i
					mtime = $2.to_i
					debug "shadow reply: size = #{size} mtime=#{mtime}"
					return size, mtime
				else
					debug "invalid shadow reply: #{ret}"
				end
			else
				debug "#{host} unavailable, deleting from shadow list"
				$shadowHosts.delete(host)
			end
		}
		return nil
	end

	def updateShadow
		fileParts = $shadowHosts[0].split('/')
		host = fileParts[2]
		file = '/' + fileParts[3..-1].join('/')

		if (! @data)
		    debug "No data found for #{@url}, not updating shadow"
		    return nil
		end

        begin
            uploadEncoded = "c=update&p=" + CGI.escape(@url) + "&d=" + CGI.escape(@data)
        rescue
             debug "error encoding data, returning"
             return nil
        end

		##########################################
		# This needs to get merged into fetchURL!#
		##########################################

		shadow = Net::HTTP.new(host, 80)
		headers = { "Content-Type" => "application/x-www-form-urlencoded" }
		debug "Uploading cache data to shadowfetch server: #{$shadowHosts[0]}"

		begin
			resp, data = shadow.post("#{file}?", uploadEncoded, headers)
		rescue Net::ProtoRetriableError => detail
			head = detail.data

			if head.code == "301"
                newLocation = head['location']
                newLocation.sub!(/\?$/, '')
                displayInfo "> Shadowhost #{$shadowHosts[0]} has moved to #{newLocation}!"

			    # store the redirect information

			    $shadowHosts[0]=newLocation
			    uri = URI.parse(head['location'])

			    host = uri.host if uri.host
			    url  = uri.path if uri.path
			    port = uri.port if uri.port

			    shadow.finish if shadow.active?
			    shadow = Net::HTTP.new(host,port)
			    retry
			end
		rescue => detail
            displayWarning "Error trying to update the shadow at #{host}"
            $shadowHosts.delete(host)
			return nil
		end


        # ruby 1.8.0 compatibility
        if VERSION =~ /1.[789]/
                data = resp.body
        end

        data.chomp!

        if data =~ /^[SL]-(\d+)/
            displayWarning "data for #{@url} failed to upload, size issue: #{data}"
		elsif (data !~ /^OK/)
			displayWarning "data for #{@url} failed to upload, deleting shadow host: (#{data})"
			$shadowHosts.delete(host)
			return nil
		else
			debug "uploaded: #{data}"
		end
	end
end

