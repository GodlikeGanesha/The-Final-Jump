#include "Global.bi"
#include "PhyVal.bi"

declare sub physic(ByVal Parameter as Any Ptr)

sub physic(ByVal Parameter as Any Ptr)
    dim as Integer i
    dim as ubyte comp ,con
    do while guiMode = 1
        sleep simulationSpeed
        if lvl.Spieler.onGround = 0 then lvl.Spieler.ort.Y += 5
        for i=0 to lvl.sObjs-1
            comp = 0
            con = 10
            if lvl.sList(i).hb.p2.X + lvl.sList(i).ort.X >= lvl.Spieler.hb.p1.X + lvl.Spieler.ort.X then 
                comp += 1
                con -= 1
            end if
            if lvl.sList(i).hb.p1.Y + lvl.sList(i).ort.Y <= lvl.Spieler.hb.p2.Y + lvl.Spieler.ort.Y then 
                comp += 1
                con -= 2
            end if
            if lvl.sList(i).hb.p2.Y + lvl.sList(i).ort.Y <= lvl.Spieler.hb.p1.Y + lvl.Spieler.ort.Y then 
                comp += 1
                con -= 3
            end if
            if lvl.sList(i).hb.p1.X + lvl.sList(i).ort.X <= lvl.Spieler.hb.p2.X + lvl.Spieler.ort.X then 
                comp += 1
                con -= 4
            end if
            if comp = 3 then 
                if con = 3 then lvl.Spieler.onGround = 1
            else
                lvl.Spieler.onGround = 0
            end if
        next
    loop
end sub