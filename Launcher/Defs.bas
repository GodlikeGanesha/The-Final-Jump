#include "Launcherloder.bas"
#include "MainLauncher.bas"

DIM shared evt AS FB.EVENT
dim shared as Integer x, y, guiMode = 0, term = 0
dim shared as Integer texture(5,2) = {{880,520}}
Dim Shared AS ANY PTR resources(99)