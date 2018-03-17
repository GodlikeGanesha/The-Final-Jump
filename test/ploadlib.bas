/' ploadlib - PNG image loader for use in FreeBASIC programs.
 ' Copyright (C) 2006 Matt Netsch (thrawn411@hotmail.net), 
 '                    Matthew Fearnley (counting.pine@virgin.net)
 '
 ' This library is free software; you can redistribute it and/or
 ' modify it under the terms of the GNU Lesser General Public
 ' License as published by the Free Software Foundation; either
 ' version 2.1 of the License, or (at your option) any later version.
 '
 ' This library is distributed in the hope that it will be useful,
 ' but WITHOUT ANY WARRANTY; without even the implied warranty of
 ' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 ' Lesser General Public License for more details.
 '
 ' You should have received a copy of the GNU Lesser General Public
 ' License along with this library; if not, write to the Free Software
 ' Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 '/

'Option Explicit
#Include once "zlib.bi"
#Include once "crt.bi"
#Include "idatfuncs.bas"

#Define __ploadlib_a__
#Include "ploadlib.bi"

#Define UpdatePalette (-1)
#Define PrintStats (0)
#Define OnErrorRoutine (0)

Type Chunk_Type
    Length_Field As Integer
    Type_Field As String * 4
End Type

Type tRNS_Type
    YY As UShort
    RR As UShort
    GG As UShort
    BB As UShort
End Type

Type Header_Type
    IWidth As UInteger
    IHeight As UInteger
    IBitDepth As UByte
    IColorType As UByte
    ICompression As UByte
    IFilter As UByte
    IInterlace As UByte
    Bypp As UInteger
    Has_PLTE As Integer
    Has_gAMA As Integer
    Has_tRNS As Integer
    tRNS As tRNS_Type
    gAMA As Double
End Type

Type Pal_Type
    RR As UByte
    GG As UByte
    BB As UByte
    AA As UByte
End Type

'|--Interface Functions (Used by the PNG Loader Algo)--|
Declare Function VSig(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
Declare Function CRCC(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
Declare Function VCOC() As Integer      'Valid Chunk Ordering Check: Checks PNG File to see if Chunks are in correct order
Declare Function UnCompressIDAT() As Integer 'Uncompresses IDAT
Declare Function LoadIHDR(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
Declare Function Pout() As Any Ptr      'Puts the Image array to the screen

'|--Support Functions (Used by the Interface Functions)--|
Declare Sub Make_gAMA_Table()
Declare Sub Add_Chunk (Chunk As Chunk_Type)
Declare Function IsRecognizedChunk (Chunk As Chunk_Type) As Integer
Declare Function IsCriticalChunk (Chunk As Chunk_Type) As Integer
Declare Function Make_PLTE(ByVal p As UByte Ptr, ByVal Length As UInteger) As Integer
Declare Function Make_tRNS(ByVal p As UByte Ptr, ByVal Length As UInteger) As Integer

Dim Shared As Chunk_Type Chunk_Ordering()       'Chunk Order
Dim Shared As Header_Type Header                'Info Header
Dim Shared As Pal_Type Pal(0 To 255)                    'Palette
Dim Shared As UByte gAMA_Correction(0 To 65535) 'gAMA Correction
Dim Shared As UByte IDAT()                      'IDAT Stream
Dim Shared As UByte RawScanLine()               'Raw ScanLines after all DeCompression/DeFiltering (w/filters wasted)
Dim Shared As Integer IDAT_Index = -1           'Index of IDAT
Dim Shared As Integer ChunkOrdering_First = -1  'Flag for first time of Chunk.Add() Method

Static Shared As PLOAD_ERR PloadError              'Pload Error Code

'=======================================================================
Public Function Pload_GetError() As PLOAD_ERR
    
    Return PloadError
    
End Function

Public Function MPload(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Any Ptr
    #If OnErrorRoutine
      On Error Goto ErrorHandler
    #EndIf
    
    PloadError = PLOAD_NOERROR
    
    Dim As Any Ptr Result
    
    With Header                                                      'Info Header
        .IWidth = 0
        .IHeight = 0
        .IBitDepth = 0
        .IColorType = 0
        .ICompression = 0
        .IFilter = 0
        .IInterlace = 0
        .Bypp = 0
        .Has_PLTE = 0
        .Has_gAMA = 0
        .Has_tRNS = 0
    End With
    
    Erase Pal
    ReDim IDAT(0) As UByte                                           'IDAT Stream
    IDAT_Index = -1                                                  'Index of IDAT
    ReDim ScanLine(0) As UByte                                       'ScanLines of postuncompression, preunfiltered Image Data (w/Filters added)
    ReDim RawScanLine(0) As UByte                                    'Raw ScanLines after all DeCompression/DeFiltering (w/filters wasted)
    ReDim RawScanLinePLTE(0) As UByte                                'ScanLine for the PLTEs
    ChunkOrdering_First = -1                                         'Flag for first time of Chunk.Add() Method
    Dim IntErr As Integer
    
    
    #If PrintStats
        Print "|--PNG 8 byte Signature Check--|"
    #EndIf
    
    If VSig(PNGData, PNGLen) = 0 Then
        #If PrintStats
            Print "Failed...Not A PNG File"
        #EndIf
        PloadError = PLOAD_INVALIDSIG
        Return 0
    End If
    
    #If PrintStats
        Print "Passed": Print: Print "|--Loading Info Header (IHDR Chunk)--|"
    #EndIf
    
    If LoadIHDR(PNGData, PNGLen) = 0 Then
        #If PrintStats
            Print "IHDR Failed: Header is Unsupported or Corrupt"
        #EndIf
        PloadError = PLOAD_INVALIDHEADER
        Return 0
    End If
    
    #If PrintStats
        Print "Passed": Print: Print "|--CRC Check--|"
    #EndIf
    
    If CRCC(PNGData, PNGLen) = 0 Then
        #If PrintStats
            Print "CRC Failed: File Corrupted"
        #EndIf
        PloadError = PLOAD_FILECORRUPTED
        Return 0
    End If
    
    #If PrintStats
        Print "Passed": Print: Print "|--Valid Chunk Ordering Check--|"
    #EndIf
    
    If VCOC = 0 Then
        #If PrintStats
            Print "VCOC Failed: Chunks Not Valid Or In Improper Order"
        #EndIf
        PloadError = PLOAD_INVALIDCHUNKS
        Return 0
    End If
    
    If Header.Has_gAMA Then Make_gAMA_Table
    
    #If PrintStats
        Print: Print "Passed": Print: Print "|--Uncompressing IDAT Chunks--|"
    #EndIf
    
    IntErr = UnCompressIDAT
    If IntErr Then
        #If PrintStats
            Print "UnCompressing IDAT Failed: ZLIB Error: " & IntErr
        #EndIf
        PloadError = PLOAD_INVALID_IDATSTREAM
        Return 0
    End If
    
    #If PrintStats
        Print "Done"
        Print
        Print "|--Writing Image To Buffer--|"
    #EndIf
    
    Result = Pout()
    Erase RawScanLine
    
    If Result = 0 Then
        #If PrintStats
            Print "Rendering failed"
        #EndIf
        PloadError = PLOAD_RENDERINGFAILED
        Return 0
    End If
    
    Return Result
    
    #If OnErrorRoutine
    ErrorHandler:
        PloadError = PLOAD_MISCERROR
        Return 0
    #EndIf
    
End Function

'=======================================================================
Public Function Pload(Byval SourceFile As String) As Any Ptr
    
    Dim As Integer FileNum
    Dim PNGData As UByte Ptr, PNGLen As UInteger
    Dim As Any Ptr Result
    
    FileNum = FreeFile
    
    PloadError = PLOAD_NOERROR
    
    If Open (SourceFile For Binary Access Read As #FileNum) Then PloadError = PLOAD_FILEOPENED_FAILED: Return 0
        
        PNGLen = LOF(FileNum)
        If PNGLen = 0 Then PloadError = PLOAD_MISCERROR: Return 0
        PNGData = Allocate(PNGLen)
        If PNGData = 0 Then PloadError = PLOAD_MISCERROR: Return 0
        
        If Get (#FileNum, 1, PNGData[0], PNGLen) Then
            PloadError = PLOAD_MISCERROR
            Close #FileNum
            Return 0
        End If
        
    Close #FileNum
    
    Result = MPLoad(PNGData, PNGLen)
    
    Deallocate(PNGData)
    
    Return Result
    
End Function

'=======================================================================
Private Function LoadIHDR(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
    
    '|--Load The Info Header--|
    
    Dim As UByte Ptr p
    Dim As Integer Bpp
    Dim As UInteger ChunkLength
    
    If PNGLen < 8 + 8 + 13 Then Return 0
    
    p = PNGData + 8
    
    ChunkLength = p[0] Shl 24 Or p[1] Shl 16 Or p[2] Shl 8 Or p[3]
    
    If ChunkLength <> 13 Then Return 0
    If memcmp(p + 4, @"IHDR", 4) Then Return 0
    
    p += 8
    
    With Header
        
        .IWidth = p[0] Shl 24 Or p[1] Shl 16 Or p[2] Shl 8 Or p[3]
        .IHeight = p[4] Shl 24 Or p[5] Shl 16 Or p[6] Shl 8 Or p[7]
        .IColorType = p[9]
        .ICompression = p[10]
        .IFilter = p[11]
        .IInterlace = p[12]
        
        #If PrintStats
            Print "IWidth: " & .IWidth
            Print "IHeight: " & .IHeight
            Print "IBit Depth: " & .IBitDepth
            Print "IColor Type: " & .IColorType
            Print "ICompression: " & .ICompression
            Print "IFilter: " & .IFilter
            Print "IInterlace: " & .IInterlace
        #EndIf
        
        If .IWidth <= 0 Or .IWidth > &H7FFFFFFF Then Return 0
        
        If .IHeight <= 0 Or .IHeight > &H7FFFFFFF Then Return 0
        
        
        .IBitDepth = p[8]
        
        If .IBitDepth <> 1 And .IBitDepth <> 2 And .IBitDepth <> 4 And .IBitDepth <> 8 And .IBitDepth <> 16 Then Return 0
        
        
        Select Case As Const .IColorType
            Case 0          'Supports 1,2,4,8,16
            Case 3          'Supports 1, 2, 4, 8
                If Header.IBitDepth = 16 Then Return 0
            Case 2, 4, 6    'Supports 8, 16
                If Header.IBitDepth <> 8 And Header.IBitDepth <> 16 Then Return 0
            Case Else
                Return 0
        End Select
        
        Select Case As Const .IColorType
            Case 0, 3
                Bpp = .IBitDepth
            Case 2
                Bpp = .IBitDepth * 3
            Case 4
                Bpp = .IBitDepth * 2
            Case 6
                Bpp = .IBitDepth * 4
        End Select
        
        .Bypp = (Bpp + 7) \ 8
        
        If .ICompression <> 0 Then Return 0
        
        If .IFilter <> 0  Then Return 0
        
        If .IInterlace > 1 Then Return 0
        
    End With
    
    Return -1
    
End Function

Private Function VSig(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
    
    '|--Signature Validation--|
    If PNGLen < 8 Then Return 0
    Const PNGHeader As String = Chr(&H89) & "PNG" & Chr(&H0D, &H0A, &H1A, &H0A)
    
    If memcmp(PNGData, @PNGHeader, 8) Then Return 0
    
    Return -1
    
End Function

Private Function CRCC(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Integer
    
    '|--Checks all the data chunks for corruption--|
    If PNGData = 0 Then Return 0
    
    Dim pMax as UByte Ptr = PNGData + PNGLen - 1
    
    Dim p as UByte Ptr = PNGData + 8
    
    Dim ChunkLength As UInteger
    Dim As UInteger CRC_Result, CRC_File
    Dim gAMA as UInteger
    Dim As String * 4 ChunkType
    Dim As Chunk_Type Chunk
    Dim As UInteger IDAT_Length = 0
    
    '|--Cycle Through All Chunks--|
    Do
        
        If p + 3 > pMax Then Return 0
        
        '|--Length Field--|
        ChunkLength = p[0] Shl 24 Or p[1] Shl 16 Or p[2] Shl 8 Or p[3]
        p += 4
        If p + ChunkLength + 7 > pMax Then Return 0
        
        '|--Type Field--|
        ChunkType = Chr(p[0], p[1], p[2], p[3])
        
        Chunk.Length_Field = ChunkLength
        Chunk.Type_Field = ChunkType
        
        Add_Chunk Chunk
        
        Select Case ChunkType
            Case "IDAT"
                If ChunkLength > 0 Then
                    ReDim Preserve IDAT(0 To IDAT_Length + ChunkLength - 1)
                    memcpy (@IDAT(IDAT_Length), p + 4, ChunkLength)
                    IDAT_Length += ChunkLength
                End If
            Case "PLTE"
                If Make_PLTE(p + 4, ChunkLength) = 0 Then Return 0
            Case "tRNS"
                If Make_tRNS(p + 4, ChunkLength) = 0 Then Return 0
            Case "gAMA"
                gAMA= p[4] Shl 24 Or p[5] Shl 16 Or p[6] Shl 8 Or p[7]
                Header.gAMA = gAMA / 100000
        End Select
        
        '|--Chunk CRC--|
        CRC_Result = crc32 (0, p, ChunkLength + 4)
        
        p += ChunkLength + 4
        CRC_File = p[0] Shl 24 Or p[1] Shl 16 Or p[2] Shl 8 Or p[3]
        p += 4
        
        If CRC_Result <> CRC_File Then Return 0
        
    Loop Until ChunkType = "IEND"
    
    Return -1
    
End Function

Private Function VCOC() As Integer
    
    '|--Check Chunk Ordering and Validization--|
    
    Dim i As UInteger
    Dim As Integer Did_PLTE = 0, Did_IDAT = 0, IDAT_Stop = 0
    Dim As Integer Did_cHRM = 0, Did_gAMA = 0, Did_sBIT = 0, Did_bKGD = 0, Did_hIST = 0, Did_tRNS = 0, Did_pHYs = 0, Did_tIME = 0
    
    If Chunk_Ordering(LBound(Chunk_Ordering)).Type_Field <> "IHDR" Then Return 0
    If Chunk_Ordering(Ubound(Chunk_Ordering)).Type_Field <> "IEND" Then Return 0
    
    For i = LBound(Chunk_Ordering) + 1 To UBound(Chunk_Ordering) - 1
        #If PrintStats
            Print i & ": " & Chunk_Ordering(i).Type_Field & ": Critical?: " & *iif(IsCriticalChunk(Chunk_Ordering(i)), @"True", @"False")
        #EndIf
        If Chunk_Ordering(i).Type_Field = "IHDR" Or Chunk_Ordering(i).Type_Field = "IEND" Then Return 0
        
        If Did_PLTE = 0 Then               'If PLTE Has not been reached Then
            If Chunk_Ordering(i).Type_Field = "PLTE" Then
                Did_PLTE = -1
                If Did_bKGD Then Return 0
                If Did_hIST Then Return 0
                If Did_tRNS Then Return 0
            End If
        Else                              'If PLTE Has Happened
            If Chunk_Ordering(i).Type_Field = "PLTE" Then Return 0
            If Chunk_Ordering(i).Type_Field = "cHRM" Then Return 0
            If Chunk_Ordering(i).Type_Field = "gAMA" Then Return 0
            If Chunk_Ordering(i).Type_Field = "sBIT" Then Return 0
        End If
        
        If Did_IDAT = 0 Then               'If IDAT Has not been reached Then
            If Chunk_Ordering(i).Type_Field = "IDAT" Then Did_IDAT = -1
            
        Else                              'If IDAT Has been reached Then
            If Chunk_Ordering(i).Type_Field <> "IDAT" Then IDAT_Stop = -1
            If IDAT_Stop = -1 Then If Chunk_Ordering(i).Type_Field = "IDAT" Then Return 0
            If Chunk_Ordering(i).Type_Field = "PLTE" Then Return 0
            If Chunk_Ordering(i).Type_Field = "cHRM" Then Return 0
            If Chunk_Ordering(i).Type_Field = "gAMA" Then Return 0
            If Chunk_Ordering(i).Type_Field = "sBIT" Then Return 0
            If Chunk_Ordering(i).Type_Field = "bKGD" Then Return 0
            If Chunk_Ordering(i).Type_Field = "hIST" Then Return 0
            If Chunk_Ordering(i).Type_Field = "tRNS" Then Return 0
            If Chunk_Ordering(i).Type_Field = "pHYs" Then Return 0
        End If
        
        If Did_cHRM = 0 Then
            If Chunk_Ordering(i).Type_Field = "cHRM" Then Did_cHRM = -1
        Else
            If Chunk_Ordering(i).Type_Field = "cHRM" Then Return 0
        End If
        
        If Did_gAMA = 0 Then
            If Chunk_Ordering(i).Type_Field = "gAMA" Then Did_gAMA = -1
        Else
            If Chunk_Ordering(i).Type_Field = "gAMA" Then Return 0
        End If
        
        If Did_sBIT = 0 Then
            If Chunk_Ordering(i).Type_Field = "sBIT" Then Did_sBIT = -1
        Else
            If Chunk_Ordering(i).Type_Field = "sBIT" Then Return 0
        End If
        
        If Did_bKGD = 0 Then
            If Chunk_Ordering(i).Type_Field = "bKGD" Then Did_bKGD = -1
        Else
            If Chunk_Ordering(i).Type_Field = "bKGD" Then Return 0
        End If
        
        If Did_hIST = 0 Then
            If Chunk_Ordering(i).Type_Field = "hIST" Then Did_hIST = -1
        Else
            If Chunk_Ordering(i).Type_Field = "hIST" Then Return 0
        End If
        
        If Did_tRNS = 0 Then
            If Chunk_Ordering(i).Type_Field = "tRNS" Then Did_tRNS = -1
        Else
            If Chunk_Ordering(i).Type_Field = "tRNS" Then Return 0
        End If
        
        If Did_pHYs = 0 Then
            If Chunk_Ordering(i).Type_Field = "pHYs" Then Did_pHYs = -1
        Else
            If Chunk_Ordering(i).Type_Field = "pHYs" Then Return 0
        End If
        
        If Did_tIME = 0 Then
            If Chunk_Ordering(i).Type_Field = "tIME" Then Did_tIME = -1
        Else
            If Chunk_Ordering(i).Type_Field = "tIME" Then Return 0
        End If
    Next i
    
    If Did_IDAT = 0 Then Return 0
    
    Header.Has_PLTE = Did_PLTE
    Header.Has_gAMA = Did_gAMA
    Header.Has_tRNS = Did_tRNS
    
    If (Header.IColorType = 3) And (Header.Has_PLTE = 0) Then Return 0
    
    Return -1
    
End Function

Private Sub Add_Chunk (Chunk As Chunk_Type)
    
    Dim As Integer i, _UBound
    
    If ChunkOrdering_First Then
        _UBound = 0
        ReDim Chunk_Ordering(0 To 0)
        ChunkOrdering_First = 0
    Else
        _UBound = UBound(Chunk_Ordering) + 1
        ReDim Preserve Chunk_Ordering(0 To _UBound)
    End If
    Chunk_Ordering(_UBound) = Chunk
    
End Sub

Private Function IsRecognizedChunk (Chunk As Chunk_Type) As Integer
    
    Select Case Chunk.Type_Field
        Case "IHDR", "PLTE", "IDAT", "IEND"
            Return -1
        Case "cHRM", "gAMA", "sBIT", "bKGD", "hIST", _
             "tRNS", "pHYs", "tIME", "tEXt", "zTXt"
            Return -1
        Case Else
            Return 0
    End Select
    
End Function

Private Function IsCriticalChunk (Chunk As Chunk_Type) As Integer
    Return ((Chunk.Type_Field[0] And &H20) = 0)
End Function

Private Function UnCompressIDAT() As Integer
    
    Dim As Unsigned Long Des_Size, Src_Size, Interlace_Size
    Dim As Integer Ret = 0
    Dim As UByte ScanLine()
    
    Src_Size = Ubound(IDAT) + 1
    
    With Header
        
        Des_Size = image_size (.IWidth, .IHeight, .IBitDepth, .IColorType, 0)
        
        ReDim ScanLine(0 to Des_Size - 1)
        
        If .IInterlace = 0 Then
            
            Ret = uncompress (@ScanLine(0), @Des_Size, @IDAT(0), Src_Size)
            Erase IDAT
            If Ret Then Return Ret
            
            Ret = unfilter_image(@ScanLine(0), .IWidth, .IHeight, .IBitDepth, .IColorType, 0)
            If Ret Then Return Ret
            
        ElseIf .IInterlace = 1 Then
            
            Interlace_Size = image_size (.IWidth, .IHeight, .IBitDepth, .IColorType, 1)
            
            Dim As UByte Interlaced(0 to Interlace_Size - 1)
            
            Ret = uncompress (@Interlaced(0), @Interlace_Size, @IDAT(0), Src_Size)
            Erase IDAT
            If Ret Then Return Ret
            
            Ret = unfilter_image(CPtr(UByte Ptr, @Interlaced(0)), .IWidth, .IHeight, .IBitDepth, .IColorType, 1)
            If Ret Then Return Ret
            
            Ret = uninterlace_image(CPtr(UByte Ptr, @ScanLine(0)), CPtr(UByte Ptr, @Interlaced(0)), .IWidth, .IHeight, .IBitDepth, .IColorType)
            Erase Interlaced
            If Ret Then Return Ret
            
            .IInterlace = 0
            
        End If
        
    End With
    
    Scope
        
        Dim As UInteger i, j, Offset, RawScanLineIndex
        
        ReDim RawScanLine(0 To (Header.IHeight * Header.IWidth * Header.Bypp) - 1)
        Dim As UInteger BytesPerScanLine
        
        If Header.IBitDepth >= 8 Then
            
            Offset = 1
            RawScanLineIndex = 0
            BytesPerScanLine = Header.IWidth * Header.Bypp
            
            For i = 0 To Header.IHeight - 1
                
                memcpy(@RawScanLine(RawScanLineIndex), @ScanLine(Offset), BytesPerScanLine)
                
                Offset += BytesPerScanLine + 1
                RawScanLineIndex += BytesPerScanLine
                
            Next i
            
        Else
            
            Dim As Integer Bpp = Header.IBitDepth
            Dim As Integer BitPos
            Dim As UByte Mask = (1 Shl Bpp) - 1
            Dim As UByte CurByte
            
            Offset = 0
            RawScanLineIndex = 0
            
            For i = 0 To Header.IHeight - 1
                
                BitPos = 0
                
                For j = 0 to Header.IWidth - 1
                    
                    BitPos -= Bpp
                    If BitPos < 0 Then
                        BitPos += 8
                        Offset += 1
                        CurByte = ScanLine(Offset)
                    End If
                    
                    RawScanLine(RawScanLineIndex) = (CurByte Shr BitPos) And Mask
                    RawScanLineIndex += 1
                    
                Next j
                
                Offset += 1
                
            Next i
            
        End If
        
    End Scope
    
    Erase ScanLine
    
    Return Ret
    
End Function

Private Function Pout() As Any Ptr
    '|--Puts out to Image--|
    Dim As Integer ColorDepth
    Dim As Any Ptr Image
    
    If ScreenPtr = 0 Then Return 0
    
    ScreenInfo , , ColorDepth
    
    Select Case As Const ColorDepth
        Case 16, 24, 32
            
            Dim As UShort RR, GG, BB, AA, YY
            Dim As UByte PP
            Dim As UInteger RawScanLineIndex, i, j
            
            Image = ImageCreate(Header.IWidth, Header.IHeight, RGBA(0,0,0,0))
            If Image = 0 Then Return 0
            
            RawScanLineIndex = 0
            
            Select Case As Const Header.IColorType
            
                Case 0 'YY
                    
                    For i = 0 To Header.IHeight - 1
                        For j = 0 To Header.IWidth - 1
                            
                            AA = 255
                            
                            YY = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                            If Header.IBitDepth = 16 Then YY = YY Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                            
                            If Header.Has_tRNS Then If Header.tRNS.YY = YY Then AA = 0
                            
                            Select Case As Const Header.IBitDepth
                                Case 1: YY *= &b11111111
                                Case 2: YY *= &b01010101
                                Case 4: YY *= &b00010001
                            End Select
                            
                            If Header.Has_gAMA Then
                                YY = gAMA_Correction(YY)
                            ElseIf Header.IBitDepth = 16 Then
                                YY Shr= 8
                            End If
                            
                            Pset Image,(j,i), RGBA(YY, YY, YY, AA)
                            
                        Next j
                    Next i
                    
                Case 2 'RRGGBB
                    
                    For i = 0 To Header.IHeight - 1
                        For j = 0 To Header.IWidth - 1
                            
                            AA = 255
                            
                            If Header.IBitDepth = 16 Then
                                
                                RR = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                RR = RR Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                GG = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                GG = GG Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                BB = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                BB = BB Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                If Header.Has_tRNS Then _
                                    If Header.tRNS.RR = RR Then _
                                        If Header.tRNS.GG = GG Then _
                                            If Header.tRNS.BB = BB Then AA = 0
                                
                                If Header.Has_gAMA Then
                                    RR = gAMA_Correction(RR)
                                    GG = gAMA_Correction(GG)
                                    BB = gAMA_Correction(BB)
                                Else
                                    RR Shr= 8
                                    GG Shr= 8
                                    BB Shr= 8
                                End If
                                
                            Else
                                
                                RR = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                GG = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                BB = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                If Header.Has_tRNS Then _
                                    If Header.tRNS.RR = RR Then _
                                        If Header.tRNS.GG = GG Then _
                                            If Header.tRNS.BB = BB Then AA = 0
                                
                                If Header.Has_gAMA Then
                                    RR = gAMA_Correction(RR)
                                    GG = gAMA_Correction(GG)
                                    BB = gAMA_Correction(BB)
                                End If
                                
                            End If
                            
                            Pset Image,(j,i), RGBA(RR, GG, BB, AA)
                            
                            
                        Next j
                    Next i
                    
                Case 3 'PP
                    
                    For i = 0 To Header.IHeight - 1
                        For j = 0 To Header.IWidth - 1
                            
                            PP = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                            
                            RR = Pal(PP).RR: GG = Pal(PP).GG: BB = Pal(PP).BB: AA = Pal(PP).AA
                            
                            If Header.Has_gAMA Then
                                RR = gAMA_Correction(RR)
                                GG = gAMA_Correction(GG)
                                BB = gAMA_Correction(BB)
                            End If
                            
                            Pset Image,(j,i), RGBA(RR, GG, BB, AA)
                            
                        Next j
                    Next i
                    
                Case 4 'YYAA
                    
                    For i = 0 To Header.IHeight - 1
                        For j = 0 To Header.IWidth - 1
                            
                            If Header.IBitDepth = 16 Then 
                                YY = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                YY = YY Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                AA = RawScanLine(RawScanLineIndex): RawScanLineIndex += 2
                                
                                If Header.Has_gAMA Then
                                    YY = gAMA_Correction(YY)
                                ElseIf Header.IBitDepth = 16 Then
                                    YY Shr= 8
                                End If
                                
                            Else
                                
                                YY = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                AA = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                If Header.Has_gAMA Then
                                    YY = gAMA_Correction(YY)
                                End If
                                
                            End If
                            
                            Pset Image,(j,i), RGBA(YY, YY, YY, AA)
                            
                        Next j
                    Next i
                    
                Case 6 'RRGGBBAA
                    
                    For i = 0 To Header.IHeight - 1
                        For j = 0 To Header.IWidth - 1
                            
                            If Header.IBitDepth = 16 Then
                                
                                RR = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                RR = RR Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                GG = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                GG = GG Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                BB = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                BB = BB Shl 8 Or RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                AA = RawScanLine(RawScanLineIndex): RawScanLineIndex += 2
                                
                                If Header.Has_gAMA Then
                                    RR = gAMA_Correction(RR)
                                    GG = gAMA_Correction(GG)
                                    BB = gAMA_Correction(BB)
                                Else
                                    RR Shr= 8
                                    GG Shr= 8
                                    BB Shr= 8
                                End If
                                
                            Else
                                
                                RR = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                GG = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                BB = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                AA = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                                
                                If Header.Has_gAMA Then
                                    RR = gAMA_Correction(RR)
                                    GG = gAMA_Correction(GG)
                                    BB = gAMA_Correction(BB)
                                End If
                                
                            End If
                            
                            Pset Image,(j,i), RGBA(RR, GG, BB, AA)
                            
                        Next j
                    Next i
                    
            End Select
                    
        Case 8, 4, 2, 1
            
            If Header.IBitDepth > ColorDepth Then Return 0
            If Header.IColorType <> 0 And Header.IColorType <> 3 Then Return 0
            
            #If UpdatePalette
            If Header.IColorType Then
                
                Dim PalIndex As Integer
                
                For PalIndex = 0 To (1 Shl Header.IBitDepth - 1)
                    With Pal(PalIndex)
                        Palette PalIndex, .RR, .GG, .BB
                    End With
                Next PalIndex
                
            Else
                
                Dim PalIndex As Integer, PalCol as Integer
                
                Select Case Header.IBitDepth
                    Case 1
                        Palette 0, 0, 0, 0
                        Palette 1, 255, 255, 255
                        
                    Case 2
                        For PalIndex = 0 to 3
                            PalCol = PalIndex * &b01010101
                            Palette PalIndex, PalCol, PalCol, PalCol
                        Next PalIndex
                        
                    Case 4
                        For PalIndex = 0 to 15
                            PalCol = PalIndex * &b00010001
                            Palette PalIndex, PalCol, PalCol, PalCol
                        Next PalIndex
                        
                    Case 8
                        For PalIndex = 0 to 255
                            Palette PalIndex, PalIndex
                        Next PalIndex
                        
                    Case Else
                        Return 0
                        
                End Select
                    
            End If
            #EndIf
            
            Dim As UByte PP
            Dim As UInteger RawScanLineIndex, i, j
            
            Image = ImageCreate(Header.IWidth, Header.IHeight, 0)
            If Image = 0 Then Return 0
            
            RawScanLineIndex = 0
            
            For i = 0 To Header.IHeight - 1
                For j = 0 To Header.IWidth - 1
                    
                    PP = RawScanLine(RawScanLineIndex): RawScanLineIndex += 1
                    Pset Image,(j,i), PP
                    
                Next j
            Next i
            
        Case Else
            
            Return 0
            
    End Select
    
    Return Image
    
End Function

Private Function Make_PLTE(ByVal p As UByte Ptr, ByVal Length As UInteger) as integer
    
    If Length < 3 Or Length > 768 Then Return 0
    If Length Mod 3 Then Return 0
    
    Length \= 3
    
    Dim As UInteger i, j
    
    j = 0
    For i = 0 To Length - 1
        Pal(i).RR = p[j]
        Pal(i).GG = p[j + 1]
        Pal(i).BB = p[j + 2]
        Pal(i).AA = 255
        j += 3
    Next i
    
    Return (-1)
    
End Function

Private Function Make_tRNS(ByVal p As UByte Ptr, ByVal Length As UInteger) As Integer
    Dim As Integer i
    
    Select Case As Const Header.IColorType
        Case 0
            If Length <> 2 Then Return 0
            Header.tRNS.YY = p[0] Shl 8 Or p[1]
        Case 2
            If Length <> 6 Then Return 0
            Header.tRNS.RR = p[0] Shl 8 Or p[1]
            Header.tRNS.GG = p[2] Shl 8 Or p[3]
            Header.tRNS.BB = p[4] Shl 8 Or p[5]
        Case 3
            If Length - 1 > UBound(Pal) Then
                Return 0
            Else
                For i = 0 To Length - 1
                   Pal(i).AA = p[i]
                Next i
            End If
        Case Else
            Return 0
    End Select
    
    Return (-1)
    
End Function

Private Sub Make_gAMA_Table()
    
    Dim As Integer i
    Dim As Double gAMA_Power
    
    If Header.gAMA > 0.0 Then
        
        gAMA_Power = 1.0 / (Header.gAMA * 2.5)
        
    Else
        
        gAMA_Power = 1.0
        
    End If
    
    If Header.IBitDepth = 16 Then
        
        Dim t as UInteger
        For i = 0 To 65535
            t = Int(((i / 65536) ^ gAMA_Power) * 256)
            if t > 255 then t = 255
            gAMA_Correction(i) = t
        Next i
        
    Else
        
        For i = 0 To 255
            gAMA_Correction(i) = Int(((i / 255) ^ gAMA_Power) * 255)
        Next i
        
    End If
    
End Sub
