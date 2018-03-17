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

#ifndef ploadlib_bi
#define ploadlib_bi

#ifndef __ploadlib_a__
    #inclib "ploadlib"
    #define __ploadlib_a__
#endif '__ploadlib_a__

#include once "zlib.bi"
#include once "crt.bi"

Enum PLOAD_ERR
    PLOAD_NOERROR = 0        'No Error
    PLOAD_INVALIDSIG         '7 byte Signature Check Failed
    PLOAD_FILECORRUPTED      'Cyclic Redundancy Check Failed
    PLOAD_INVALIDCHUNKS      'Chunks could be in improper order, invalid sigs, critical chunks not recognized, missing required critical chunks
    PLOAD_INVALIDHEADER      'IDHR chunk unsupported according to specification
    PLOAD_INVALID_IDATSTREAM 'Most likely the IDAT stream [zstream] is corrupt and zlib spit back an error
    PLOAD_RENDERINGFAILED    'Current Screendepth is not 24 or 32, ImageCreate Failed, or PLTE chunk is invalid
    PLOAD_FILEOPENED_FAILED  'PLOAD() Failed when opening file
    PLOAD_MISCERROR          'Error trapped by ON ERROR
End Enum

Declare Function Pload(Byval SourceFile As String) As Any Ptr
Declare Function MPload(ByVal PNGData as Any Ptr, ByVal PNGLen as UInteger) As Any Ptr
Declare Function Pload_GetError() As PLOAD_ERR     'Gets Last Pload Error

#endif 'ploadlib_bi