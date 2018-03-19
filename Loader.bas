#include "Global.bi"

declare sub lvlLoad(dic as String)
declare sub lvlLoadT()
declare sub resourcesLoad()

sub lvlLoadT()
    dim as sObj O
    o.ort.X = 100
    o.ort.Y = 500
    o.hb.p1.X = 0
    o.hb.p1.Y = 0
    o.hb.p2.X = 50
    o.hb.p2.Y = 50
    o.texture = 4
    lvl.sList(lvl.sObjs) = o 
    lvl.sObjs = 1
    lvl.Spieler.ort.X = 100
    lvl.Spieler.ort.Y = 100
    lvl.Spieler.hb.p1.X = 0
    lvl.Spieler.hb.p1.Y = 0
    lvl.Spieler.hb.p2.X = 50
    lvl.Spieler.hb.p2.Y = 100
end sub

sub lvlLoad(dic as String)
    dim as String Zeile
    dim as Integer tmp0,tmp1,tmp2,DNr = Freefile 
    dim as punkt coord
    OPEN dic FOR INPUT AS #DNr
      LINE INPUT #DNr, Zeile
      PRINT Zeile
    CLOSE #DNr
end sub 

sub resourcesLoad()
    dim as Integer i,ff
    for i=0 to 5
        ff = FREEFILE
        OPEN "resources\textures\"+str(i)+".bmp" FOR BINARY AS #ff
            GET #ff, 19, textureSize(i,0)
            GET #ff, 23, textureSize(i,1) 
        CLOSE #ff
        resources(i) = IMAGECREATE(textureSize(i,0),textureSize(i,1))
        BLOAD "resources\textures\"+str(i)+".bmp",resources(i)
    next
end sub