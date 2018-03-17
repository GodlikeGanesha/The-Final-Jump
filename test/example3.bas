Dim As Any Ptr StartFile       'Pointer für den Anfang des Files
Dim As Uinteger LenFile        'Variable für die Länge des Files

Asm
  .balign 16
  jmp START_OF_PROG            'springe zum Label START_OF_PROG
  
  .balign 4
  START_OF_FILE:               'ab hier beginnt die eingebundene Datei
  .incbin "./test.png"
  END_OF_FILE:                 'hier endet die eingebundene Datei
  
  .balign 16
  START_OF_PROG:
  lea ebx, START_OF_FILE       'Lade die Adresse des Label START_OF_FILE nach ebx
  mov dword Ptr [StartFile], ebx 'Speicher die Adresse im Pointer StartFile
  lea eax, END_OF_FILE         'Lade die Adresse des Label END_OF_FILE nach eax
  Sub eax, ebx                 'berechne eax - ebx = Länge des Files
  mov dword Ptr [LenFile], eax 'Speicher die Länge des Files in der Variablen LenFile
End Asm

#include "ploadlib.bas" 'die ploadlib.bas wird in unser Programm eingebunden.

Screen 18, 8        'erstellt ein Grafikfenster für 256 Farben
Color 0, 7          'Hintergrund in grau
Cls

Dim As Any Ptr img  'Pointer (Zeiger) auf das Image definieren
'die MPload - Funktion benötigt 
'einen Pointer auf den Anfang der Datei und die Dateilänge
img = MPload( StartFile, LenFile )

If img <> 0 Then    'wurde dem Pointer eine Adresse mitgegeben?
  Put( 0, 0 ), img, trans  'ja, dann das Bild anzeigen
  Locate 20,1
  Print "Breite : "; Cast( Integer Ptr, img)[4]; " Pixel"
  Print "Hoehe  : "; Cast( Integer Ptr, img)[3]; " Pixel"
  Imagedestroy img  'den belegten Speicherbereich freigeben
Else
  Print "Fehler beim laden der PNG-Grafik! FehlerNr: " & Pload_GetError()
End If

Sleep

