#include "Global.bi"
#include "PhyVal.bi"

#include "Loader.bas"

declare sub event(ByVal Parameter as Any Ptr)

sub event(ByVal Parameter as Any Ptr)
    DIM evt AS FB.EVENT
    dim as Integer x,y
    dim as UByte uPressed,lPressed,rPressed
    dim as String dump
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
            if multikey(FB.SC_RIGHT) then rPressed = 1
            if multikey(FB.SC_LEFT) then lPressed = 1
            if multikey(FB.SC_SPACE) then uPressed = 1
            DO
              IF SCREENEVENT(@evt) THEN
                SELECT CASE evt.type
                  CASE FB.EVENT_KEY_PRESS
                    IF evt.scancode = FB.SC_ESCAPE THEN 
                        phPause=1
                        guiMode = 2
                    end if
                    IF evt.scancode = FB.SC_RIGHT THEN rPressed = 1
                    IF evt.scancode = FB.SC_LEFT THEN lPressed = 1 
                    IF evt.scancode = FB.SC_SPACE THEN uPressed = 1
                  CASE FB.EVENT_KEY_RELEASE
                    IF evt.scancode = FB.SC_RIGHT THEN rPressed = 0
                    IF evt.scancode = FB.SC_LEFT THEN lPressed = 0
                    IF evt.scancode = FB.SC_SPACE THEN uPressed = 0
                  CASE FB.EVENT_WINDOW_CLOSE
                    term = 1
                END SELECT
                dump = inkey
              END IF
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
            do
                IF SCREENEVENT(@evt) THEN
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
