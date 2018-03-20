#include "Windows.bi"
#include "Launcherloder.bas"
#include "fbgfx.bi"
#include "MainLauncher.bas"
#include "Defs.bas"

FreeConsole()
WINDOWTITLE "The Final Jump Launcher"

screenres 880, 520, 24,,&h40
color rgba(255,0,0,100),rgba(255,0,0,100)
WINDOW screen (0, 0) - (1080, 720)

resourcesLoad()

do
    
    if guiMode = 0 then
        screensync
        screenlock
        Put (0,0), resources(0), trans
        screenunlock
        Butt()
    elseif 
    elseif guiMode = 1 then
        
    end if
    
loop until term = 1

        

sleep