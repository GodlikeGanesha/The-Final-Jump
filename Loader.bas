#include "Global.bi"

declare function ImageScale(s As fb.Image Ptr, Scale as single=1.0) As fb.Image Ptr
declare sub lvlLoad(dic as String)
declare sub lvlLoadIN(bKind as Integer,bTexture as Integer,X as Integer,Y as Integer)
declare sub resourcesLoad()
declare sub scanLvls()

sub lvlLoad(dic as String)
    CLEAR lvl, 0, LEN(level)
    erase(lvl.sHit)
    damage = 0
    jM = 1
    upCount = 0
    lvl.won = 0
    Dim As Integer fh, chk
    Dim As String lbuffer, tmpbuffer
    Dim as Integer countR,countC
    dim as integer t1,t2

    fh = FreeFile
    If Open (dic For Input As #fh) = 0 Then
        countR = -50
        countC = -50
       Do While Not Eof(fh)
          Line Input #fh, lbuffer
          If Len(lbuffer) > 0 Then
              countR += 50
              countC = -50 
             chk = InStr(lbuffer, ",")
             Do While chk <> 0
                tmpbuffer = Left(lbuffer, chk - 1)
                countC += 50
                if not tmpbuffer = "" then lvlLoadIN(val(Left(tmpbuffer,instr(tmpbuffer,":")-1)),val(Right(tmpbuffer,len(tmpbuffer)-instr(tmpbuffer,":"))),countC,countR)
                If chk < Len(lbuffer) Then
                   lbuffer = Mid(lbuffer, chk + 1)
                Else
                   lbuffer = ""
                End If
                chk = InStr(lbuffer, ",")
             Loop
             If Len(lbuffer) > 0 Then
                countC += 50
                lvlLoadIN(val(Left(lbuffer,instr(lbuffer,":")-1)),val(Right(lbuffer,len(lbuffer)-instr(lbuffer,":"))),countC,countR)
             End If
          End If
       Loop
       Close fh
    End If
end sub 

sub lvlLoadIN(bKind as Integer,bTexture as Integer,X as Integer,Y as Integer)
    if bKind = 0 then
        lvl.Spieler.ort.X = X
        lvl.Spieler.ort.Y = Y
        lvl.Spieler.calcPos.X = X
        lvl.Spieler.calcPos.Y = Y
        lvl.Spieler.lastPos.X = X
        lvl.Spieler.lastPos.Y = Y
        lvl.Spieler.hb.p1.X = 0
        lvl.Spieler.hb.p1.Y = 0
        lvl.Spieler.hb.p2.X = 50
        lvl.Spieler.hb.p2.Y = 100
        lvl.Spieler.mov.X = 0
        lvl.Spieler.mov.Y = 0
        lvl.Spieler.nMovP = PlayerMovement
        lvl.Spieler.nMovN = -PlayerMovement
        lvl.Spieler.leben = 3
        lvl.Spieler.death = 0
    elseif bKind = 1 then
        lvl.sList(lvl.sObjs).ort.X = X
        lvl.sList(lvl.sObjs).ort.Y = Y
        lvl.sHit(int(Y/50),int(X/50)) = 1
        lvl.sList(lvl.sObjs).hb.p1.X = 0
        lvl.sList(lvl.sObjs).hb.p1.Y = 0
        lvl.sList(lvl.sObjs).hb.p2.X = 50
        lvl.sList(lvl.sObjs).hb.p2.Y = 50
        lvl.sList(lvl.sObjs).texture = bTexture
        lvl.sObjs += 1
    elseif bKind = 2 then
        lvl.eList(lvl.entitys).ort.X = X 
        lvl.eList(lvl.entitys).ort.Y = Y
        lvl.eList(lvl.entitys).calcPos.X = X 
        lvl.eList(lvl.entitys).calcPos.Y = Y
        lvl.eList(lvl.entitys).start.X = X
        lvl.eList(lvl.entitys).start.Y = Y
        lvl.eList(lvl.entitys).hb.p1.X = 0
        lvl.eList(lvl.entitys).hb.p1.Y = 0
        lvl.eList(lvl.entitys).hb.p2.X = 50
        lvl.eList(lvl.entitys).hb.p2.Y = 50
        lvl.eList(lvl.entitys).mov.X = 0
        lvl.eList(lvl.entitys).mov.Y = 0
        lvl.eList(lvl.entitys).leben = 2
        lvl.eList(lvl.entitys).death = 0
        lvl.eList(lvl.entitys).texture = bTexture
        lvl.entitys += 1
    elseif bKind = 3 then
        lvl.mList(lvl.mObjs).ort.X = X 
        lvl.mList(lvl.mObjs).ort.Y = Y
        lvl.mList(lvl.mObjs).calcPos.X = X 
        lvl.mList(lvl.mObjs).calcPos.Y = Y
        lvl.mList(lvl.mObjs).hb.p1.X = 0
        lvl.mList(lvl.mObjs).hb.p1.Y = 0
        lvl.mList(lvl.mObjs).hb.p2.X = 50
        lvl.mList(lvl.mObjs).hb.p2.Y = 50
        lvl.mList(lvl.mObjs).mov.X = 0
        lvl.mList(lvl.mObjs).mov.Y = 0
        lvl.mList(lvl.mObjs).texture = bTexture
        lvl.mObjs += 1
    elseif bKind = 4 then
        lvl.win.ort.X = int(X/50)
        lvl.win.ort.Y = int(Y/50)
        lvl.win.dis.X = X
        lvl.win.dis.Y = Y
    end if
end sub


sub resourcesLoad()
    dim as Integer i
    for i=0 to 35
        resources(i) = png_load("resources\textures\"+str(i)+".png")
    next
end sub


sub scanLvls()
    dim as ubyte scaning = 1,lvlC = 0
    do while scaning
        if Fileexists("levels\lvl"+str(lvlC)+".txt") then
            lvlC += 1
        else
            scaning = 0
        end if
    loop
    lvlCount = lvlC
end sub 

Function ImageScale(s As fb.Image Ptr, Scale as single=1.0) As fb.Image Ptr
  static As fb.Image Ptr t=0
  If s        =0 Then Return 0
  If s->width <1 Then Return 0
  If s->height<1 Then Return 0
  scale=abs(scale)
  dim as integer w = s->width *Scale
  dim as integer h = s->height*Scale
  If w<4 Then w=4
  If h<4 Then h=4
  if t then ImageDestroy(t) : t=0
  t=ImageCreate(w,h)
  Dim As Integer xs=(s->width /t->Width ) * (1024*64)
  Dim As Integer ys=(s->height/t->height) * (1024*64)
  Dim As Integer x,y,sy
  Select Case As Const s->bpp
    Case 4
      Dim As Ulong Ptr ps=cptr(Ulong Ptr,s)+8
      Dim As Uinteger     sp=(s->pitch Shr 2)
      Dim As Ulong Ptr pt=cptr(Ulong Ptr,t)+8
      Dim As Uinteger     tp=(t->pitch Shr 2)-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ulong Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
    Case 2
      Dim As Ushort Ptr ps=cptr(Ushort Ptr,s)+16
      Dim As Uinteger   sp=(s->pitch Shr 1)
      Dim As Ushort Ptr pt=cptr(Ushort Ptr,t)+16
      Dim As Uinteger   tp=(t->pitch Shr 1)-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ushort Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
    Case 1
      Dim As Ubyte Ptr ps=cptr(Ubyte Ptr,s)+32
      Dim As Uinteger   sp=s->pitch
      Dim As Ubyte Ptr pt=cptr(Ubyte Ptr,t)+32
      Dim As Uinteger   tp=t->pitch-t->width
      For ty As Integer = 0 To t->height-1
        Dim As Ubyte Ptr src=ps+(sy Shr 16)*sp
        For tx As Integer = 0 To t->width-1
          *pt=src[x Shr 16]:pt+=1:x+=xs
        Next
        pt+=tp:sy+=ys:x=0
      Next
  End Select
  Return t
End Function