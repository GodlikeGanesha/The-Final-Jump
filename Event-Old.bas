#include "Global.bi"
#include "BNames.bi"

declare sub event(ByVal Parameter as Any Ptr)
declare sub forne()
declare sub hinten()
declare sub hoch()

sub event(ByVal Parameter as Any Ptr)
    dim as String a
    do
      if multikey(SC_RIGHT) then forne()
      if multikey(SC_LEFT) then hinten()
      if multikey(SC_SPACE) then hoch()
      if multikey(SC_ESCAPE) then term = 1
      sleep 1
    loop until term = 1
end sub

sub forne()
    PosX += 10
end sub

sub hinten()
    PosX -= 10
end sub

sub hoch()
    dim as Integer i,h 
    h = 200
    
    for i=1 to h step 2
        PosY -= 2
        sleep 10
    next i
    
    for i=1 to h step 2
        PosY += 2
        sleep 10
    next i
end sub