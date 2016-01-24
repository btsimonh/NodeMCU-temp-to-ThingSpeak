--init.lua
version = 1
print("Setting up WIFI...")
--loading setup
dofile("identity.lua")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config(ssid,pwd)

wifi.sta.autoconnect(1)
version = 8

tmr.alarm(1, 1000, 1, function() 
	if wifi.sta.getip()== nil then 
		print("IP unavailable, Waiting...") 
	else 
		tmr.stop(1)
		print("Config done, IP is "..wifi.sta.getip())
		dofile("ds1820.lua")
		dofile("checkupdate.lua")
		dofile("loadfiles.lua")
		--start temperature readings
		startPoll( 120000 )

		tmr.alarm(1, 30000, 1, function()
			loadAndRun( updatefile, updatepath, updatehost, updateport, 0)
			end)

	end 
end)

