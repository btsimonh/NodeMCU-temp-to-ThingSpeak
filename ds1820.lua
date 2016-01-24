-- Measure temperature and post data to thingspeak.com
-- 2014 OK1CDJ
--- Temp sensor DS18B20 is connected to GPIO0
--- 2015.01.21 sza2 temperature value concatenation bug correction

pin = 3
ow.setup(pin)

counter=0
lasttemp=-999

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

function getTime()
	sntp.sync("0.uk.pool.ntp.org", 
		function(sec,usec,server)
			print('sntp sync', sec, usec, server)
		end,
		function()
			print('sntp failed!')
  		end)
end



--- Get temperature from DS18B20 
function getTemp()
	index = 0
	values = {}
	ow.reset(pin)
	ow.reset_search(pin)
	addr = ow.search(pin)

	-- to start read on ALL devices use this instead
	-- but we don't have the power available to trigger 5 at once
	--present = ow.reset(pin)
	--ow.write(pin,0xCC,1)
	--ow.write(pin,0x44,1)
	--tmr.delay(1000000)

      repeat
        tmr.wdclr()

        if (addr ~= nil) then
	  	  index = index + 1
          --print("Got Addr")

          crc = ow.crc8(string.sub(addr,1,7))
          if (crc == addr:byte(8)) then
            if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                --print(addr:byte(1,8))


				--start read on each found device separately
				-- we don't need to read quickly, and 
				-- devices are on parasitic power
				-- so we don't have the power available to trigger 5 at once
				present = ow.reset(pin)
				ow.select(pin, addr)
				ow.write(pin,0x44,1)
				tmr.delay(1000000)

                present = ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin,0xBE,1)

                data = nil
                data = string.char(ow.read(pin))
                for i = 1, 8 do
                  data = data .. string.char(ow.read(pin))
                end
                --print(data:byte(1,9))

                crc = ow.crc8(string.sub(data,1,8))
                if (crc == data:byte(9)) then
                   t = (data:byte(1) + data:byte(2) * 256)
                   --print("raw data: " .. t);
                   if (t > 32768) then
                    t = (bxor(t, 0xffff)) + 1
                    t = (-1) * t
                   end
                   t = t * 625
                   lasttemp = t
                   --print("Last temp: " .. lasttemp)
					t1 = lasttemp / 10000
					t2 = (lasttemp >= 0 and lasttemp % 10000) or (10000 - lasttemp % 10000)
					print("Temp:"..t1 .. "."..string.format("%04d", t2).." C")
					temp = t1.."."..string.format("%04d", t2)
					values[index] = temp
                else
                   print("badCRC: " .. crc)
                end                   
                tmr.wdclr()
          end
        end
      end
      addr = ow.search(pin)
      until(addr == nil)

	return values	
end

--- Get temp and send data to thingspeak.com
function sendData()
	values = getTemp()
	postData( values )
end

function postData( temps )

-- conection to thingspeak.com
print("Sending data to thingspeak.com")

conn=net.createConnection(net.TCP, 0) 
conn:on("connection", function(conn, payloadout)
	print("Posting...")
	tosend = "GET /update?key="..channelkey
	for k,v in pairs(temps) do 
		tosend = tosend.."&field"..k.."="..v 
	end
	
	tosend = tosend.." HTTP/1.1\r\n"
		.."Host: api.thingspeak.com\r\n"
		.."Accept: */*\r\n"
		.."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
		.."\r\n"
	--print( "sending.."..tosend )
	conn:send( tosend )
	end)

conn:on("sent",function(conn)
	print("sent...")
	print("version:"..version);
	--conn:close()
	end)

conn:on("receive", function(conn, payload) 
	conn:close()
	print("receive:", payload) 
	end)

conn:on("disconnection", function(conn)
	print("Got disconnection...")
	wifi.sleeptype(MODEM_SLEEP);
	end)

conn:connect(80,'api.thingspeak.com') 

end


-- send data every X ms to thing speak

function stopPoll()
	tmr.stop(0)
end

function startPoll( interval )
	tmr.alarm(0, interval, 1, function() sendData() end )
end


