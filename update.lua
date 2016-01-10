print("Would do software update now")
tmr.stop(0)
clearfiles()
addfile( "init.lua" )
addfile( "checkupdate.lua" )
addfile( "loadfiles.lua" )
addfile( "ds1820.lua" )
restartwhendone = 1
startLoad( "/nodemcu1/", "192.168.1.6" , 8080)


