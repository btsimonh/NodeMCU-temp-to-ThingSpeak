My NodeMCU project to read from multiple DS18b20 sensors and publish to ThingSpeak.

I'm preparing to make a controller for my electric water heating;  this project is the result of the investigations.

One of the things I wanted was 'auto update' of the LUA scripts in the NodeMCU filesystem.  I approached this by looking at observing a webserver, and periodically looking at a file 'version.lua' on the webserver.  Every 100s, I read this file and execute it.  The file checks the current version, and if the version has changed, it then launches 'update.lua' from the webserver.
This basically allows you to do whatever you need to in the update process.
However, the actual 'version.lua' is run from RAM and loaded in a single read, so must be < ~1400 bytes.  'update.lua' is read and store in flash, but still not sure if it can be bigger.

Reading files from a webserver and storing them in the NodeMCU filesystem was tricky - you have to identify the actual payload returned from the webserver (strip the headers), and then accept multiple chunks (as files are certainly bigger than the nodemcu reads in one chunk).  
To solve this, I accept received data until the 'disconnect' comes in.  At 'disconnect', I set a timer (500ms) to start the next download (I found that trying to start the next download in the disconnect did not work...).

I also wanted to enable many NodeMCU projects in my house, so the file 'identity.lua' contains the important things which could be different between different NodeMCU modules.

Issues overcome:
The current 'release' version of NodeMCU does not do 1-wire correctly - 
use the build facility to build from 'master', then it works.

Downloading files > ~1490 bytes -> multiple receives from the webserver.


Anticipated issues:
Being new to LUA, I make a lot of mistakes.  I suspect that now I have automatic uppgrade available, I will not find it really useful, as any upgrade i give it will not run correctly and prevent the upgrade!!!!


btsimonh
