; Minimal test for the OpenAL Soft module.

EnableExplicit

IncludeFile "../openal.pbi" 
IncludeFile "../openal.load.pb" 

UseModule openal

CompilerIf Defined(WAVE_FORMAT_PCM, #PB_Constant) = #False
 #WAVE_FORMAT_PCM = 1
CompilerEndIf

Structure WAVE
  wFormatTag.w
  nChannels.w
  nSamplesPerSec.l
  nAvgBytesPerSec.l
  nBlockAlign.w
  wBitsPerSample.w
  cbSize.w
EndStructure

Procedure.i CheckError()
 Protected err = alGetError()
 
 Select err
    Case #AL_NO_ERROR
        ; OK
    Case #AL_INVALID_NAME
        Debug "Invalid name"
    Case #AL_INVALID_ENUM
        Debug "Invalid enum"
    Case #AL_INVALID_VALUE
        Debug "Invalid value"
    Case #AL_INVALID_OPERATION
        Debug "Invalid operation"
    Case #AL_OUT_OF_MEMORY
        Debug "Out of memory"
 EndSelect
 
 ProcedureReturn err
EndProcedure

Procedure.i CheckContextError (device)
 Protected err = alcGetError(device)
 
 Select err
    Case #ALC_NO_ERROR
        ; OK
    Case #ALC_INVALID_DEVICE
        Debug "Invalid device"
    Case #ALC_INVALID_CONTEXT
        Debug "Invalid context"
    Case #ALC_INVALID_ENUM
        Debug "Invalid enum"        
    Case #ALC_INVALID_VALUE
        Debug "Invalid value"
    Case #ALC_OUT_OF_MEMORY
        Debug "Out of memory"
 EndSelect
 
 ProcedureReturn err
EndProcedure

Procedure.i CreateSound (freq, duration, *dataptr, *datalen)
 ; mono, 8 bits
 
 ; http://www.purearea.net/pb/CodeArchiv/Music+Movie/Wave/MakeSound.pb
 
 Protected w.f
 Protected WaveFormatEx.WAVE
  
 #Mono = 1
 #SampleRate = 22050; // 8000, 11025, 22050, or 44100
 #RiffId = "RIFF"
 #WaveId = "WAVE"
 #FmtId  = "fmt "
 #DataId = "data"
  
 WaveFormatEx\wFormatTag = #WAVE_FORMAT_PCM
 WaveFormatEx\nChannels = #Mono;
 WaveFormatEx\nSamplesPerSec = #SampleRate;
 WaveFormatEx\wBitsPerSample = $0008;
 WaveFormatEx\nBlockAlign = (WaveFormatEx\nChannels * WaveFormatEx\wBitsPerSample) / 8
 WaveFormatEx\nAvgBytesPerSec = WaveFormatEx\nSamplesPerSec * WaveFormatEx\nBlockAlign;
 WaveFormatEx\cbSize = 0;

 Protected DataCount = (duration * #SampleRate) / 1000
 Protected RiffCount = 4 + 4 + 4 + SizeOf(WAVE) + 4 + 4 + DataCount
 Protected *MS = AllocateMemory(RiffCount + 100)
  
 Protected i
  
 PokeS(*MS+i, #RiffId, -1, #PB_Ascii) : i + 4  ; 'RIFF'
 PokeL(*MS+i, RiffCount): i + 4 ; file data size
 PokeS(*MS+i, #WaveId, -1, #PB_Ascii) : i + 4  ; 'WAVE'
 PokeS(*MS+i, #FmtId, -1, #PB_Ascii) : i + 4   ; 'fmt '
  
 PokeL(*MS+i, SizeOf(WAVE)) : i + 4   
 
 PokeW(*MS+i, WaveFormatEx\wFormatTag) : i + 2 
 PokeW(*MS+i, WaveFormatEx\nChannels) : i + 2
 PokeL(*MS+i, WaveFormatEx\nSamplesPerSec) : i + 4
 PokeL(*MS+i, WaveFormatEx\nAvgBytesPerSec) : i + 4
 PokeW(*MS+i, WaveFormatEx\nBlockAlign) : i + 2
 PokeW(*MS+i, WaveFormatEx\wBitsPerSample) : i + 2
 PokeW(*MS+i, WaveFormatEx\cbSize) : i + 2

 PokeS(*MS+i, #DataId, -1, #PB_Ascii) : i + 4 ; 'data'
 PokeL(*MS+i, DataCount) : i + 4 ;sound data size

 w = 2 * #PI * freq
  
 Protected j
 
 PokeI(*datalen, DataCount)
 PokeI(*dataptr, *MS+i)
 
 For j = 0 To DataCount - 1
    PokeB(*MS+i, 127 + 127 * Sin(j * w / #SampleRate)) : i + 1
 Next
  
 ProcedureReturn *MS
EndProcedure

Procedure PrintDeviceList (*p)
 Protected s$, l
 
 While *p 
    s$ = PeekS(*p, -1, #PB_Ascii)
    Debug s$
          
    l = Len(s$)
        
    *p + l + 1
    
    If PeekB(*p) = 0
        Break
    EndIf
 Wend
EndProcedure

Procedure Main() 
 Protected err, *p, s$
 
 Debug "Available playback devices:"
 
 ; enumerates available playback devices 
 
 If alcIsExtensionPresent(#Null, "ALC_ENUMERATE_ALL_EXT") ; this should always present in OpenAL Soft
    *p = alcGetString(#Null, #ALC_ALL_DEVICES_SPECIFIER)
    If *p
        PrintDeviceList (*p)
        Debug ""
    EndIf
    
    *p = alcGetString(#Null, #ALC_DEFAULT_ALL_DEVICES_SPECIFIER) 
    If *p
        s$ = PeekS(*p, -1, #PB_Ascii)
        Debug "Default playback device:"
        Debug s$
        Debug ""
    EndIf    
 Else
    *p = alcGetString(#Null, #ALC_DEVICE_SPECIFIER)
    If *p
        PrintDeviceList (*p)
        Debug ""
    EndIf

    *p = alcGetString(#Null, #ALC_DEFAULT_DEVICE_SPECIFIER) 
    If *p
        s$ = PeekS(*p, -1, #PB_Ascii)
        Debug "Default playback device:"
        Debug s$
        Debug ""
    EndIf    
 EndIf
 
 Protected device, context 
 
 ; open default device 
 device = alcOpenDevice(#Null$)
 If device = #False : Goto exit : EndIf
 
 ; creates rendering context
 context = alcCreateContext(device, #Null)
 If context = #False : Goto exit : EndIf
 
 ; and makes it current
 
 If alcMakeContextCurrent(context) = #False : Goto exit : EndIf
 
 Debug "Default device opened and context selected."
 Debug ""
 
 ; get version 
 *p = alGetString(#AL_VERSION)
 If *p
    s$ = PeekS(*p, -1, #PB_Ascii)
    Debug "OpenAL version: " + s$
 EndIf

 ; get vendor
 *p = alGetString(#AL_VENDOR)
 If *p
    s$ = PeekS(*p, -1, #PB_Ascii)
    Debug "OpenAL vendor: " + s$
 EndIf    

 ; get renderer
 *p = alGetString(#AL_RENDERER)
 If *p
    s$ = PeekS(*p, -1, #PB_Ascii)
    Debug "OpenAL renderer: " + s$
 EndIf
 
 Debug ""
 
 Protected source, buffer, dataptr, datalen, state
 
 CheckError()
 
 ; creates one audio source 
 alGenSources(1, @source)
 alSourcef(source, #AL_PITCH, 1.0)
 alSourcef(source, #AL_GAIN, 1.0)
 alSource3f(source, #AL_POSITION, 0, 0, 0)
 alSource3f(source, #AL_VELOCITY, 0, 0, 0)
 alSourcei(source, #AL_LOOPING, #AL_FALSE)
 If CheckError() : Goto exit : EndIf
 
 ; creates one buffer  
 alGenBuffers(1, @buffer)
 If CheckError() : Goto exit : EndIf
 
 ; make an in-memory sound (440 Hz, 2 seconds long, 8 bits, 22KHz)
 Protected *sound = CreateSound (440, 2000, @dataptr, @datalen) 
 
 ; fill the buffer with audio data 
 alBufferData(buffer, #AL_FORMAT_MONO8, dataptr, datalen, 22050)
 If CheckError() : Goto exit : EndIf
 
 ; and binds the buffer to the source
 alSourcei(source, #AL_BUFFER, buffer) 
 If CheckError() : Goto exit : EndIf
 
 Debug "Playing 440 Hz sine sound having a lenght of 2 seconds ..."
 
 ; plays the sound in the background 
 alSourcePlay(source)
 If CheckError() : Goto exit : EndIf
 
 alGetSourcei(source, #AL_SOURCE_STATE, @state)
 If CheckError() : Goto exit : EndIf
 
 ; wai until the sound has been completely played
 While state = #AL_PLAYING
    alGetSourcei(source, #AL_SOURCE_STATE, @state)
 Wend
 
 alSourceStop(source)
 CheckError()
 
 Debug "Stopped."
 
exit:

 ; cleanup
 
 Debug "Cleanup."
 
 If *sound : FreeMemory(*sound) : EndIf
 
 If source : alDeleteSources(1, @source) : EndIf
 
 If buffer : alDeleteBuffers(1, @buffer) : EndIf
    
 If context
    alcMakeContextCurrent(#Null)
    alcDestroyContext(context)
 EndIf
 
 If device : alcCloseDevice(device) : EndIf        
EndProcedure

; imports all the functions from the DLL

If openal_load::Load() = openal_load::#LOAD_OK
    Main()      
    openal_load::Shutdown()
Else
    Debug "Import failed."
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 119
; FirstLine = 86
; Folding = --
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory