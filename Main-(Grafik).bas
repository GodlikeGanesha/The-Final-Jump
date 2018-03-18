#include "SpielDef.bi"

FreeConsole()
WINDOWTITLE "The-Final-Jump"

screenres 1080, 720, 24,,&h40
color rgba(255,0,0,100),rgba(255,0,0,100)
WINDOW screen (0, 0) - (1080, 720) 

ThreadCreate(@event)
ThreadCreate(@physic)

resourcesLoad()

do
    do until not guiMode = 0 or term
        screensync
        Put (0,0), resources(0), trans
    loop
    sleep 1
    do until not guiMode = 1 or term
        screensync
        Put (0,0), resources(1), trans
        Put (PosX,PosY), resources(3), trans
    loop
    sleep 1
    do until not guiMode = 2 or term
        screensync
        Put (0,0), resources(2), trans
    loop
    sleep 1
loop until term

