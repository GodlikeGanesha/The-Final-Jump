#include "fbgfx.bi"
'
'  NewImage = ImageScale(SourceImage,Scale)
'
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



#define FULLSCREEN 1
#define SCR_W 1024
#define SCR_H 768


type BALL2D
  declare constructor (radius as integer=32)
  declare sub Draw
  as single size,x,y,z
  as fb.Image ptr Img
end type

constructor BALL2D (radius as integer=32)
  if radius<2 then radius=2
  size = radius*2
  dim as uinteger col = RGB(rnd*256,rnd*256,rnd*256)
  dim as integer r=radius
  dim as single be = col and &HFF,blue =be/4:col shr=8
  dim as single ge = col and &HFF,green=ge/4:col shr=8
  dim as single re = col and &HFF,red  =re/4
  dim as single rs = red/r*3,gs=green/r*3,bs=blue/r*3
  img=ImageCreate(size,size)
  while r
    r-=1:
    Circle img,(radius,radius),r,rgb(red,green,blue),,,,F
    red+=rs:green+=gs:blue+=bs
  wend
end constructor

sub BALL2D.Draw
  ' behind the observer ?
  if z<1 then return
  dim as single ScreenX    = x*256       /z
  dim as single ScreenSize =(x+Size)*256 /z
  dim as single ScreenY    = y*256       /z
  ScreenSize-=ScreenX
  ScreenX=SCR_W/2 + ScreenX
  ScreenY=SCR_H/2 + ScreenY
  ' scale factor
  dim as single Scale = ScreenSize/Size
  ' ScreenRadius
  dim as single ScreenRadius = ScreenSize*0.5
  ScreenX-=ScreenRadius
  ScreenY-=ScreenRadius
  ' up or down scale
  put (ScreenX,ScreenY),ImageScale(img,Scale),TRANS
end sub

type BALL_CHAIN
  declare constructor(n as integer=100)
  declare sub Update(w as single)
  declare sub Draw
  as single wstep
  as integer nBalls,nSorted
  as BALL2D ptr  pBalls
  as integer ptr pSorted
end type
constructor BALL_CHAIN(n as integer)
  this.nBalls = n
  pBalls = new BALL2D[nBalls]
  pSorted = new INTEGER[nBalls]
  wstep = 1.57/nBalls
end constructor
sub BALL_CHAIN.Update(w as single)
  nSorted=0
  for i as integer=0 to nBalls-1
    pBalls[i].z = 828+sin(w)*700
    if pBalls[i].z>1 then
      pBalls[i].x = cos(w*4)*500
      pBalls[i].y = sin(w*8)*200
      pSorted[nSorted]=i
      nSorted+=1
    end if
    w+=wStep
  next

  if nSorted>1 then
    dim as integer flag=1
    while flag
      flag=0
      for i as integer=0 to nSorted-2
        if pBalls[pSorted[i]].z < pBalls[pSorted[i+1]].z then
          swap pSorted[i],pSorted[i+1]
          flag = 1
          exit for
        end if
      next
    wend
  end if
end sub
sub BALL_CHAIN.Draw
  if nSorted<1 then return
  for i as integer=0 to nSorted-1
    pBalls[pSorted[i]].Draw
  next
end sub


Screenres SCR_W,SCR_H,32,,IIF(FULLSCREEN,1,0)

dim as BALL_CHAIN Ballchain

dim as single w=-1.57

while inkey=""
  screenlock:cls
  BallChain.Draw
  screenunlock
  BallChain.Update(w)
  w=w+0.005
  sleep 10
wend
