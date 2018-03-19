#include "SpielDef.bi"

FreeConsole()
WINDOWTITLE "The-Final-Jump"

screenres 1080, 720, 32,30,&h40

ThreadCreate(@event)

resourcesLoad()
lvlLoadT()
do
    do until not guiMode = 0 or term
        screensync
        screenlock
        Put (0,0), resources(0), trans
        screenunlock
    loop
    sleep 1
    if guiMode = 1 then ThreadCreate(@physic)
    do until not guiMode = 1 or term
        screensync
        screenlock
        Put (0,0), resources(1), trans
        for i=0 to lvl.sObjs - 1
            Put (lvl.sList(i).ort.X - lvl.Spieler.ort.X + 515,lvl.sList(i).ort.Y), resources(lvl.sList(i).texture),trans
        next
        Put (515,lvl.Spieler.ort.Y), resources(3), trans
        screenunlock
    loop
    sleep 1
    do until not guiMode = 2 or term
        screensync
        screenlock
        Put (0,0), resources(2), trans
        screenunlock
    loop
    sleep 1
loop until term

