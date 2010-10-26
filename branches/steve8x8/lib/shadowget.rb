# $Id$

require 'digest/md5'
require 'net/http'
require 'fileutils'
require 'uri'
require 'cgi'
require 'common'
require 'messages'

# Does a webget, but stores a local directory with cached results ###################
class ShadowFetch
  attr_reader :data, :waypoints, :cookie
  attr_accessor :url

  include Common
  include Messages
  @@downloadErrors = 0

  # gets a URL, but stores it in a nice webcache
  def initialize (url)
    @url = url
    @remote = 0
    @localExpiry=518400    		# 6 days
    @maxFailures = 2
    @httpHeaders = {
      'User-Agent'      => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-US) AppleWebKit/532.9 (KHTML, like Gecko) Chrome/5.0.307.11 Safari/532.9",
      'Accept'          => 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
      'Accept-Language' => 'en-us,en;q=0.5',
      'Accept-Charset'  => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
    }
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
      debug "SET #{key}: #{vars[key]}"
      if (@postString)
        @postString = @postString + "&"
      else
        @postString = ''
      end
      @postString = @postString + key + "=" + CGI.escape(vars[key])
    }
    @postVars=vars
    debug "Set POST string to: #{@postString}"
  end

  def src
    debug "src of last get was #{@@src}"
    @@src
  end

  def cookie=(cookie)
    debug "set cookie to #{cookie}"
    @cookie=cookie
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
    end

    fileParts = url.split('/')
    host = fileParts[2]


    if fileParts[3]
      dir = fileParts[3..-2].join('/')
      file = fileParts[-1]
      localfile = '/' + host + '/' + dir + '/' + file
    end

    if url =~ /\/$/
      localfile = localfile + '/index.html'
    end

    # make a friendly filename
    localfile.gsub!(/[=\?\*\%\&\$:\-\.]/, "_")
    localfile.gsub!(/_+/, "_")
    if $CACHE_DIR
      localfile = $CACHE_DIR + localfile;
    else
      localfile = '/tmp' + localfile
    end
    # Windows users have a max of 255 characters I believe.
    if (localfile.length > 250)
      debug "truncating #{localfile} -- too long"
      localfile = localfile.slice(0,250)
    end

    debug "cachefile: #{localfile}"
    return localfile
  end

  def invalidate
    filename = cacheFile(@url)
    if File.exist?(filename)
      displayInfo "Invalidating cache at #{filename}"
      begin
        File.unlink(filename)
      rescue Errno::EACCES => e
        displayWarning "Could not delete #{filename}: #{e} - attempting truncation."
        f = File.truncate(filename, 0)
      end
    end
  end


  # gets the file
  def fetch
    @@src = nil
    time = Time.now
    localfile = cacheFile(@url)
    localparts = localfile.split(/[\\\/]/)
    localdir = localparts[0..-2].join("/")  # basename sucks in Windows.
    debug "====+ Fetch URL: #{url}"
    debug "====+ Fetch File: #{localfile}"

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


    @data = fetchRemote
    size = nil
    if (@data)
      @@src='remote'
      size = @data.length
    else
      debug "we must not have a net connection, uh no"
      if (File.exists?(localfile))
        debug "using local cache instead"
        @data = fetchLocal(localfile)
        @@src = "local <offline>"
        return @data
      else
        @@src=nil
        debug "ERROR: #{@url} could not be fetched, even by cache"
        return nil
      end
    end

    if (! File.exists?(localdir))
      debug "creating #{localdir}"
      FileUtils::mkdir_p(localdir)
    end


    debug "outputting #{localfile}"
    cache = File.open(localfile, File::WRONLY|File::TRUNC|File::CREAT, 0666)
    cache.puts @data
    cache.close
    debug "Returning #{@data.length} bytes: #{@data[0..512]}"
    return @data
  end


  ## the real fetch methods ########################################################

  def fetchLocal(file)
    begin
      data = IO.readlines(file).join
    rescue Errno::EACCES => e
      displayWarning "Could not read #{file}: #{e}"
      invalidate()
      return nil
    end
    debug "#{data.length} bytes retrieved from local cache"
    return data
  end


  def fetchRemote
    debug "fetching remote data from #{@url}"
    @httpHeaders['Referer'] = @url
    data = fetchURL(@url)
  end

  def fetchURL (url_str, redirects=2)  # full http:// string!
    raise ArgumentError, 'HTTP redirect too deep' if redirects == 0
    debug "Fetching [#{url_str}]"
    uri = URI.parse(url_str)

    if @@downloadErrors == @maxFailures
      sleep(10)
      debug "#{@@downloadErrors} download errors so far, no more retries will be attempted."
    elsif @@downloadErrors > @maxFailures
      displayInfo "Offline mode: not fetching #{url_str}"
      return nil
    elsif @@downloadErrors > 0 && @@downloadErrors < @maxFailures
      debug "Only #{@@downloadErrors} download errors so far, will try until #{@maxFailures}"
      sleep(5)
    end

    if ENV['HTTP_PROXY']
      proxy = URI.parse(ENV['HTTP_PROXY'])
      proxy_user, proxy_pass = uri.userinfo.split(/:/) if uri.userinfo
      debug "Using proxy from environment: " + ENV['HTTP_PROXY']
      http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy_user, proxy_pass).new(uri.host, 80)
    else
      debug "No proxy found in environment, using standard HTTP connection."
      http = Net::HTTP.new(uri.host, 80)
    end

    if uri.query
      query=uri.path + "?" + uri.query
    else
      query=uri.path
    end

    if @cookie
      debug "Added Cookie to #{url_str}: #{@cookie}"
      @httpHeaders['Cookie']=@cookie
    else
      debug "No cookie to add to #{url_str}"
    end

    begin
      if (@postVars)
        @httpHeaders['Content-Type'] =  "application/x-www-form-urlencoded";
        debug "POST to #{query}, headers are #{@httpHeaders.keys.join(" ")}"
        resp = http.post(query, @postString, @httpHeaders)
      else
        debug "GET to #{query}, headers are #{@httpHeaders.keys.join(" ")}"
        resp = http.get(query, @httpHeaders)
      end
    rescue Timeout::Error => e
      @@downloadErrors = @@downloadErrors + 1
      displayWarning "Timed out trying to access #{uri.host}:80 (try #{@@downloadErrors})"

      return fetchURL(url_str, redirects)

    rescue Errno::ECONNREFUSED => e
      @@downloadErrors = @@downloadErrors + 1
      displayWarning "Connection refused accessing #{uri.host}:80 (try #{@@downloadErrors})"
      return fetchURL(url_str, redirects)

    rescue => e
      @@downloadErrors = @@downloadErrors + 1
      displayWarning "Unable to connect to #{uri.host}:80: #{e} (try #{@@downloadErrors})"
      return fetchURL(url_str, redirects)
    end

    case resp
    when Net::HTTPSuccess
      debug "#{url_str} successfully downloaded."

    when Net::HTTPRedirection
      location = resp['location']
      debug "REDIRECT: [#{location}]"
      # relative redirects are against RFC, but we may encounter them.
      if location =~ /^\//
        if uri.port == 80
          location = "#{uri.scheme}://#{uri.host}#{location}"
        else
          location = "#{uri.scheme}:#{uri.port}//#{uri.host}#{location}"
        end
      end
      return fetchURL(location, redirects - 1)
    else
      @@downloadErrors = @@downloadErrors + 1
      debug "unknown response downloading #{url_str} (try #{@@downloadErrors})"
      return fetchURL(url_str, redirects)
    end


    if resp.response && resp.response['set-cookie']
      @cookie = resp.response['set-cookie']
      debug "receieved cookie: #{@cookie}"
    end

    return resp.body
  end
end
