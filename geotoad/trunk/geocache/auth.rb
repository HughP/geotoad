module Auth
	include Common
	include Display
	
	def login(user, password)		
		getLoginValues
		getLoginCookies(user, password)
		return @cookies
	end
	
	def getLoginValues
		@postVars = Hash.new
		
		page = ShadowFetch.new('http://www.geocaching.com/login/')
      page.localExpiry=1
      data = page.fetch

		data.each do |line| 
			case line
      		when /^\<input type=\"hidden\" name=\"(.*?)\" value=\"(.*?)\" \/\>/
          		debug "found hidden post variable: #{$1}"
          		@postVars[$1]=$2
      		when /\<form name=\"frmLogin\" method=\"post\" action=\"(.*?)\"/
          			@postURL='http://www.geocaching.com/login/' + $1
          			@postURL.gsub!('&amp;', '&')
          			debug "post URL is #{@postURL}"
			end
		end
	end
	
	def getLoginCookies(user, password)
		page = ShadowFetch.new(@postURL)
      page.localExpiry=1
		@postVars['myUsername']=user
		@postVars['myPassword']=password
		@postVars['cookie']='on'
		@postVars['Button1']='Login'
		page.postVars=@postVars
		data = page.fetch
		@cookies = page.cookies
		debug "got cookies: #{@cookies}"
	end
end
