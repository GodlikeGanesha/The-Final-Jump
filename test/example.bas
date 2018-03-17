#include "ploadlib.bas" 'die ploadlib.bas wird in unser Programm eingebunden.

Screen 18, 32       'erstellt ein Grafikfenster
Dim As Any Ptr img  'Pointer (Zeiger) auf das Image definieren

'die Pload - Funktion benötigt nur den Dateinamen
img = Pload( "test.png" )

If img <> 0 Then    'wurde dem Pointer eine Adresse mitgegeben?
  Put( 0, 0 ), img  'ja, dann das Bild anzeigen
  Imagedestroy img  'den belegten Speicherbereich freigeben
Else
  Print "Fehler beim laden der PNG-Grafik! FehlerNr: " & Pload_GetError()
End If
Sleep

