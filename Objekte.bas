TYPE punkt
  AS Integer X,Y
END TYPE

TYPE velocity
  AS Integer X,Y
END TYPE

TYPE hitbox
  AS punkt p1,p2
END TYPE

TYPE sObj
  AS punkt ort
  AS hitbox hB
  As Any Ptr texture
END TYPE 

TYPE mObj EXTENDS sObj
  As ubyte onGround
  AS velocity mov
END TYPE

TYPE level
  AS mObj mList(2100)
  AS Integer mObjs 
  AS sObj sList(2100)
  AS Integer sObjs
END TYPE 