#include "Defs.bas"

sub resourcesLoad()
    dim i as Integer
    for i=0 to 1
        resources(i) = IMAGECREATE(texture(i,0),texture(i,1))
        BLOAD "Resources\"+str(i)+".bmp",resources(i)
    next
end sub

sub Butt()
    
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

    
end sub