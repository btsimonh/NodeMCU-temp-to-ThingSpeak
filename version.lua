print("doing version check")
oldversion = version
newversion=6
print("oldversion:", oldversion, " newversion:", newversion)
if (newversion ~= oldversion) then
	print("running update.lua...")
	loadAndRun( "update.lua", updatepath, updateserver, updateport, 1 )
end
