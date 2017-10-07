# ruby class for fritzbox home
# by Michael Plaschke

class FritzBoxError < StandardError
   attr_reader :object

  def initialize(object)
    @object = object
  end
end

class FritzBox
	require 'open-uri'
	require 'xmlsimple'
	require 'digest/md5'

	def initialize(host, user, password)
    	@host = host
    	@user = user
    	@password = password
  	end

	def getResponse(challenge, password)
	  before = challenge + "-" + password
	  ary = []
	  before.size.times { ary << 0 }
	  after = before.bytes.zip(ary).flatten!
	  unicode = after.pack('U*')
	  md5string = Digest::MD5.hexdigest(unicode)
	  return "#{challenge}-#{md5string}"
	end

  	# get a session id from fritzbox
	def getSessionID()
	  uri="http://#{@host}/login_sid.lua"
	  xml = open(uri)
	  data = XmlSimple.xml_in(xml)
	  sessionID = data["SID"][0]
	  if sessionID.eql?("0000000000000000")
	    challenge = data["Challenge"][0]
	     response = getResponse(challenge,@password)
	    uri = "http://#{@host}/login_sid.lua?username=#{@user}&response=#{response}"
	    xml = open(uri)
	    data = XmlSimple.xml_in(xml)
	    sessionID = data["SID"][0]
	    @sessionID = sessionID
	    return sessionID
	  else
  	   	raise FritzBoxError.new("FritzBoxLogin"), "login failed"
	    return sessionID
	  end
	end

	def getDeviceInfo(device)
		if @sessionID.eql?("0000000000000000") or @sessionID.nil?
			raise FritzBoxError.new("FritzBoxLogin"), "no session"
		else
	  		xml = open("http://#{@host}/webservices/homeautoswitch.lua?ain=#{device}&switchcmd=getdevicelistinfos&sid=#{@sessionID}")
	  		data = XmlSimple.xml_in(xml)
	  		fbdev = FritzBoxDevice.new(data)
	  		return fbdev
	  	end 
	end

	def getSwitchName(device)
		if @sessionID.eql?("0000000000000000") or @sessionID.nil?
			raise FritzBoxError.new("FritzBoxLogin"), "no session"
		else
	  		xml = open("http://#{@host}/webservices/homeautoswitch.lua?ain=#{device}&switchcmd=getswitchname&sid=#{@sessionID}")
	  		return xml.readlines
	  	end 
	end

	def getSwitchState(device)
		if @sessionID.eql?("0000000000000000") or @sessionID.nil?
			raise FritzBoxError.new("FritzBoxLogin"), "no session"
		else
	  		xml = open("http://#{@host}/webservices/homeautoswitch.lua?ain=#{device}&switchcmd=getswitchstate&sid=#{@sessionID}")
	  		return xml.readlines
	  	end
	end

	def getTemperature(device)
		if @sessionID.eql?("0000000000000000") or @sessionID.nil?
			raise FritzBoxError.new("FritzBoxLogin"), "no session"
		else
	  		xml = open("http://#{@host}/webservices/homeautoswitch.lua?ain=#{device}&switchcmd=gettemperature&sid=#{@sessionID}")
	  		return (xml.readlines[0].to_f/10)
	  	end
	end

	def getDeviceList()
		if @sessionID.eql?("0000000000000000") or @sessionID.nil?
			raise FritzBoxError.new("FritzBoxLogin"), "no session"
		else
			xml = open("http://#{@host}/webservices/homeautoswitch.lua?switchcmd=getswitchlist&sid=#{@sessionID}")
			return xml.readlines[0].split(',')
		end
	end
end






