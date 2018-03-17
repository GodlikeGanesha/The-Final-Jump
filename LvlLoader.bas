#include "Global.bi"

declare sub lvlLoad(dic as String)
declare function skin(dic as String) as any ptr

sub lvlLoad(dic as String)
    
end sub 

function skin(dic as String) as any ptr
    dim as any ptr char
    char = IMAGECREATE(265, 281)
    Bload dic, char
    return char 
end function 