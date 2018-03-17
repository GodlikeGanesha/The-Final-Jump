#include "SpielDef.bi"

FreeConsole()
WINDOWTITLE "The-Lost-Cookie"

screenres 1080, 720,24
WINDOW screen (0, 0) - (1080, 720) 

Dim As Any Ptr back ,char
back = IMAGECREATE(1080, 720)
Bload "back.bmp", back

char = skin("char.bmp")

ThreadCreate(@event)
ThreadCreate(@physic)

do
        screensync
        'cls
        Put (0,0), back, trans
        Put (PosX,PosY), char, trans
loop until term

IMAGEDESTROY back
IMAGEDESTROY char

