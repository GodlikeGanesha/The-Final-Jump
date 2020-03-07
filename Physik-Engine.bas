#include "Global.bi"
#include "PhyVal.bi"

declare sub physic(ByVal Parameter as Any Ptr)

sub physic(ByVal Parameter as Any Ptr)
    dim as Integer sX,sY,gX,gY,i,sOX,sOY,gOX,gOY
    dim as ubyte dif
    do until term or phTerm or lvl.Spieler.death
        do while phPause and not phTerm
            sleep 10
        loop
        sleep simulationSpeed
        if lvl.Spieler.ort.Y > 800 then 
            lvl.Spieler.leben -= 1
            if jm > 1 then 
                jM /= 1.5
                upCount -= 1
            end if
            lvl.Spieler.wallL = 0
            lvl.Spieler.wallR = 0
            lvl.Spieler.hhH = 0
            lvl.Spieler.onGround = 0
            lvl.Spieler.ort.X = lvl.Spieler.lastPos.X
            lvl.Spieler.ort.Y = lvl.Spieler.lastPos.Y
            lvl.Spieler.calcPos.X = lvl.Spieler.lastPos.X
            lvl.Spieler.calcPos.Y = lvl.Spieler.lastPos.Y
            lvl.Spieler.mov.X = 0
            lvl.Spieler.mov.Y = 0
            damage = 150
        end if
        if lvl.Spieler.leben > 100 then lvl.Spieler.leben = 0
        if lvl.Spieler.leben <= 0 then lvl.Spieler.death = 1
        
        if lvl.Spieler.onGround = 0 then 
            lvl.Spieler.mov.Y += grav
        end if
        
        if lvl.Spieler.mov.Y > maxSpeedY then lvl.Spieler.mov.Y = maxSpeedY
        if lvl.Spieler.mov.Y < minSpeedY then lvl.Spieler.mov.Y = minSpeedY
        
        'lvl.Spieler.calcPos.Y += lvl.Spieler.mov.Y
        lvl.Spieler.calcPos.X += lvl.Spieler.mov.X
        

        'Sub-Pos
        sY = int((lvl.Spieler.calcPos.Y) MOD 50)
        sX = int((lvl.Spieler.calcPos.X) MOD 50)
        
        'Grid-Pos
        gY = int(lvl.Spieler.calcPos.Y/50)
        gX = int(lvl.Spieler.calcPos.X/50)
    
        
        if sX = 0 then
            ' Rechts
            if lvl.sHit(gY,gX+1) = 1 or lvl.sHit(gY+1,gX+1) then
                lvl.Spieler.wallR = 1
            elseif not sY = 0 and lvl.sHit(gY+2,gX+1) then
                lvl.Spieler.wallR = 1
            else
                lvl.Spieler.wallR = 0
            end if
            ' Links
            if lvl.sHit(gY,gX-1) = 1 or lvl.sHit(gY+1,gX-1) then
                lvl.Spieler.wallL = 1
            elseif not sY = 0 and lvl.sHit(gY+2,gX-1) then
                lvl.Spieler.wallL = 1
            else
                lvl.Spieler.wallL = 0
            end if
        else
            if lvl.sHit(gY,gX+1) = 1 or lvl.sHit(gY+1,gX+1) then
                lvl.Spieler.wallR = 1
                lvl.Spieler.calcPos.X -= sX
            elseif not sY = 0 and lvl.sHit(gY+2,gX+1) then
                lvl.Spieler.wallR = 1
                lvl.Spieler.calcPos.X -= sX
            else
                lvl.Spieler.wallR = 0
            end if
            if lvl.sHit(gY,gX) = 1 or lvl.sHit(gY+1,gX) then
                lvl.Spieler.wallL = 1
                lvl.Spieler.calcPos.X += 50 - sX
            elseif not sY = 0 and lvl.sHit(gY+2,gX) then
                lvl.Spieler.wallL = 1
                lvl.Spieler.calcPos.X += 50 - sX
            else
                lvl.Spieler.wallL = 0
            end if
        end if
        
        
        if lvl.Spieler.wallR = 1 and lvl.Spieler.mov.X > 0  then lvl.Spieler.mov.X = 0
        if lvl.Spieler.wallL = 1 and lvl.Spieler.mov.X < 0  then lvl.Spieler.mov.X = 0
        
        lvl.Spieler.calcPos.Y += lvl.Spieler.mov.Y
        
        sY = int((lvl.Spieler.calcPos.Y) MOD 50)
        sX = int((lvl.Spieler.calcPos.X) MOD 50)
        
        'Grid-Pos
        gY = int(lvl.Spieler.calcPos.Y/50)
        gX = int(lvl.Spieler.calcPos.X/50)
        
        if sY = 0 then
            'Unten
                if lvl.sHit(gY+2,gX) = 1 then
                    lvl.Spieler.onGround = 1
                elseif not sX = 0 and lvl.sHit(gY+2,gX+1) = 1 then
                    lvl.Spieler.onGround = 1
                else
                    lvl.Spieler.onGround = 0
                end if
            'Oben
                if lvl.sHit(gY-1,gX) = 1 then
                    lvl.Spieler.hhH = 1
                elseif not sX = 0 and lvl.sHit(gY-1,gX+1) = 1 then
                    lvl.Spieler.hhH = 1
                else
                    lvl.Spieler.hhH = 0
                end if
        else 
            ' Unten
            if lvl.Spieler.mov.Y > 0 then
                if lvl.sHit(gY+2,gX) = 1 then
                    lvl.Spieler.calcPos.Y -= sY
                    lvl.Spieler.onGround = 1
                elseif not sX = 0 and lvl.sHit(gY+2,gX+1) = 1 then'-------------------------------------------
                    lvl.Spieler.calcPos.Y -= sY
                    lvl.Spieler.onGround = 1
                else
                    lvl.Spieler.onGround = 0
                end if
            else
                lvl.Spieler.onGround = 0
            end if
            
            'Oben
            if lvl.Spieler.mov.Y < 0 then
                if lvl.sHit(gY,gX) = 1 then
                    lvl.Spieler.calcPos.Y += 50-sY
                    lvl.Spieler.hhH = 1
                elseif not sX = 0 and lvl.sHit(gY,gX+1) = 1 then
                    lvl.Spieler.calcPos.Y += 50-sY
                    lvl.Spieler.hhH = 1
                else
                    lvl.Spieler.hhH = 0
                end if
            else
                lvl.Spieler.hhH = 0
            end if
        end if
        
        if lvl.Spieler.onGround and lvl.Spieler.mov.Y > 0 then 
            lvl.Spieler.mov.Y = 0
            lvl.Spieler.lastPos.X = lvl.Spieler.ort.X
            lvl.Spieler.lastPos.Y = lvl.Spieler.ort.Y
        end if
        if lvl.Spieler.hhH and lvl.Spieler.mov.Y < 0 then lvl.Spieler.mov.Y = 0
        
        lvl.Spieler.ort.Y = int(lvl.Spieler.calcPos.Y)
        lvl.Spieler.ort.X = int(lvl.Spieler.calcPos.X)
        
        if lvl.win.ort.X = gX and lvl.win.ort.Y-1 = gY then
            lvl.won = 1
        end if
        
        for i=0 to lvl.mObjs - 1
            if lvl.mList(i).invis = 0 then
                if (lvl.Spieler.ort.X < lvl.mList(i).ort.X + 50 and lvl.Spieler.ort.X + 50 > lvl.mList(i).ort.X and lvl.Spieler.ort.Y < lvl.mList(i).ort.Y + 50 and lvl.Spieler.ort.Y + 100 > lvl.mList(i).ort.Y) then
                    lvl.mList(i).invis = 1
                    jM *= 1.5
                    upCount += 1
                end if
            end if
        next 
        
        for i=0 to lvl.entitys - 1
            if lvl.eList(i).death = 0 then 
                if lvl.eList(i).onGround = 0 then lvl.eList(i).mov.Y += grav
                
                if lvl.eList(i).mov.Y > maxSpeedY then lvl.eList(i).mov.Y = maxSpeedY
                if lvl.eList(i).mov.Y < minSpeedY then lvl.eList(i).mov.Y = minSpeedY
                
                if ((lvl.Spieler.ort.X-lvl.eList(i).ort.X)^2+(lvl.Spieler.ort.Y-lvl.eList(i).ort.Y)^2)^(1/2) < 450 then
                    if lvl.Spieler.ort.X = lvl.eList(i).ort.X or lvl.eList(i).onGround = 0 or (lvl.Spieler.onGround = 0 and ((lvl.Spieler.ort.X-lvl.eList(i).ort.X)^2+(lvl.Spieler.ort.Y-lvl.eList(i).ort.Y)^2)^(1/2) < 200) then 
                        lvl.eList(i).mov.X = 0
                    elseif lvl.eList(i).ort.X > lvl.Spieler.ort.X then
                        lvl.eList(i).mov.X = -entityMovement
                    else
                        lvl.eList(i).mov.X = entityMovement
                    end if
                else
                    lvl.eList(i).mov.X = 0
                end if
                    
                lvl.eList(i).calcPos.Y += lvl.eList(i).mov.Y
                lvl.eList(i).calcPos.X += lvl.eList(i).mov.X
                
                'Sub-Pos
                sOX = int((lvl.eList(i).calcPos.X) MOD 50)
                sOY = int((lvl.eList(i).calcPos.Y) MOD 50)
                
                'Grid-Pos
                gOX = int(lvl.eList(i).calcPos.X/50)
                gOY = int(lvl.eList(i).calcPos.Y/50)
                        
                
                if sOX = 0 then
                    ' Rechts
                    if lvl.sHit(gOY,gOX+1) = 1 then
                        lvl.eList(i).wallR = 1
                    elseif not sOY = 0 and lvl.sHit(gOY+1,gOX+1) then
                        lvl.eList(i).wallR = 1
                    else
                        lvl.eList(i).wallR = 0
                    end if
                    ' Links
                    if lvl.sHit(gOY,gOX-1) = 1 then
                        lvl.eList(i).wallL = 1
                    elseif not sOY = 0 and lvl.sHit(gOY+1,gOX-1) then
                        lvl.eList(i).wallL = 1
                    else
                        lvl.eList(i).wallL = 0
                    end if
                    
                    if lvl.eList(i).onGround = 1 then
                        if lvl.sHit(gOY+1,gOX+1) = 0 then lvl.eList(i).wallR = 1
                        if lvl.sHit(gOY+1,gOX-1) = 0 then lvl.eList(i).wallL = 1
                    end if
                end if
                
                
                if lvl.eList(i).wallR = 1 and lvl.eList(i).mov.X > 0 then lvl.eList(i).mov.X = 0
                if lvl.eList(i).wallL = 1 and lvl.eList(i).mov.X < 0 then lvl.eList(i).mov.X = 0
                
                
                if sOY = 0 then
                    'Unten
                    if lvl.sHit(gOY+1,gOX) = 1 then
                        lvl.eList(i).onGround = 1
                    elseif not sOX = 0 and lvl.sHit(gOY+1,gOX+1) = 1 then
                        lvl.eList(i).onGround = 1
                    else
                        lvl.eList(i).onGround = 0
                    end if
                else
                    ' Unten
                    if lvl.sHit(gOY+1,gOX) = 1 then
                        lvl.eList(i).calcPos.Y -= sOY
                        lvl.eList(i).onGround = 1
                    elseif not sOX = 0 and lvl.sHit(gOY+1,gOX+1) = 1 then
                        lvl.eList(i).calcPos.Y -= sOY
                        lvl.eList(i).onGround = 1
                    else
                        lvl.eList(i).onGround = 0
                    end if
                end if
                
                if lvl.eList(i).onGround and lvl.eList(i).mov.Y > 0 then 
                    lvl.eList(i).mov.Y = 0
                end if
                
                lvl.eList(i).ort.X = int(lvl.eList(i).calcPos.X)
                lvl.eList(i).ort.Y = int(lvl.eList(i).calcPos.Y)
                
                if lvl.eList(i).ort.Y > 700 then 
                    lvl.eList(i).ort.X = lvl.eList(i).start.X
                    lvl.eList(i).ort.Y = lvl.eList(i).start.Y
                    lvl.eList(i).calcPos.X = lvl.eList(i).start.X
                    lvl.eList(i).calcPos.Y = lvl.eList(i).start.Y
                    lvl.eList(i).leben -= 1
                end if
                
                if (lvl.Spieler.ort.X < lvl.eList(i).ort.X + 50 and lvl.Spieler.ort.X + 50 > lvl.eList(i).ort.X and lvl.Spieler.ort.Y < lvl.eList(i).ort.Y + 50 and lvl.Spieler.ort.Y + 100 > lvl.eList(i).ort.Y) then
                    lvl.Spieler.leben -= 1
                    if jm > 1 then 
                        jM /= 1.5
                        upCount -= 1
                    end if
                    damage = 150
                    lvl.eList(i).ort.X = lvl.eList(i).start.X
                    lvl.eList(i).ort.Y = lvl.eList(i).start.Y
                    lvl.eList(i).calcPos.X = lvl.eList(i).start.X
                    lvl.eList(i).calcPos.Y = lvl.eList(i).start.Y
                    lvl.eList(i).leben -= 1
                end if
                
                if lvl.eList(i).leben = 0 or lvl.eList(i).leben > 10 then
                    lvl.eList(i).death = 1
                end if
                
            end if
        next
    loop
end sub