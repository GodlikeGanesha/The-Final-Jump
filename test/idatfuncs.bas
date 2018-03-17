/' idatfuncs - Functions to remove filters and interlacing from PNG image data
 ' Copyright (C) 2006 Matthew Fearnley (counting.pine@virgin.net)
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

'option explicit

#include once "crt.bi"
'#define debug_mode

static shared as integer startx(1 to 7) => {0, 4, 0, 2, 0, 1, 0}
static shared as integer stepx(1 to 7)  => {8, 8, 4, 4, 2, 2, 1}
static shared as integer lstepx(1 to 7) => {3, 3, 2, 2, 1, 1, 0}

static shared as integer starty(1 to 7) => {0, 0, 4, 0, 2, 0, 1}
static shared as integer stepy(1 to 7)  => {8, 8, 8, 4, 4, 2, 2}
static shared as integer lstepy(1 to 7) => {3, 3, 3, 2, 2, 1, 1}

'===============================================================================

'Public function declarations:


'image_size(wid, hei, bitdepth, colortype, interlace)

'Returns the size of uncompressed PNG image data, given the relevant
'information, which can be found in the IHDR chunk.
declare function image_size(byval wid as integer, _
                    byval hei as integer, _
                    byval bitdepth as integer, _
                    byval colortype as integer = 0, _
                    byval interlace as integer = 0) _
as uinteger


'unfilter_image(img, wid, hei, bitdepth, colortype, interlace)

'Unfilters uncompressed PNG image data.  The data can either be uninterlaced,
'or interlaced with Adam7.
'It overwrites the original, filtered data with the unfiltered data.
declare function unfilter_image(byval img as ubyte ptr, _
                                byval wid as integer, _
                                byval hei as integer, _
                                byval bitdepth as integer, _
                                byval colortype as integer = 0, _
                                byval interlace as integer = 0) _
as integer


'uninterlace_image(dest, source, wid, hei, bpp, colortype)

'Takes uncompressed, interlaced image data, and converts it to uninterlaced
'image data, storing it at a provided memory address.  The image data must
'already be unfiltered, which can be done using unfilter_image()
declare function uninterlace_image(byval dest as ubyte ptr, _
                                   byval source as ubyte ptr, _
                                   byval wid as integer, _
                                   byval hei as integer, _
                                   byval bpp as integer, _
                                   byval colortype as integer = 0) _
as integer



'===============================================================================

'Private function declarations:


'unfilter_pass(img, rowlen, heigfht, bypp)

'Unfilters uncompressed, uninterlaced PNG image data, or a single pass of 
'uncopmpressed, interlaced PNG image data.
'It overwrites the original, filtered data with the unfiltered data.
declare function unfilter_pass(byval img as ubyte ptr, _
                               byval rowlen as integer, _
                               byval height as integer, _
                               byval bypp as integer) _
as integer


'uninterlace_bits(dest, source, wid, hei, bpp)

'Takes uncompressed, interlaced image data, and converts it to uninterlaced
'image data, storing it at a provided memory address.  The image data must
'already be unfiltered, which can be done using unfilter_image().  It must have
'a bit depth of no more than 8 bits per pixel.
declare function uninterlace_bits(byval dest as ubyte ptr, _
                                  byval source as ubyte ptr, _
                                  byval wid as integer, _
                                  byval hei as integer, _
                                  byval bpp as integer) _
as integer

'ininterlace_bytes(dest, source, wid, hei, bypp)

'Takes uncompressed, interlaced image data, and converts it to uninterlaced
'image data, storing it at a provided memory address.  The image data must
'already be unfiltered, which can be done using unfilter_image().  It must have
'a bit depth that is a multiple of 8 bits per sample.
declare function uninterlace_bytes(byval dest as ubyte ptr, _
                                   byval source as ubyte ptr, _
                                   byval wid as integer, _
                                   byval hei as integer, _
                                   byval bypp as integer) _
as integer


'===============================================================================

'Public Functions:

public function image_size(byval wid as integer, _
                    byval hei as integer, _
                    byval bitdepth as integer, _
                    byval colortype as integer = 0, _
                    byval interlace as integer = 0) as uinteger
    
    if wid <= 0 or hei <= 0 or bitdepth <= 0 then return 0
    
    dim bpp as uinteger
    
    select case as const colortype
        case 0, 3
            bpp = bitdepth
        case 2
            bpp = bitdepth * 3
        case 4
            bpp = bitdepth * 2
        case 6
            bpp = bitdepth * 4
        case else
            return 0
    end select
    
    if interlace = 0 then
        
        return hei * (1 + (wid * bpp + 7) shr 3)
        
    elseif interlace = 1 then
        
        dim size as uinteger
        dim as integer passwid, passhei, passrowlen
        dim pass as integer
        
        size = 0
        
        for pass = 1 to 7
            
            if startx(pass) < wid and starty(pass) < hei then
                
                passwid = (wid - startx(pass) - 1) shr lstepx(pass) + 1
                passhei = (hei - starty(pass) - 1) shr lstepy(pass) + 1
                
                passrowlen = (1 + (passwid * bpp + 7) shr 3)
                    
                size += passhei * passrowlen
                
            end if
            
        next pass
        
        return size
        
    else
        
        return 0
        
    end if
    
end function

public function unfilter_image(byval img as ubyte ptr, _
                        byval wid as integer, _
                        byval hei as integer, _
                        byval bitdepth as integer, _
                        byval colortype as integer = 0, _
                        byval interlace as integer = 0) as integer
   
    dim as uinteger bpp
    dim as uinteger bypp
   
    select case as const colortype
        case 0, 3
            bpp = bitdepth
        case 2
            bpp = bitdepth * 3
        case 4
            bpp = bitdepth * 2
        case 6
            bpp = bitdepth * 4
        case else
            return -1
    end select
    
    bypp = (bpp + 7) shr 3
    
    select case interlace
        
        case 0
            
            dim as uinteger rowlen = (wid * bpp + 7) shr 3 + 1
            return unfilter_pass(img, rowlen, hei, bypp)
            
        case 1
            
            dim pass as integer
            dim as ubyte ptr passimg = img
            
            for pass = 1 to 7
                
                if startx(pass) < wid and starty(pass) < hei then
                    
                    dim as uinteger passwid = (wid - startx(pass) - 1) shr lstepx(pass) + 1
                    dim as uinteger passhei = (hei - starty(pass) - 1) shr lstepy(pass) + 1
                    
                    dim as uinteger passrowlen = (passwid * bpp + 7) shr 3 + 1
                    
                    if unfilter_pass(passimg, passrowlen, passhei, bypp) then return -1
                    
                    passimg += passrowlen * passhei
                    
                end if
                
            next pass
            
        case else
            
            return -1
           
    end select
    
    return 0
   
end function

public function uninterlace_image(byval dest as ubyte ptr, _
                           byval source as ubyte ptr, _
                           byval wid as integer, _
                           byval hei as integer, _
                           byval bpp as integer, _
                           byval colortype as integer = 0) as integer
    
    select case as const colortype
        case 0, 3
        case 2
            bpp *= 3
        case 4
            bpp *= 2
        case 6
            bpp *= 4
        case else
            return -1
    end select
    
    if bpp >= 8 then
        
        if bpp and 7 then return -1
        
        return uninterlace_bytes(dest, source, wid, hei, bpp shr 3)
        
    else
        
        if bpp = 0 then return -1
        
        if bpp and (bpp - 1) then return -1 'if bpp not a power of 2 (1, 2 or 4)
        
        return uninterlace_bits(dest, source, wid, hei, bpp)
        
    end if
    
end function


'===============================================================================

'Private Functions:

private function unfilter_pass(byval img as ubyte ptr, _
                       byval rowlen as integer, _
                       byval height as integer, _
                       byval bypp as integer) as integer
    
    dim as uinteger y
    dim as uinteger x
    
    dim as ubyte ptr row, lastrow
    dim as ubyte byte1, byte2, byte3, byte4
    
    if height = 0 then return -1
    if rowlen <= 1 then return -1
    
    row = img
    
    select case as const row[0]
        
        case 0, 2 'None, dY
            
        case 1, 4 'dX, Paeth
            
            for x = bypp + 1 to rowlen - 1
                
                byte1 = row[x]
                
                byte2 = row[x - bypp]
                
                byte1 += byte2
                row[x] = byte1
                
            next x
            
        case 3 'Avg
            
            for x = bypp + 1 to rowlen - 1
                
                byte1 = row[x]
                byte2 = row[x - bypp]
                
                byte1 += byte2 shr 1
                row[x] = byte1
                
            next x
           
        case else
            
            return -1
            
    end select
   
    row[0] = 0
    
    
    for y = 1 to Height - 1
        
        lastrow = row
        row += rowlen
       
        select case as const row[0]
            
            case 0 'None
                
            case 1 'dX
                
                for x = bypp + 1 to rowlen - 1
                    
                    byte1 = row[x]
                    byte2 = row[x - bypp]
                    
                    byte1 += byte2
                    row[x] = byte1
                    
                next x
                   
            case 2 'dY
                
                for x = 1 to rowlen - 1
                    
                    byte1 = row[x]
                    byte2 = lastrow[x]
                    
                    byte1 += byte2
                    row[x] = byte1
                    
                next x
                   
            case 3 'Avg
                
                for x = 1 to bypp
                    
                    byte1 = row[x]
                    byte2 = lastrow[x]
                    
                    byte1 += byte2 shr 1
                    
                    row[x] = byte1
                    
                next x
                
                for x = bypp + 1 to rowlen - 1
                    
                    byte1 = row[x]
                    byte2 = lastrow[x]
                    byte3 = row[x - bypp]
                    
                    byte1 += (byte2 + byte3) shr 1
                    row[x] = byte1
                    
                next x
                   
            case 4 'Paeth
                
                for x = 1 to bypp
                    
                    byte1 = row[x]
                    byte2 = lastrow[x]
                    
                    byte1 += byte2
                    row[x] = byte1
                   
                next x
                
                for x = bypp + 1 to rowlen - 1
                    
                    byte1 = row[x]
                    byte2 = row[x - bypp]
                    byte3 = lastrow[x]
                    byte4 = lastrow[x - bypp]
                    
                    scope
                        
                        dim as integer p = byte2 + byte3 - byte4
                        dim as uinteger p2 = abs(p - byte2), p3 = abs(p - byte3), p4 = abs(p - byte4)
                        
                        'if p2 <= p3 and p2 <= p4 then byte1 += byte2 elseif p3 <= p4 then byte1 += byte3 else byte1 += byte4
                        
                        byte1 += iif(p3 <= p4, iif(p2 <= p3, byte2, byte3), iif(p2 <= p4, byte2, byte4))
                        
                    end scope
                    
                    row[x] = byte1
                    
                next x
                   
            case else
                
                return -1
               
        end select
       
        row[0] = 0
       
    next y
   
    return 0
   
end function

private function uninterlace_bits(byval dest as ubyte ptr, _
                          byval source as ubyte ptr, _
                          byval wid as integer, _
                          byval hei as integer, _
                          byval bpp as integer) as integer
    
    
    dim as uinteger rowlen = (wid * bpp + 7) shr 3 + 1
    dim as uinteger bitsmask = 256 - (256 shr bpp)
    
    dim as uinteger xoff, xbit, startxbit, stepxbit
    dim as uinteger rowskip
    dim as ubyte ptr row
    
    dim as integer pass
    dim as uinteger passwid, passhei, passrowlen
    dim as uinteger passx, passy, passxoff, passxbit
    
    dim as uinteger bits
    dim as ubyte ptr passrow
    
    dim as ubyte     b1, b2
    dim as ubyte ptr p1, p2
    
    #ifdef debug_mode
    dim passdata as ubyte ptr, passsize as uinteger
    #endif
    
    row = dest
    passrow = source
    
    for pass = 1 to 7
        
        #ifdef debug_mode
        if pass = 1 then passdata = source else passdata += passsize
        assert(passrow = passdata)
        #endif
        
        if startx(pass) >= wid or starty(pass) >= hei then
            #ifdef debug_mode
            passsize = 0
            #endif
            continue for
        end if
        
        passwid = (wid - startx(pass) - 1) shr lstepx(pass) + 1
        passhei = (hei - starty(pass) - 1) shr lstepy(pass) + 1
        
        passrowlen = (passwid * bpp + 7) shr 3 + 1
        #ifdef debug_mode
        passsize = passrowlen * passhei
        #endif
        
        rowskip = rowlen shl lstepy(pass)
        
        startxbit = 8 + bpp * startx(pass)
        stepxbit = bpp shl lstepx(pass)
        
        row = @dest[starty(pass) * rowlen]
        
        for passy = 0 to passhei - 1
            
            p1 = passrow
            p2 = row
            
            b2 = 0
            
            xbit = startxbit
            passxbit = 8
            
            for passx = 0 to passwid - 1
                
                passxbit += bpp
                if passxbit < 0 then
                    p1 += 1
                    b1 = *p1
                    passxbit += 8
                end if
                
                xbit += stepxbit
                if xbit < 0 then
                    *p2 = b2
                    p2 += csign(-xbit) shr 3
                    b2 = *p2
                    xbit and= 7
                end if
                
                bits = (b1 shl passxbit) and bitsmask
                
                b2 = (b2 and not (bitsmask shr xbit)) or (bits shl xbit)
                
            next passx
            
            row += rowskip
            
            passrow += passrowlen
            
        next passy
        
    next pass
        
    return 0
    
end function

private function uninterlace_bytes(byval dest as ubyte ptr, _
                           byval source as ubyte ptr, _
                           byval wid as integer, _
                           byval hei as integer, _
                           byval bypp as integer) as integer
    
    
    dim as uinteger rowlen = (wid * bypp) + 1
    
    dim as uinteger xoff, startxoff, stepxoff
    dim as integer rowskip
    dim as ubyte ptr row
    
    dim as integer pass
    dim as uinteger passwid, passhei, passrowlen
    dim as uinteger passx, passy, passxoff
    
    dim as ubyte ptr p1, p2
    dim as ubyte ptr passrow
    
    #ifdef debug_mode
    dim passdata as ubyte ptr, passsize as uinteger
    #endif
    
    row = dest
    passrow = source
    
    for pass = 1 to 7
        
        #ifdef debug_mode
        if pass = 1 then passdata = source else passdata += passsize
        if passrow <> passdata then return -1
        #endif
        
        if startx(pass) >= wid or starty(pass) >= hei then 
            #ifdef debug_mode
            passsize = 0
            #endif
            continue for
        end if
        
        passwid = (wid - startx(pass) - 1) shr lstepx(pass) + 1
        passhei = (hei - starty(pass) - 1) shr lstepy(pass) + 1
        
        passrowlen = (passwid * bypp) + 1
        #ifdef debug_mode
        passsize = passrowlen * passhei
        #endif
        
        rowskip = rowlen shl lstepy(pass)
        
        startxoff = 1 + bypp * startx(pass)
        stepxoff = bypp shl lstepx(pass)
        
        row = @dest[starty(pass) * rowlen]
        
        for passy = 0 to passhei - 1
            
            row[0] = 0
            
            xoff = startxoff
            passxoff = 1
            
            select case as const bypp
                
                case 1
                    
                    for passx = 0 to passwid - 1
                        
                        p1 = @passrow[passxoff]
                        p2 = @row[xoff]
                        
                        *p2 = *p1
                        
                        xoff = xoff + stepxoff
                        passxoff += 1
                        
                    next passx
                    
                case 2
                    
                    for passx = 0 to passwid - 1
                        
                        p1 = @passrow[passxoff]
                        p2 = @row[xoff]
                        
                        *cptr(ushort ptr, p2) = *cptr(ushort ptr, p1)
                        
                        xoff = xoff + stepxoff
                        passxoff += 2
                        
                    next passx
                    
                case 4
                    
                    for passx = 0 to passwid - 1
                        
                        p1 = @passrow[passxoff]
                        p2 = @row[xoff]
                        
                        *cptr(uinteger ptr, p2) = *cptr(uinteger ptr, p1)
                        
                        xoff = xoff + stepxoff
                        passxoff += 4
                        
                    next passx
                    
                case else
                    
                    for passx = 0 to passwid - 1
                        
                        p1 = @passrow[passxoff]
                        p2 = @row[xoff]
                        
                        #if 0
                        dim i as integer
                        for i = 0 to bypp - 1
                            p2[i] = p1[i]
                        next i
                        #else
                        memcpy p2, p1, bypp
                        #endif
                        
                        xoff += stepxoff
                        passxoff += bypp
                        
                    next passx
                    
            end select
            
            row += rowskip
            
            passrow += passrowlen
            
        next passy
        
    next pass
    
    return 0
    
end function

