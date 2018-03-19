'Wav-Dateien abspielen, auch als endlos Hintergrundmusik.
'Die WAV-Dateien aus dem Listing müssen nicht im gleichen Verzeichnis auf Ihrem PC liegen
'einfach mal nach die Datei "ding.wav" suchen und den Pfad anpassen.


#include once "windows.bi"
#include once "win/mmsystem.bi"
'SND_SYNC = 0 'Programmausführung wartet bis Sound abgespielt
'SND_ASYNC = 1 'Sound wird im Hintergrund abgespielt
'SND_NODEFAULT = 2 'wird die WAV nicht gefunden kein Sound abspielen (sonst default)
'SND_LOOP = 8 'Endlosschleife bis Aufruf sndPlaySound ohne SND_LOOP (besser mit SND_ASYNC aufrufen)
'declare function sndPlaySound alias "sndPlaySoundA" (byval as LPCSTR, byval as UINT) as BOOL

'Programmausführung wartet bis Sound abgespielt
Dim Pfad as String

Pfad="C:\WINDOWS\Media\"
Do: Print "+";
sndPlaySound Pfad & "ding.wav", SND_SYNC
Loop While InKey$=""
Print
'Sound wird im Hintergrund abgespielt
sndPlaySound Pfad & "ringin.wav", SND_ASYNC Or SND_LOOP
Do: Print "-"; : Sleep 120 : Loop While InKey$=""
Print
sndPlaySound Pfad & "ringout.wav", SND_ASYNC Or SND_LOOP
Do: Print "x"; : Sleep 120 : Loop While InKey$=""
Print
'Damit die Soundausgabe endet ohne SND_LOOP aufrufen
sndPlaySound " ",SND_ASYNC
Sleep