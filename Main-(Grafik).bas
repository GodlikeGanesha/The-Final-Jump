#include "SpielDef.bi"

FreeConsole()
WINDOWTITLE "The-Final-Jump"

screenres 1080, 720, 24,,&h40
color rgba(255,0,0,100),rgba(255,0,0,100)
WINDOW screen (0, 0) - (1080, 720) 

Dim As Any Ptr menu, back, char, escB
menu = IMAGECREATE(1080, 720)
escB = IMAGECREATE(1080, 720)
back = IMAGECREATE(1080, 720)
Bload "Menu.bmp", menu
Bload "ESC.bmp", escB
Bload "back.bmp", back

char = skin("char.bmp")

ThreadCreate(@event)
ThreadCreate(@physic)
 
do
    do until not guiMode = 0 or term
        screensync
        Put (0,0), menu, trans
    loop
    sleep 1
    do until not guiMode = 1 or term
        screensync
        Put (0,0), back, trans
        Put (PosX,PosY), char, trans
    loop
    sleep 1
    do until not guiMode = 2 or term
        screensync
        Put (0,0), escB, trans
    loop
    sleep 1
loop until term

IMAGEDESTROY back
IMAGEDESTROY char

