; Minimal test for the libsndfile module.

EnableExplicit

IncludeFile "../libsndfile.pbi" 
IncludeFile "../libsndfile.load.pb" 

UseModule libsndfile

Procedure ShowFileInfo (fname$)
 Protected fmt_info.SF_FORMAT_INFO
 Protected sf_info.SF_INFO
 Protected format, subFormat
 
 Protected sndfile = sf_open (fname$, #SFM_READ, @sf_info)
  
 If sndfile
    
    Debug "Opened file " + fname$
    
    ; Debug Hex(sfinfo\format)
    
    format = sf_info\format & #SF_FORMAT_TYPEMASK
    subFormat = sf_info\format & #SF_FORMAT_SUBMASK
    
    fmt_info\format = format
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) = 0
        Debug "Audio format: "  + PeekS(fmt_info\name, -1, #PB_UTF8)    
    EndIf
    
    fmt_info\format = subFormat
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) = 0
        Debug "Audio subformat: "  + PeekS(fmt_info\name, -1, #PB_UTF8)
    EndIf
    
    Debug "Channels: " + sf_info\channels
    Debug "Sample rate: " + sf_info\samplerate
    Debug ""
 Else
    Debug "cannot open " + fname$
    Debug ""
 EndIf

EndProcedure

Procedure Main()
 Dim buffer.b(64)
 
 Protected len = sf_command (#Null, #SFC_GET_LIB_VERSION, buffer(), ArraySize(buffer())) 
 If len 
    Protected ver$ = PeekS(@buffer(), len, #PB_UTF8)
    Debug "Library version string: " + ver$
    Debug ""
 EndIf
 
 Protected info.SF_FORMAT_INFO
 Protected sfinfo.SF_INFO
 Protected majorCount, subtypeCount, format, subFormat, i, j
 
 Debug "Supported audio formats:"
 Debug ""
 
 sf_command (#Null, #SFC_GET_FORMAT_MAJOR_COUNT, @majorCount, SizeOf (Long))
 sf_command (#Null, #SFC_GET_FORMAT_SUBTYPE_COUNT, @subtypeCount, SizeOf (Long))

 
 For i = 0 To majorCount - 1
    info\format = i
    
    If sf_command (#Null, #SFC_GET_FORMAT_MAJOR, @info, SizeOf (SF_FORMAT_INFO)) = 0
        Debug PeekS(info\name, -1, #PB_UTF8)
        
        format = info\format
        
        For j = 0 To subtypeCount - 1
            info\format = j
            
            sf_command (#Null, #SFC_GET_FORMAT_SUBTYPE, @info, SizeOf (SF_FORMAT_INFO)) 
            
            format = (format & #SF_FORMAT_TYPEMASK) | info\format

            sfinfo\channels = 1
            sfinfo\format = format
            
            If sf_format_check (@sfinfo)
                Debug "   " + PeekS(info\name, -1, #PB_UTF8) 
            EndIf
        Next        
    Else
        Debug "sf_command() error !"
    EndIf
 Next 
 
 Debug ""
 
 ShowFileInfo("../../assets/pb-mono-08-bits.wav")
 
 ShowFileInfo("../../assets/pb-mono-16-bits.wav")
 
 ShowFileInfo("../../assets/blues.mp3")
EndProcedure

; imports all the functions from the DLL

If libsndfile_load::Load() = libsndfile_load::#LOAD_OK
    Main()      
    libsndfile_load::Shutdown()
Else
    Debug "Import failed."
EndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 95
; FirstLine = 63
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory