#include "Global.bi"

declare sub event(ByVal Parameter as Any Ptr)
declare sub esc()
declare sub forne(ByVal Parameter as Any Ptr)
declare sub hinten(ByVal Parameter as Any Ptr)
declare sub hoch(ByVal Parameter as Any Ptr)

dim shared as integer forneTerm,hintenTerm,hochTerm

sub event(ByVal Parameter as Any Ptr)
    DIM evt AS FB.EVENT
    dim as Integer x,y
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
                                if x > 25 and x < 175 and y > 330 and y < 415 then guiMode = 1
                                if x > 210 and x < 330 and y > 330 and y < 450 then print "lol"
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
            DO
              IF SCREENEVENT(@evt) THEN
                SELECT CASE evt.type
                  CASE FB.EVENT_KEY_PRESS
                    IF evt.scancode = FB.SC_ESCAPE THEN guiMode = 2
                    IF evt.scancode = FB.SC_RIGHT THEN 
                        forneTerm = 0
                        ThreadCreate(@forne)
                        end if
                    IF evt.scancode = FB.SC_LEFT THEN
                        hintenTerm = 0
                        ThreadCreate(@hinten)
                        end if
                    IF evt.scancode = FB.SC_SPACE THEN
                        hochTerm = 0
                        ThreadCreate(@hoch)
                        end if
                  CASE FB.EVENT_KEY_RELEASE
                    IF evt.scancode = FB.SC_RIGHT THEN 
                        forneTerm = 1
                    end if
                    IF evt.scancode = FB.SC_LEFT THEN 
                        hintenTerm = 1
                    end if
                    IF evt.scancode = FB.SC_SPACE THEN 
                        hochTerm = 1
                    end if
                  CASE FB.EVENT_WINDOW_CLOSE
                    term = 1
                END SELECT
                dump = inkey
              END IF
              SLEEP 1
            LOOP until not guiMode = 1 or term
        elseif guiMode = 2 then
            do
                IF SCREENEVENT(@evt) THEN
                    SELECT CASE evt.type
                        CASE FB.EVENT_KEY_PRESS
                            IF evt.scancode = FB.SC_ESCAPE THEN guiMode = 1
                        CASE FB.EVENT_MOUSE_BUTTON_PRESS
                    
                        CASE FB.EVENT_MOUSE_BUTTON_RELEASE
                            if evt.button = FB.BUTTON_LEFT then
                                getmouse(x,y,,)
                                if x > 400 and x < 650 and y > 150 and y < 260 then guiMode = 1
                                if x > 360 and x < 660 and y > 410 and y < 510 then guiMode = 0
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
                sleep 1
            loop until not guiMode = 3 or term
        end if
    loop until term
end sub 

sub forne(ByVal Parameter as Any Ptr)
    do until forneTerm
    PosX += 10
    sleep 1
    loop
end sub

sub hinten(ByVal Parameter as Any Ptr)
    do until hintenTerm
    PosX -= 10
    sleep 1
    loop
end sub

sub hoch(ByVal Parameter as Any Ptr)
    dim as Integer i,h 
    do until hochTerm
    h = 200
    
    for i=1 to h step 2
        PosY -= 2
        sleep 10
    next i
    
    for i=1 to h step 2
        PosY += 2
        sleep 10
    next i
    sleep 2
    loop
end sub