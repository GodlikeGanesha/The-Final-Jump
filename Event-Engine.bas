#include "Global.bi"

declare sub event(ByVal Parameter as Any Ptr)
declare sub esc()
declare sub forne(ByVal Parameter as Any Ptr)
declare sub hinten(ByVal Parameter as Any Ptr)
declare sub hoch(ByVal Parameter as Any Ptr)

dim shared as integer forneTerm,hintenTerm,hochTerm

sub event(ByVal Parameter as Any Ptr)
    DIM evt AS FB.EVENT
    dim as String dump
    DO
      IF SCREENEVENT(@evt) THEN
        SELECT CASE evt.type
          CASE FB.EVENT_KEY_PRESS
            IF evt.scancode = FB.SC_ESCAPE THEN esc()
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
    LOOP until term
end sub 

sub esc()
    
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