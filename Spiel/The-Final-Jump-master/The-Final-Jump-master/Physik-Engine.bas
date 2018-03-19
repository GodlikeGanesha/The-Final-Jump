#include "Global.bi"
#include "PhyVal.bi"

declare sub physic(ByVal Parameter as Any Ptr)

sub physic(ByVal Parameter as Any Ptr)
    do while guiMode = 1
        sleep simulationSpeed
    loop
end sub