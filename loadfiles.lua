--module to load multiple files from an http server to flash

files = {}
done = 1
restartwhendone = 0

function addfile( file )
	table.insert( files, file )
end

function getnextfile()
	f = files[1]
	if (f ~= nil) then
		table.remove( files, 1 )
	end
	return f
end

function listfiles()
	n = table.getn( files )
	for i = 1,n do
		print(files[i])
	end
end

function clearfiles()
	files = {}
end


function startLoad( rootpath, server, port )
local loadcon 
local state

if (files[1] == nil) then
	return
end

loadcon=net.createConnection(net.TCP, 0) 
state = 0


function sendrequest(c)
	name = getnextfile()
	if (name == nil) then
		c:close()
		return 0
	end
		
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
	return 1
end

loadcon:on("connection", function(c, payloadout)
	-- ask for first file
	sendrequest(c)
	end)

loadcon:on("sent",function(c)
	print("data sent")
	end)

loadcon:on("receive", function(c, payload) 
	foundstart = 0

	if (state == 0) then

		-- read status code, expect 'HTTP/1.1 200 OK'
		teststr = "HTTP/1.1 200"
		if payload:sub(1,teststr:len()) ~= teststr then
			print("did not get file: ", payload, " not:", "HTTP//1.1 200")
			clearfiles()
		else
			-- find first double <cr><lf><cr><lf>
    		for rest in payload:gmatch("\r\n\r\n.*") do
				file.open( name, "w+" )
				file.write( rest )
				state = 1
			end
		end
	else
		file.write( payload )
	end


	end)

loadcon:on("disconnection", function(c)
	print("Got disconnection...")
	file.close()
	state = 0
	print("Saved to file:", name)

	-- ask for next file
	if (files[1] == nil) then
		wifi.sleeptype(MODEM_SLEEP);
		loaddone = 1
		if (restartwhendone == 1) then
			node.restart()
		end
	else
		print("setting alarm")
		tmr.alarm(2, 500, 0, function() startLoad( rootpath, server, port ) end)
		print("set alarm")
	end

	end)

loadcon:connect(port,server) 
loaddone = 0

end
