# smarthome
Smarthome Fritzbox in ruby

AVM API: https://avm.de/fileadmin/user_upload/Global/Service/Schnittstellen/AHA-HTTP-Interface.pdf

# INIT Session
fb = FritzBox.new('fritz.box', 'login', 'password')
session = fb.getSessionID

# Get devicelist
devices = fb.getDeviceList

# Read Data
devices.each do |device|
	puts fb.getSwitchName(device)
	puts fb.getSwitchState(device)
	puts fb.getTemperature(device)
end

