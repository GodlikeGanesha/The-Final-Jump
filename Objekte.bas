TYPE punkt
  AS Integer X,Y
END TYPE

TYPE tpunkt EXTENDS punkt
  AS uByte valid
  AS Double mv
END TYPE

TYPE fpunkt
  AS double X,Y
END TYPE

TYPE velocity
  AS double X,Y
END TYPE

TYPE hitbox
  AS punkt p1,p2
END TYPE

TYPE sObj
  AS punkt ort
  AS hitbox hB
  As uInteger texture
END TYPE 

TYPE mObj EXTENDS sObj
  As ubyte onGround
  As ubyte wallR
  As ubyte wallL
  As ubyte hhH ' hit his Head
  AS ubyte invis
  AS fpunkt calcPos
  AS velocity mov
END TYPE

TYPE action 
    as punkt dis
    as punkt ort
end type 

TYPE Player Extends mObj
  AS ubyte nMovP
  AS ubyte nMovN
  As ubyte leben
  As ubyte death
  As punkt lastPos
END TYPE

TYPE entity Extends mObj
  AS ubyte death
  AS ubyte leben
  AS punkt start
END Type

TYPE level
  AS Player Spieler
  AS entity eList(2100)
  AS mObj mList(2100)
  AS sObj sList(2100)
  AS action win
  as ubyte won
  as Integer sHit(0 to 13+5,0 to 299)
  AS Integer entitys 
  AS Integer mObjs
  AS Integer sObjs
END TYPE 