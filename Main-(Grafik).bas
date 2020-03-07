#include "SpielDef.bi"

FreeConsole()
WINDOWTITLE "The-Final-Jump"

screenres 1080, 1720, 32,2,FB.GFX_ALPHA_PRIMITIVES

ThreadCreate(@event)

scanLvls()
resourcesLoad()

do
    do until not guiMode = 0 or term
        'screensync
        sleep 33
        screenlock
        Put (0,0), resources(0), ALPHA
        screenunlock
    loop
    
    '---------------------------
    sleep 1
    do until not guiMode = 1 or term
        'screensync
        sleep 10
        counter += 1
        screenlock
        Put (0,0), resources(1), ALPHA
        for i=0 to lvl.sObjs - 1
            Put (lvl.sList(i).ort.X - lvl.Spieler.ort.X + 515,lvl.sList(i).ort.Y), resources(lvl.sList(i).texture),ALPHA
        next
        for i=0 to lvl.mObjs - 1
            if lvl.mList(i).invis = 0 then Put (lvl.mList(i).ort.X - lvl.Spieler.ort.X + 515,lvl.mList(i).ort.Y), resources(lvl.mList(i).texture),ALPHA
        next
        for i=0 to lvl.entitys - 1
            if lvl.eList(i).death = 0 then Put (lvl.eList(i).ort.X - lvl.Spieler.ort.X + 515,lvl.eList(i).ort.Y), resources(lvl.eList(i).texture),ALPHA
        next
        
        
        for i=1 to lvl.Spieler.leben 
            Put ((i-1)*50,0), resources(11), ALPHA
        next
        
        for i=1 to upCount
            Put ((i-1)*50,60), resources(29), ALPHA
        next
        
        Put (lvl.win.dis.X - lvl.Spieler.ort.X + 515,lvl.win.dis.Y), resources(30),ALPHA
        
        if lvl.Spieler.mov.X = 0 then
            Put (515,lvl.Spieler.ort.Y), resources(13 + (int(counter/12) mod 4) ), ALPHA 
        elseif lvl.Spieler.mov.X > 0 then
            Put (515,lvl.Spieler.ort.Y), resources(17 + (int(counter/6) mod 6) ), ALPHA 
        else
            Put (515,lvl.Spieler.ort.Y), resources(23 + (int(counter/6) mod 6) ), ALPHA 
        end if
        'LINE (515,lvl.Spieler.ort.Y)-(565, lvl.Spieler.ort.Y+100), rgb(255,0,0), B 
        if damage > 0 then
            screenunlock
            color ,rgba(255,0,0,damage)
            cls
            damage -= 1
            screenlock
        end if
        'print Pr
        if lvl.won = 1 then
            phTerm = 1
            sleep 10
            screenunlock 
            put (0,0), resources(31), Alpha
            put (515,lvl.Spieler.ort.Y), resources(13),Alpha
            Put (lvl.win.dis.X - lvl.Spieler.ort.X + 515,lvl.win.dis.Y), resources(30),ALPHA
            for i=0 to 10
                sleep 500
                screenlock
                if i < 4 then 
                    Put (0,0), resources(1), ALPHA
                    for k=0 to lvl.sObjs - 1
                        Put (lvl.sList(k).ort.X - lvl.Spieler.ort.X + 515,lvl.sList(k).ort.Y), resources(lvl.sList(k).texture),ALPHA
                    next
                    put (0,0), resources(31), Alpha
                    put (515,lvl.Spieler.ort.Y-50), resources(32+i),Alpha
                end if
                screenunlock
            next
            sleep 500
            guiMode = 0
        elseif lvl.Spieler.death = 1 then
            screenunlock
            color ,rgba(100,0,0,1)
            put (0,0), resources(12), ALPHA
            for i=0 to 200
                sleep 10
                cls
            next
            phTerm = 1
            guiMode = 4
        end if
        screenunlock
    loop
    '-----------------------------
    
    sleep 1
    do until not guiMode = 2 or term
        'screensync
        sleep 33
        screenlock
        Put (0,0), resources(2), ALPHA
        screenunlock
    loop
    sleep 1
    do until not guiMode = 3 or term
        'screensync
        sleep 33
        screenlock
        Put (0,0), resources(6), ALPHA
        screenunlock
    loop
    sleep 1
    do until not guiMode = 4 or term
        'screensync
        sleep 33
        screenlock
        Put (0,0), resources(lvlCount+7), ALPHA
        screenunlock
    loop
    sleep 1
loop until term
