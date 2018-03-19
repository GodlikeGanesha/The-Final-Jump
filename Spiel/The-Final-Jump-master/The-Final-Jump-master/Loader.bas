#include "Global.bi"

declare sub lvlLoad(dic as String)
declare sub resourcesLoad()

sub lvlLoad(dic as String)
    
end sub 

sub resourcesLoad()
    dim i as Integer
    for i=0 to 5
        resources(i) = IMAGECREATE(texture(i,0),texture(i,1))
        BLOAD "resources\textures\"+str(i)+".bmp",resources(i)
    next
end sub