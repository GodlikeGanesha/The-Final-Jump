#ifndef __Global_BI__
#define __Global_BI__

#include "fbgfx.bi"
#INCLUDE "vbcompat.bi"
#INCLUDE "fbpng.bi"
#INCLUDE "multiput.bi"

#include "Objekte.bas"
#include "Block-Definitons.bi"
#include "PhyVal.bi"

#DEFINE sFact       5
Dim Shared AS FB.Image PTR resources(99)
dim shared as Integer textureSize(99,2)
Dim Shared As Integer guiMode = 0,lvlCount,upCount=0,sLvl,phPause=0,phTerm = 1,term = 0
dim shared as double jM = 1
dim shared as single sF=0.9
dim shared as Ubyte damage
DIM Shared AS String PR
'0 hauptmenü
'1 Spiel
'2 ESC
'3 Optionen
'4 Level
Dim Shared as level lvl



#endif