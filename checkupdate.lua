function loadAndRun( name, rootpath, server, port, usefile )

-- conection to thingspeak.com
print("checking for updates for", name)

local torun = ""
local conn=net.createConnection(net.TCP, 0) 
conn:on("connection", function(c, payloadout)
	print("RequestScript...", name)
	tosend = "GET "..rootpath..name
	
	tosend = tosend.." HTTP/1.1\r\n"
		.."Host: "
		..server
		.."\r\n"
		.."Accept: */*\r\n"
		.."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
		.."\r\n"
	print( "sending.."..tosend )
	c:send( tosend )
	end)

conn:on("sent",function(c)
	print("data sent")
	--conn:close()
	end)

conn:on("receive", function(c, payload) 
	c:close()
	foundstart = 0

	--print("receive", payload)

	-- read status code, expect 'HTTP/1.1 200 OK'
	teststr = "HTTP/1.1 200"
	if payload:sub(1,teststr:len()) ~= teststr then
		print("did not get file: ", payload, " not:", "HTTP//1.1 200")
	else
		-- find first double <cr><lf><cr><lf>
    	for rest in payload:gmatch("\r\n\r\n.*") do
			if (usefile == 0) then
				torun = rest
				print("wouldRun:", rest)
			else
				file.open( name, "w+" )
				file.write( rest )
				file.close()
				print("Saved to file:", name)
			end
			--print("rest:", rest);
		end
	end

	end)

conn:on("disconnection", function(c)
	print("Got disconnection...")
	wifi.sleeptype(MODEM_SLEEP);
	if (usefile == 0) then
		f = loadstring(torun)
		if (f ~= nil) then
			f()
		else
			print("did not run")
		end
	end

	if (usefile == 1) then
		dofile(name)
	end

	if (usefile == 2) then
		print("file just saved")
	end

	end)

conn:connect(port,server) 

end
