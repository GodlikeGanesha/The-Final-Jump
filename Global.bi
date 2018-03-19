#ifndef __Global_BI__
#define __Global_BI__

#include "fbgfx.bi"
#include "Objekte.bas"
#include "Block-Definitons.bi"

#DEFINE sFact       5
Dim Shared AS FB.Image PTR resources(99)
dim shared as Integer textureSize(99,2)
Dim Shared As Integer guiMode = 0,term = 0
DIM Shared AS String PR
'0 hauptmenü
'1 Spiel
'2 ESC
'3 Optionen
'4 Level
Dim Shared as level lvl
#endif