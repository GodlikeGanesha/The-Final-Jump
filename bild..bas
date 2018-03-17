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

#include "fbpng.bi" 'alle nötigen PNG-Routinen werden in unser Programm eingebunden.

Screen 18, 32       'erstellt ein Grafikfenster
Dim As Any Ptr img  'Pointer (Zeiger) auf das Image definieren

'die png_load_mem - Funktion benötigt 3 Angaben,
'einen Pointer auf den Anfang der Datei, die Dateilänge
'und ob das alte oder neue Imageformat benutzt wird.
img = png_load_mem( StartFile, LenFile, PNG_TARGET_FBNEW )

If img <> 0 Then    'wurde img eine Adresse mitgegeben?
  Put( 0, 0 ), img  'ja, dann das Bild anzeigen
  Deallocate( img ) 'den belegten Speicherbereich freigeben
Else
  Print "Fehler beim laden der PNG-Grafik!"
End If

Dim As Integer hoch, breit 'damit fragen wir die Grafikgröße ab
png_dimensions_mem(StartFile, breit, hoch)
If breit > 0 And hoch > 0 Then
  Print "Breite : "; breit; " Pixel"
  Print "Hoehe  : "; hoch;  " Pixel"
Else
  Print "Fehler, PNG-Datei beschaedigt oder nicht vorhanden!"
End If

Sleep