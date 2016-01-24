print("doing version check")
oldversion = version
newversion=8
print("oldversion:", oldversion, " newversion:", newversion)
if (newversion ~= oldversion) then
	print("running update.lua...")
	tmr.stop(1)
	stopPoll()
	loadAndRun( "update.lua", updatepath, updateserver, updateport, 1 )
end
