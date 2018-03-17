#include "ploadlib.bas"

Screen 18, 8 'erstellt ein Grafikfenster für 256 Farben
Color 15, 7
Cls

Dim As Any Ptr img = Pload( "test.png" )
If img Then
  Put (1,1), img, trans
  Imagedestroy img
Else
  Print "Fehler beim laden der PNG-Grafik! FehlerNr: " & Pload_GetError()
End If
Sleep
