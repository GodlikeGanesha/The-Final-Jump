#ifndef __Global_BI__
#define __Global_BI__

#include "fbgfx.bi"
#include "Objekte.bas"
#include "Block-Definitons.bi"

#DEFINE sFact       5
Dim Shared AS ANY PTR resources(99)
Dim Shared As Integer guiMode = 0,PosX = 40,PosY = 460,PhStop = 0,term = 0
'0 hauptmenü
'1 Spiel
'2 ESC
'3 NIM
Dim Shared as level lvl

#endif