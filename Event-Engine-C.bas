#include "Global.bi"
#include "PhyVal.bi"

#include "Loader.bas"

declare sub event(ByVal Parameter as Any Ptr)

sub event(ByVal Parameter as Any Ptr)
    DIM evt AS FB.EVENT
    dim as Integer x,y,b,mx,my,id=-1,it=0
    dim as single smx,smy,dps
    dim as UByte uPressed,lPressed,rPressed
    dim as String dump
    
    do until id >= 0 or it = 16
        getjoystick(it,b)
        if b = 0 then id = it
        it += 1
    loop
    Pr += str(id)
    if it = 16 then term = 1
    
    do
        if guiMode = 0 then
            Do
                IF SCREENEVENT(@evt) THEN
                    SELECT CASE evt.type                    
                        CASE FB.EVENT_MOUSE_BUTTON_PRESS
                    
                        CASE FB.EVENT_MOUSE_BUTTON_RELEASE
                            if evt.button = FB.BUTTON_LEFT then
                                getmouse(x,y,,)
                                if x > 25 and x < 175 and y > 330 and y < 415 then guiMode = 4
                                if x > 207 and x < 385 and y > 333 and y < 443 then guiMode = 3 
                                if x > 400 and x < 575 and y > 375 and y < 550 then term = 1
                            end if
                        CASE FB.EVENT_WINDOW_CLOSE
                            term = 1
                    END SELECT
                END IF
              dump = inkey
              sleep 1
            loop until not guiMode = 0 or term
        elseif guiMode = 1 then
            do while (b and (1 shl 0))
                Getjoystick id,b
                sleep 1
            loop
            DO
              IF SCREENEVENT(@evt) THEN
                  if evt.type = FB.EVENT_KEY_PRESS then
                    IF evt.scancode = FB.SC_ESCAPE THEN 
                        phPause=1
                        guiMode = 2
                    end if
                  elseif evt.type = FB.EVENT_WINDOW_CLOSE then 
                      term = 1
                  end if
                dump = inkey
              END IF
              
              Getjoystick id,b,dps,dps,dps,dps,dps,dps,smx
              
              if (b AND (1 SHL 0)) then
                    phPause = 1
                    guiMode = 2
              elseif (b AND (1 SHL 1)) or (b AND (1 SHL 2)) then 
                    uPressed = 1
              else
                    uPressed = 0
              end if
              mx = int(smx)
              if mx > 0.5 then 
                  lPressed = 0
                  rPressed = 1
              elseif mx < -0.5 and mx > -2 then
                  rPressed = 0
                  lPressed = 1
              else
                  rPressed = 0
                  lPressed = 0
              end if
              SLEEP 1
              if lvl.Spieler.onGround = 1 then
                  if not lvl.Spieler.hhH and uPressed then lvl.Spieler.mov.Y = -jumpDis*jM
                  if rPressed = lPressed then
                      lvl.Spieler.mov.X = 0
                  elseif rPressed = 1 and lvl.Spieler.wallR = 0 then
                      lvl.Spieler.mov.X = PlayerMovement
                  elseif lPressed = 1 and lvl.Spieler.wallL = 0 then
                      lvl.Spieler.mov.X = -PlayerMovement
                  end if
              else
                  if rPressed = lPressed then
                      lvl.Spieler.mov.X = 0
                  elseif rPressed = 1 and lvl.Spieler.wallR = 0 then
                      lvl.Spieler.mov.X = aMov
                  elseif lPressed = 1 and lvl.Spieler.wallL = 0 then
                      lvl.Spieler.mov.X = -aMov
                  end if
              end if
            LOOP until not guiMode = 1 or term
            uPressed = 0
            lPressed = 0
            rPressed = 0
        elseif guiMode = 2 then
            do while (b and (1 shl 0))
                Getjoystick id,b
                sleep 1
            loop
            do
                Getjoystick id,b
                if (b and (1 shl 0)) then
                    phPause = 0
                    guiMode = 1
                elseIF SCREENEVENT(@evt) THEN
                    SELECT CASE evt.type
                        CASE FB.EVENT_KEY_PRESS
                            IF evt.scancode = FB.SC_ESCAPE THEN 
                                phPause = 0
                                guiMode = 1
                            end if
                        CASE FB.EVENT_MOUSE_BUTTON_PRESS
                    
                        CASE FB.EVENT_MOUSE_BUTTON_RELEASE
                            if evt.button = FB.BUTTON_LEFT then
                                getmouse(x,y,,)
                                if x > 304 and x < 726 and y > 102 and y < 288 then 
                                    phPause = 0
                                    guiMode = 1
                                end if
                                if x > 303 and x < 722 and y > 350 and y < 549 then 
                                    phTerm = 1
                                    guiMode = 0
                                end if
                            end if
                        CASE FB.EVENT_WINDOW_CLOSE
                            term = 1
                    END SELECT
              END IF
              dump = inkey
              sleep 1
            loop until not guiMode = 2 or term
        elseif guiMode = 3 then
            do
                IF SCREENEVENT(@evt) THEN
                    SELECT CASE evt.type
                        CASE FB.EVENT_MOUSE_BUTTON_PRESS
                            
                        CASE FB.EVENT_MOUSE_BUTTON_RELEASE
                            if evt.button = FB.BUTTON_LEFT then
                                getmouse(x,y,,)
                                if x > 303 and x < 722 and y > 350 and y < 549 then guiMode = 0
                            end if
                        CASE FB.EVENT_WINDOW_CLOSE
                            term = 1
                    END SELECT
                END IF
                sleep 1
            loop until not guiMode = 3 or term
        elseif guiMode = 4 then
            do
                IF SCREENEVENT(@evt) THEN
                    SELECT CASE evt.type
                        CASE FB.EVENT_MOUSE_BUTTON_PRESS
                    
                        CASE FB.EVENT_MOUSE_BUTTON_RELEASE
                            if evt.button = FB.BUTTON_LEFT then
                                getmouse(x,y,,)
                                if x > 0 and x < 154 and y > 560 and y < 716 then guiMode = 0
                                if x > 100 and x < 370 and y > 50 and y < 280 then 
                                    phTerm = 0
                                    phPause = 0
                                    lvlLoad("levels\lvl"+str(1)+".txt")
                                    ThreadCreate(@physic)
                                    guiMode = 1
                                end if
                                'if x > 304 and x < 726 and y > 102 and y < 288 then guiMode = 1
                            end if
                        CASE FB.EVENT_WINDOW_CLOSE
                            term = 1
                    END SELECT
                END IF
              dump = inkey
              sleep 1
            loop until not guiMode = 4 or term
        end if
    loop until term
end sub 
