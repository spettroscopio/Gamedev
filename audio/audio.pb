; *********************************************************************************************************************
; audio.pb
; by luis
;
; To play sounds.
;
; Tested on: Windows (x86, x64)
;
; 1.0, Aug 03 2023, PB 6.02 
; *********************************************************************************************************************

; TODO

; 3D sound

XIncludeFile "./openal-soft/openal.pbi" 
XIncludeFile "./openal-soft/openal.load.pb" 

XIncludeFile "./libsndfile/libsndfile.pbi" 
XIncludeFile "./libsndfile/libsndfile.load.pb" 

XIncludeFile "../inc/dbg.pb"
XIncludeFile "../inc/str.pb"
XIncludeFile "../inc/SBBT.pb"

;- * INTERFACE *

DeclareModule audio

#AUDIO_MAJ = 0
#AUDIO_MIN = 9
#AUDIO_REV = 0

; state
#Ready      = 1 
#Playing    = 2
#Paused     = 3
#Stopped    = 4
  
; length
#Frames         = 5
#Milliseconds   = 6

;- CallBacks   
Prototype CallBack_Error (Source$, Desc$)

;- Structures

Structure SoundFileInfo
 majFmt$        ; string description of the audio format
 subFmt$        ; string description of the audio subformat 
 samplerate.i   ; in hertz
 channels.i     ; 1 = mono, 2 = stereo
 frames.i       ; sound length in frames 
 milliseconds.i ; sound length in milliseconds
 bytes.i        ; size in bytes of the audio data after being loaded in memory
EndStructure

Structure SoundLocation
; TODO
EndStructure

;- Declares

Declare      RegisterErrorCallBack (*fp) ; Registers a callback to get runtime error messages from the library.
Declare.i    Init() ; Initialize the library.
Declare      Shutdown() ; Shutdown the library.
Declare.s    GetVersion() ; Returns a string representing the Audio version.
Declare.s    GetLibSndFileVersion() ; Returns a string representing the version of the LibSndFile support library.
Declare.s    GetOpenALVersion() ; Returns a string representing the version of the OpenAL support library.
Declare.s    GetDefaultDeviceName() ; Returns the string identifying the default playback device.
Declare.i    GetAllDevicesNames (Array devices$(1)) ; Populates an array of strings identifying all the available playback devices.
Declare.s    GetCurrentDeviceName() ; Returns the string identifying the device associated to the current context.
Declare.i    OpenDevice (device$ = #Null$) ; Open the specified playback device using its name or default one if the name is omitted.
Declare.i    GetCurrentDevice() ; Returns the handle of the playback device associated to the current context.
Declare      CloseDevice (device) ; Close the specified playback device and destroys the current context, if any.
Declare.i    GetSoundFileInfo (file$, *sfi.SoundFileInfo) ; Retrieves some info about the specified aound file and fills the passed structure with them.
Declare.i    CreateBufferFromMemory (bits, samplerate, channels, *data, dataSize)
Declare.i    CreateBufferFromMemoryFile (*data, dataSize)
Declare.i    CreateBufferFromFile (file$) ; Creates an audio buffer from the sound file and returns its handle.
Declare.i    IsBufferBound (buffer)
Declare.i    IsSoundBound (sound)
Declare.i    CreateSound()
Declare.i    CreateSoundFromBuffer (buffer) ; Create a sound from the passed audio buffer and returns its handle.
Declare.i    BindBuffer (sound, buffer) ; Bind the passed audio buffer to the source and unbinds the previously bound if any.
Declare      DestroySound (sound) ; Destroy a sound releasing its own resources.
Declare      DestroyBuffer (buffer) ; Destroy a buffer releasing its own resource.
Declare.i    GetAudioDataSize (sound) ; Returns the size in bytes of the audio data stored in memory for the sound.
Declare.s    GetFormatString (sound) ; Returns the audio format string of the loaded audio file.
Declare.s    GetSubFormatString (sound) ; Returns the sub-audio format string of the loaded audio file.
Declare.i    GetChannels (sound) ; Returns the number of channels of the sound (1 = mono, 2 = stereo).
Declare.i    GetSampleRate (sound) ; Returns the sample rate in Hz of the sound.
Declare.i    GetLength (sound, format) ; Returns the length of the sound expressed in milliseconds or frames.
Declare      SetLooping (sound, loop)
Declare.i    GetState (sound) ; Returns the current state of the sound.
Declare.i    GetPos (sound, format) ; Returns the current position in milliseconds or frames for the specified sound.
Declare      SetPos (sound, position, format) ; Sets the sound current position in milliseconds or frames.
Declare      Play (sound, loop = #False) ; Start playing the specified audio file.
Declare      Pause (sound) ; Pause the reproduction of the specified audio file.
Declare      Resume (sound) ; Resume the reproduction of specified sound if it was paused, else do nothing.
Declare      Stop (sound) ; Stop the reproduction of the specified audio file.
Declare      PlayArray (Array sounds(1)) ; Start playing the sounds listed in the array while guaranteeing synchronized operation.
Declare      PauseArray (Array sounds(1)) ; Pause the reproduction of the sounds listed in the array while guaranteeing synchronized operation.
Declare      ResumeArray (Array sounds(1)) ; Resume the reproduction of the sounds listed in the array which are currently paused while guaranteeing synchronized operation.
Declare      StopArray (Array sounds(1)) ; Stop the reproduction of the sounds listed in the array while guaranteeing synchronized operation.
Declare      PauseAll() ; Pause the reproduction of every sound currently playing.
Declare      ResumeAll() ; Resume the reproduction of every sound currently paused.
Declare      StopAll() ; Stop every sound currently playing or paused.
Declare      SetVolume (sound, volume.f) ; Set the volume of the specified sound (from 0.0 to 1.0)
Declare      SetGlobalVolume (volume.f) ; Set the global volume (from 0.0 to 1.0)
Declare      SetLocation (sound, *loc.SoundLocation)

EndDeclareModule


Module audio

EnableExplicit

; In OpenAL samples are the same thing as frames in libsndfile: a unit of PCM data for every channel.
; A 16 bit mono sample is 16 bits of data = one OpenAL sample = one libsndfile frame.
; A 16 bit stereo sample is 32 bits of data (16 bits per channel) = one OpenAL sample = one libsndfile frame.
; On a source in the AL_STOPPED state, all buffers are marked as processed.
; On a source in the AL_INITIAL state, no buffers are being processed, and all buffers are pending.

UseModule libsndfile ; import constants and global functions 
UseModule openal ; import constants and global functions 
UseModule dbg

;- Structures

Structure AudioBuffer
 magic.l     ; magic number 
 ALBuffer.i  ; OpenAL buffer object 
 srcMajFmt$  ; string description of the audio format
 srcSubFmt$  ; string description of the audio subformat
 srcMajFmt.i ; major format ID from LibSndFile 
 srcSubFmt.i ; subformat ID from LibSndFile 
 audioFormat.i ; #AL_FORMAT_MONO16, #AL_FORMAT_STEREO16, #AL_FORMAT_MONO8, #AL_FORMAT_STEREO8
 samplerate.i  ; in hertz
 channels.i    ; 1 = mono, 2 = stereo
 length.i      ; sound length in frames 
 bytes.i       ; size in bytes of the audio data
 bindings.i    ; the instances of this buffer bound to different sounds 
EndStructure

Structure SoundHandle
 magic.l    ; magic number
 ALSource.i ; OpenAL source object 
 *buffer.AudioBuffer ; AudioBuffer
EndStructure

Structure VirtualUserData 
 *fp    ; virtual file pointer
 *start ; pointer to the start of the virtual file
 length.i ; length of the virtual file 
EndStructure

;- Declares

Declare.i    LSF_CheckError (sf, here$)
Declare.i    OAL_CheckError (here$)
Declare.i    OAL_ContextCheckError (device, here$)
Declare.i    PopulateDeviceList (*p, Array devices$(1))
Declare      InitAudioObj()

DeclareC.q   cb_get_filelen (*user_data)
DeclareC.q   cb_seek (offset.q, whence, *user_data)
DeclareC.q   cb_read (*ptr, count.q, *user_data)
DeclareC.q   cb_tell (*user_data)

; error callback sources
#SOURCE_ERROR_AUDIO$        = "AUDIO"
#SOURCE_ERROR_OPENAL$       = "OPENAL" 
#SOURCE_ERROR_LIBSNDFILE$   = "LIBSNDFILE"

; signature
#MAGIC_SOUND  = $BA51C128
#MAGIC_BUFFER = $BA51C256
#MAGIC_CLEAR  = $00FF00FF

;- AUDIO OBJ

Structure AUDIO_OBJ
 initialized.i
 *btSounds
 *btBuffers
 fpCallBack_Error.CallBack_Error 
EndStructure : Global AUDIO.AUDIO_OBJ : InitAudioObj()

Macro FRAMES_TO_MILLISECONDS (frames, samplerate)
 (1000 * frames / samplerate)
EndMacro

Macro FRAMES_TO_BYTES (frames, bits, channels)
 (frames * (bits/8) * channels)
EndMacro

Macro BYTES_TO_FRAMES (bytes, bits, channels)
 (bytes / (bits/8) / channels)
EndMacro

Macro HERE()
 " [" + #PB_Compiler_Filename + ", " + Str(#PB_Compiler_Line) + "]"
EndMacro

Macro CALLBACK_ERROR (source, desc, here = "")
 If AUDIO\fpCallBack_Error 
    AUDIO\fpCallBack_Error(source, desc + here)
 EndIf 
EndMacro

Macro LSF_ERROR (sf)
 LSF_CheckError (sf, HERE())
EndMacro

Macro AL_ERROR()
 OAL_CheckError (HERE())
EndMacro

Macro ALC_ERROR (device)
 OAL_ContextCheckError (device, HERE())
EndMacro

;- * PRIVATE *

Procedure.i LSF_CheckError (sf, here$)
 Protected err = sf_error(sf)
 Protected *p, err$
 
 If err <> #SF_ERR_NO_ERROR        
    *p = sf_error_number(err) ; convert the  internal error enumerations into text strings
    
    If *p
        err$ = PeekS(*p, -1, #PB_UTF8)
    Else
        err$ = "#" + Str(err)
    EndIf
    
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, err$, here$)
 EndIf
 
 ProcedureReturn err
EndProcedure

Procedure.i OAL_CheckError (here$)
 Protected err = alGetError()
 
 If err <> #AL_NO_ERROR
    Select err
        Case #AL_INVALID_NAME
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#AL_INVALID_NAME", here$)
        Case #AL_INVALID_ENUM
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#AL_INVALID_ENUM", here$)
        Case #AL_INVALID_VALUE
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#AL_INVALID_VALUE", here$)
        Case #AL_INVALID_OPERATION
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#AL_INVALID_OPERATION", here$)
        Case #AL_OUT_OF_MEMORY
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#AL_OUT_OF_MEMORY", here$)
     EndSelect
 EndIf
     
 ProcedureReturn err
EndProcedure

Procedure.i OAL_ContextCheckError (device, here$)
 Protected err = alcGetError(device)
 
 If err <> #ALC_NO_ERROR
     Select err
        Case #ALC_INVALID_DEVICE
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#ALC_INVALID_DEVICE", here$)
        Case #ALC_INVALID_CONTEXT
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#ALC_INVALID_CONTEXT", here$)
        Case #ALC_INVALID_ENUM
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#ALC_INVALID_ENUM", here$)
        Case #ALC_INVALID_VALUE        
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#ALC_INVALID_VALUE", here$)
        Case #ALC_OUT_OF_MEMORY
            CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "#ALC_OUT_OF_MEMORY", here$)
     EndSelect
 EndIf
   
 ProcedureReturn err
EndProcedure

Procedure.i PopulateDeviceList (*p, Array devices$(1))
 Protected i, l, count
 
 While *p
    i = count     
    
    count + 1    
    ReDim devices$(i)
    
    devices$(i) = PeekS(*p, -1, #PB_UTF8)    
    l = Len(devices$(i))
    *p + l + 1
    
    If PeekB(*p) = 0
        Break
    EndIf       
 Wend
 
 ProcedureReturn count
EndProcedure

Procedure InitAudioObj() 
 AUDIO\initialized = 0
 AUDIO\fpCallBack_Error = 0
 AUDIO\btSounds = SBBT::New(#PB_Integer)
 AUDIO\btBuffers = SBBT::New(#PB_Integer)
EndProcedure 

;- Virtual I/O

ProcedureC.q cb_get_filelen (*user_data)
 Protected *vud.VirtualUserData = *user_data
 ProcedureReturn *vud\length
EndProcedure

ProcedureC.q cb_seek (offset.q, whence, *user_data)
 Protected *vud.VirtualUserData = *user_data

 Select whence
    Case #SEEK_CUR
        *vud\fp + offset
    Case #SEEK_SET
        *vud\fp = *vud\start + offset
    Case #SEEK_END
        *vud\fp = (*vud\start + *vud\length - 1) + offset
 EndSelect
 
 ProcedureReturn (*vud\fp - *vud\start)
EndProcedure

ProcedureC.q cb_read (*ptr, count.q, *user_data)
 Protected *vud.VirtualUserData = *user_data
 Protected *end = *vud\start + *vud\length - 1
 Protected length
 
 If (*vud\fp + count - 1) <= *end
    length = count
 Else
    length = *end - *vud\fp + 1
 EndIf
 
 CopyMemory (*vud\fp, *ptr, length)
 
 *vud\fp + length
 
 ProcedureReturn length
EndProcedure

ProcedureC.q cb_tell (*user_data)
 Protected *vud.VirtualUserData = *user_data
 ProcedureReturn (*vud\fp - *vud\start)
EndProcedure

;- * PUBLIC *

Procedure RegisterErrorCallBack (*fp)
;> Registers a callback to get runtime error messages from the library.
; Should be called before Init().

 AUDIO\fpCallBack_Error = *fp
EndProcedure

Procedure.i Init()
;> Initialize the library. 
; Returns 1 on success and 0 if failed.
; It's recommended but not required to call RegisterErrorCallBack() before this.

 If AUDIO\initialized 
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "AUDIO has already been initialized.", HERE()) 
    ProcedureReturn 0
 EndIf
 
 If openal_load::Load() <> openal_load::#LOAD_OK
    CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "Error importing the OpenAL Soft library.", HERE()) 
    Goto exit
 EndIf   

 If libsndfile_load::Load() <> libsndfile_load::#LOAD_OK
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Error importing the LibSndFile library.", HERE()) 
    Goto exit
 EndIf   
 
 AUDIO\initialized = 1
 
 ProcedureReturn 1
 
exit:
 Shutdown()
 
 ProcedureReturn 0
EndProcedure

Procedure Shutdown()
;> Shutdown the library.
; You should always call CloseDevice() before invoking Shutdown().

 AUDIO\initialized = 0
 
 SBBT::Free(AUDIO\btSounds)
 SBBT::Free(AUDIO\btBuffers)

 libsndfile_load::Shutdown()
 openal_load::Shutdown()
EndProcedure

Procedure.s GetVersion()
;> Returns a string representing the Audio version.
 
 Protected s$
 
 ; Audio version
 
 s$ = "AUDIO " + Str(#AUDIO_MAJ) + "." + Str(#AUDIO_MIN) + "." + Str(#AUDIO_REV)
 
 CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
 s$ + " x86"
 CompilerElse   
 s$ + " x64"
 CompilerEndIf 
 
 CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
  s$ + " Windows" 
 CompilerEndIf
 
 CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
  s$ + " Linux" 
 CompilerEndIf
  
 CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)
 s$ + " ASM"  
 CompilerElse
 s$ + " gcc"
 CompilerEndIf

 CompilerIf (#PB_Compiler_Optimizer)
 s$ + " (Optimizer ON)"  
 CompilerEndIf
 
 s$ + " (PB " + Str(#PB_Compiler_Version / 100) + "." + str::PadLeft(Str(#PB_Compiler_Version % 100),2,"0") + ")"
   
 ProcedureReturn s$
EndProcedure

Procedure.s GetLibSndFileVersion()
;> Returns a string representing the version of the LibSndFile support library.

 Protected s$
 
 Dim buffer.a(64)
 
 Protected len = sf_command (#Null, #SFC_GET_LIB_VERSION, @buffer(), ArraySize(buffer())) 
 
 If len 
    s$ = PeekS(@buffer(), len, #PB_UTF8)
 EndIf
   
 ProcedureReturn s$
EndProcedure

Procedure.s GetOpenALVersion()
;> Returns a string representing the version of the OpenAL support library.

 Protected s$, *p1, *p2, device, context 
 
 If alcGetCurrentContext() = #Null
 
    ; open default device 
    device = alcOpenDevice(#Null$)
    
    If device    
        ; creates rendering context
        context = alcCreateContext(device, #Null)
          
        ; and makes it current 
        If alcMakeContextCurrent(context)
            *p1 = alGetString(#AL_RENDERER)
            *p2 = alGetString(#AL_VERSION)
        EndIf
        
        alcDestroyContext(context)
     
        alcCloseDevice(device)    
    EndIf
 Else 
    *p1 = alGetString(#AL_RENDERER)
    *p2 = alGetString(#AL_VERSION)    
 EndIf
 
 If *p1 And *p2
    s$ = PeekS(*p1, -1, #PB_UTF8) + " " + PeekS(*p2, -1, #PB_UTF8)
 EndIf
 
 ProcedureReturn s$
EndProcedure

Procedure.s GetDefaultDeviceName()
;> Returns the string identifying the default playback device.

 Protected *p, s$
 If alcIsExtensionPresent(#Null, "ALC_ENUMERATE_ALL_EXT")
    *p = alcGetString(#Null, #ALC_DEFAULT_ALL_DEVICES_SPECIFIER) 
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)
    EndIf
 Else
    *p = alcGetString(#Null, #ALC_DEFAULT_DEVICE_SPECIFIER) 
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)
    EndIf
 EndIf
 
 ProcedureReturn s$
EndProcedure

Procedure.i GetAllDevicesNames (Array devices$(1))
;> Populates an array of strings identifying all the available playback devices.
; Returns the number of strings.

 Protected *p, s$, count
 
 ; enumerates available playback devices 
 
 If alcIsExtensionPresent(#Null, "ALC_ENUMERATE_ALL_EXT") 
    *p = alcGetString(#Null, #ALC_ALL_DEVICES_SPECIFIER)
    If *p
        count = PopulateDeviceList(*p, devices$())
    EndIf
 Else
    *p = alcGetString(#Null, #ALC_DEVICE_SPECIFIER)
    If *p
        count = PopulateDeviceList(*p, devices$())
    EndIf 
 EndIf
 
 ProcedureReturn count
EndProcedure

Procedure.s GetCurrentDeviceName()
;> Returns the string identifying the device associated to the current context.
; Returns "" if there is no current device.

 Protected s$, *p
 Protected device = GetCurrentDevice()
 
 If device  
    ALC_ERROR(device)
    
    If alcIsExtensionPresent(#Null, "ALC_ENUMERATE_ALL_EXT")     
        *p = alcGetString(device, #ALC_ALL_DEVICES_SPECIFIER)
    Else
        *p = alcGetString(device, #ALC_DEVICE_SPECIFIER)
    EndIf
    ALC_ERROR(device)
    
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)
    EndIf  
 EndIf
  
 ProcedureReturn s$
EndProcedure

Procedure.i OpenDevice (device$ = #Null$)
;> Open the specified playback device using its name or default one if the name is omitted.

; Returns the handle of the device or 0 in case of failure.

 Protected device, context 
 
 device = alcOpenDevice(device$) 
 ALC_ERROR(device)
  
 If device = 0 : Goto exit : EndIf
    
 context = alcCreateContext(device, #Null) 
 ALC_ERROR(device)
 
 If context = 0
    CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "Error creating a context.", HERE()) 
    Goto exit
 EndIf
    
 If alcMakeContextCurrent(context) = #False  
    CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "Error making the context current.", HERE()) 
    Goto exit
 EndIf
       
 ProcedureReturn device
 
 exit:
 
 If context
    alcMakeContextCurrent(#Null)                
    alcDestroyContext(context)
 EndIf
 
 If device
    alcCloseDevice(device)   
 EndIf
 
 If device$
    CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "Error opening the device: " + device$, HERE()) 
 Else
    CALLBACK_ERROR(#SOURCE_ERROR_OPENAL$, "Error opening the default device.", HERE()) 
 EndIf

 ProcedureReturn 0
EndProcedure

Procedure.i GetCurrentDevice()
;> Returns the handle of the playback device associated to the current context.

; Returns 0 if there is no current context

 Protected device, context
 
 context = alcGetCurrentContext()
 
 If context 
    device = alcGetContextsDevice(context)
    ALC_ERROR(device)
 EndIf
 
 ProcedureReturn device 
EndProcedure

Procedure CloseDevice (device)
;> Close the specified playback device and destroys the current context, if any.

 Protected i 
 Protected context
 Protected soundsCount, buffersCount

 If device
    soundsCount = SBBT::Count(AUDIO\btSounds)
    buffersCount = SBBT::Count(AUDIO\btBuffers)
  
     If soundsCount
        Dim sounds (soundsCount - 1)
        
        SBBT::EnumStart(AUDIO\btSounds)    
        i = 0
        
        While SBBT::EnumNext(AUDIO\btSounds)
            sounds(i) = SBBT::GetKey(AUDIO\btSounds)
            i + 1
        Wend
        
        SBBT::EnumEnd(AUDIO\btSounds)        
     EndIf
     
     If buffersCount
        Dim buffers (buffersCount - 1)
        
        SBBT::EnumStart(AUDIO\btBuffers)    
        i = 0
         
        While SBBT::EnumNext(AUDIO\btBuffers)
            buffers(i) = SBBT::GetKey(AUDIO\btBuffers)
            i + 1
        Wend
         
        SBBT::EnumEnd(AUDIO\btBuffers)        
     EndIf
    
     For i = 0 To soundsCount - 1
        DestroySound(sounds(i))
     Next
     
     For i = 0 To buffersCount - 1
        DestroyBuffer(buffers(i))
     Next

     ; and now closes the device 
     
     ALC_ERROR(device)
                
     context = alcGetCurrentContext()
     ALC_ERROR(device)
            
     If context                
        alcMakeContextCurrent(#Null)
        ALC_ERROR(device)
            
        alcDestroyContext(context)
        ALC_ERROR(device)
     EndIf
        
     alcCloseDevice(device) 
 EndIf 
EndProcedure

Procedure.i GetSoundFileInfo (file$, *sfi.SoundFileInfo)
;> Retrieves some info about the specified aound file and fills the passed structure with them.
; Returns 0 in case of error.
 
 Protected fmt_info.SF_FORMAT_INFO
 Protected sf_info.SF_INFO
 Protected srcMajFmt, srcSubFmt
 
 Protected sf = sf_open (file$, #SFM_READ, @sf_info)
 
 If sf        
    *sfi\channels = sf_info\channels
    *sfi\samplerate = sf_info\samplerate
    *sfi\frames = sf_info\frames
    *sfi\milliseconds = FRAMES_TO_MILLISECONDS (*sfi\frames, *sfi\samplerate)
    *sfi\bytes = FRAMES_TO_BYTES(*sfi\frames, 16, *sfi\channels)
    
    srcMajFmt = sf_info\format & #SF_FORMAT_TYPEMASK    
    srcSubFmt = sf_info\format & #SF_FORMAT_SUBMASK

    fmt_info\format = srcMajFmt    
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The file major format cannot be determined for " + file$, HERE()) 
        *sfi\majFmt$ = "Unknown"
    Else    
        *sfi\majFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for major format
    EndIf    
    
    fmt_info\format = srcSubFmt
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The file sub-format cannot be determined for " + file$, HERE()) 
        *sfi\subFmt$= "Unknown"
    Else    
        *sfi\subFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for subformat
    EndIf    
             
    sf_close(sf)
    
    ProcedureReturn 1
 Else
    Protected *p, s$
    
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "File error : " + file$, HERE()) 
    
    *p = sf_strerror(#Null) ; retrieve a more specific error description
        
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)        
        s$ = ReplaceString(s$, #CRLF$, "")
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, s$, HERE()) 
    EndIf
     
    ProcedureReturn 0
 EndIf
EndProcedure

Procedure.i CreateBufferFromMemory (bits, samplerate, channels, *data, dataSize)
; Creates an audio buffer from a region of memory filled with raw audio data and returns its handle.
; Both 8 and 16 bits per sample are supported when using this function.

 Protected *b.AudioBuffer

 ASSERT(*data) 
 ASSERT(dataSize)
 
 If bits <> 8 And bits <> 16
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Only mono or stereo audio file are supported.", HERE()) 
    Goto exit
 EndIf
 
 If channels < 1 Or channels > 2
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Only mono or stereo audio file are supported.", HERE()) 
    Goto exit
 EndIf
 
 *b = AllocateStructure(AudioBuffer)
 ASSERT(*b)

 *b\magic = #MAGIC_BUFFER
        
 *b\channels = channels
 *b\samplerate = samplerate
 *b\length = dataSize / (bits/8) / channels
 *b\bytes = dataSize

 *b\srcMajFmt$ = "RAW PCM"
 *b\srcMajFmt = #SF_FORMAT_RAW
 
 If channels = 1
    If bits = 8
        *b\audioFormat = #AL_FORMAT_MONO8
        *b\srcSubFmt = #SF_FORMAT_PCM_U8
        *b\srcSubFmt$ = "Unsigned 8 bit PCM"
    Else
        *b\audioFormat = #AL_FORMAT_MONO16
        *b\srcSubFmt = #SF_FORMAT_PCM_16
        *b\srcSubFmt$ = "Signed 16 bit PCM"
    EndIf
 Else
     If bits = 8
        *b\audioFormat = #AL_FORMAT_STEREO8
        *b\srcSubFmt = #SF_FORMAT_PCM_U8
        *b\srcSubFmt$ = "Unsigned 8 bit PCM"
    Else
        *b\audioFormat = #AL_FORMAT_STEREO16
        *b\srcSubFmt = #SF_FORMAT_PCM_16 
        *b\srcSubFmt$ = "Signed 16 bit PCM"
    EndIf        
 EndIf 
 
 Protected ALBuffer
                
 alGenBuffers(1, @ALBuffer)
 If AL_ERROR() : Goto exit : EndIf
    
 *b\ALBuffer = ALBuffer
 
 ; fill the buffer with audio data        
 alBufferData(*b\ALBuffer, *b\audioFormat, *data, dataSize, *b\samplerate)
 If AL_ERROR() : Goto exit : EndIf
 
 If SBBT::Insert(AUDIO\btBuffers, *b) = 0    
    CALLBACK_ERROR (#SOURCE_ERROR_AUDIO$, "Error storing the buffer handle in the BTree.")
    Goto exit
 EndIf
                  
 ProcedureReturn *b
 
exit:

 If *b : FreeStructure(*b) : EndIf  
 
 If alIsBuffer(ALBuffer) : alDeleteBuffers(1, @ALBuffer) : EndIf

 ProcedureReturn 0
EndProcedure

Procedure.i CreateBufferFromMemoryFile (*data, dataSize)
;> Creates an audio buffer from the sound file stored in memory and returns its handle.
; Returns 0 in case of error.
 
 Protected fmt_info.SF_FORMAT_INFO
 Protected sf_info.SF_INFO
 Protected *b.AudioBuffer

 ASSERT(*data) 
 ASSERT(dataSize)
 
 Protected vio.SF_VIRTUAL_IO
 vio\cb_get_filelen = @cb_get_filelen()
 vio\cb_seek = @cb_seek()
 vio\cb_read = @cb_read()
 vio\cb_write = #Null 
 vio\cb_tell = @cb_tell()
 
 Protected vud.VirtualUserData
 vud\start = *data
 vud\length = dataSize
 vud\fp = vud\start
 
 Protected sf = sf_open_virtual (@vio, #SFM_READ, @sf_info, @vud)
 LSF_ERROR(sf)
 
 If sf
    *b = AllocateStructure(AudioBuffer)
    ASSERT(*b)
            
    *b\magic = #MAGIC_BUFFER
        
    *b\channels = sf_info\channels
    *b\samplerate = sf_info\samplerate
    *b\length = sf_info\frames
    *b\bytes = FRAMES_TO_BYTES(*b\length, 16, *b\channels)
    
    *b\srcMajFmt = sf_info\format & #SF_FORMAT_TYPEMASK    
    *b\srcSubFmt = sf_info\format & #SF_FORMAT_SUBMASK
    
    fmt_info\format = *b\srcMajFmt    
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The major format cannot be determined for the virtual file", HERE()) 
        Goto exit
    EndIf    
    *b\srcMajFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for major format
    
    fmt_info\format = *b\srcSubFmt
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The sub-format cannot be determined for the virtual file", HERE()) 
        Goto exit
    EndIf    
    *b\srcSubFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for subformat
        
    If *b\channels < 1 Or *b\channels > 2
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Only mono or stereo audio file are supported.", HERE()) 
        Goto exit
    EndIf
    
    If *b\channels = 1
        *b\audioFormat = #AL_FORMAT_MONO16
    Else
        *b\audioFormat = #AL_FORMAT_STEREO16
    EndIf
        
    Protected ALBuffer, *membuf, bufSize, framesRead
                
    alGenBuffers(1, @ALBuffer)
    If AL_ERROR() : Goto exit : EndIf
    
    *b\ALBuffer = ALBuffer
    
    bufSize = 2 * (*b\channels) * (*b\length) ; 16 bit samples * channels * frames
    
    *membuf = AllocateMemory(bufSize)
    ASSERT(*membuf)
    
    framesRead = sf_readf_short(sf, *membuf, *b\length) ; samples are converted to 16 bits upon reading
    LSF_ERROR(sf)
    ASSERT(framesRead = *b\length)
    
    ; fill the buffer with audio data 
         
    alBufferData(*b\ALBuffer, *b\audioFormat, *membuf, bufSize, *b\samplerate)
    If AL_ERROR() : Goto exit : EndIf    
                     

    If SBBT::Insert(AUDIO\btBuffers, *b) = 0    
        CALLBACK_ERROR (#SOURCE_ERROR_AUDIO$, "Error storing the buffer handle in the BTree.")
        Goto exit
    EndIf
    
    sf_close(sf)
 Else
    Protected *p, s$
    
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Virtual I/O error", HERE()) 
    
    *p = sf_strerror(#Null) ; retrieve a more specific error description
        
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)        
        s$ = ReplaceString(s$, #CRLF$, "")        
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, s$, HERE()) 
    EndIf
    
    Goto exit
 EndIf
 
 ProcedureReturn *b
 
exit:

 If *b : FreeStructure(*b) : EndIf  
 
 If alIsBuffer(ALBuffer) : alDeleteBuffers(1, @ALBuffer) : EndIf

 If *membuf : FreeMemory(*membuf) : EndIf
 
 If sf : sf_close(sf) : EndIf  

 ProcedureReturn 0

EndProcedure

Procedure.i CreateBufferFromFile (file$)
;> Creates an audio buffer from the sound file and returns its handle.
; Load any of the supported audio formats in mono or stereo and converts any sample format to 16 bits for its internal use.
; Returns 0 in case of error.
 
 Protected fmt_info.SF_FORMAT_INFO
 Protected sf_info.SF_INFO
 Protected *b.AudioBuffer
 
 Protected sf = sf_open (file$, #SFM_READ, @sf_info)
 LSF_ERROR(sf)
 
 If sf
    *b = AllocateStructure(AudioBuffer)
    ASSERT(*b)
            
    *b\magic = #MAGIC_BUFFER
        
    *b\channels = sf_info\channels
    *b\samplerate = sf_info\samplerate
    *b\length = sf_info\frames
    *b\bytes = FRAMES_TO_BYTES(*b\length, 16, *b\channels)
    
    *b\srcMajFmt = sf_info\format & #SF_FORMAT_TYPEMASK    
    *b\srcSubFmt = sf_info\format & #SF_FORMAT_SUBMASK
    
    fmt_info\format = *b\srcMajFmt    
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The file major format cannot be determined for " + file$, HERE()) 
        Goto exit
    EndIf    
    *b\srcMajFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for major format
    
    fmt_info\format = *b\srcSubFmt
    If sf_command (#Null, #SFC_GET_FORMAT_INFO, @fmt_info, SizeOf (SF_FORMAT_INFO)) <> 0
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "The file sub-format cannot be determined for " + file$, HERE()) 
        Goto exit
    EndIf    
    *b\srcSubFmt$ = PeekS(fmt_info\name, -1, #PB_UTF8) ; get string for subformat
        
    If *b\channels < 1 Or *b\channels > 2
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "Only mono or stereo audio file are supported.", HERE()) 
        Goto exit
    EndIf
    
    If *b\channels = 1
        *b\audioFormat = #AL_FORMAT_MONO16
    Else
        *b\audioFormat = #AL_FORMAT_STEREO16
    EndIf
        
    Protected ALBuffer, *membuf, bufSize, framesRead
                
    alGenBuffers(1, @ALBuffer)
    If AL_ERROR() : Goto exit : EndIf
    
    *b\ALBuffer = ALBuffer
    
    bufSize = 2 * (*b\channels) * (*b\length) ; 16 bit samples * channels * frames
    
    *membuf = AllocateMemory(bufSize)
    ASSERT(*membuf)
    
    framesRead = sf_readf_short(sf, *membuf, *b\length) ; samples are converted to 16 bits upon reading
    LSF_ERROR(sf)
    ASSERT(framesRead = *b\length)
    
    ; fill the buffer with audio data 
         
    alBufferData(*b\ALBuffer, *b\audioFormat, *membuf, bufSize, *b\samplerate)
    If AL_ERROR() : Goto exit : EndIf    
                     

    If SBBT::Insert(AUDIO\btBuffers, *b) = 0    
        CALLBACK_ERROR (#SOURCE_ERROR_AUDIO$, "Error storing the buffer handle in the BTree.")
        Goto exit
    EndIf
    
    sf_close(sf)
 Else
    Protected *p, s$
    
    CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, "File error : " + file$, HERE()) 
    
    *p = sf_strerror(#Null) ; retrieve a more specific error description
        
    If *p
        s$ = PeekS(*p, -1, #PB_UTF8)        
        s$ = ReplaceString(s$, #CRLF$, "")        
        CALLBACK_ERROR(#SOURCE_ERROR_LIBSNDFILE$, s$, HERE()) 
    EndIf
    
    Goto exit
 EndIf
 
 ProcedureReturn *b
 
exit:

 If *b : FreeStructure(*b) : EndIf  
 
 If alIsBuffer(ALBuffer) : alDeleteBuffers(1, @ALBuffer) : EndIf

 If *membuf : FreeMemory(*membuf) : EndIf
 
 If sf : sf_close(sf) : EndIf  

 ProcedureReturn 0

EndProcedure

Procedure.i IsBufferBound (buffer)
; Returns 0 if not bound to a sound, else the number of bindings currently active.

 Protected *b.AudioBuffer = buffer
 ASSERT (*b And *b\magic = #MAGIC_BUFFER)
 
 ProcedureReturn *b\bindings
EndProcedure

Procedure.i IsSoundBound (sound)
; Returns 0 if not bound to a buffer, else the handle of the buffer.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)

 ProcedureReturn *s\buffer
EndProcedure

Procedure.i CreateSound() 
 Protected *s.SoundHandle
  
 *s = AllocateStructure(SoundHandle)
 ASSERT(*s)
 
 *s\magic = #MAGIC_SOUND
 
 *s\buffer = #Null
           
 Protected ALSource
        
 alGenSources(1, @ALSource)
 alSourcef(ALSource, #AL_PITCH, 1.0)
 alSourcef(ALSource, #AL_GAIN, 1.0)
 alSource3f(ALSource, #AL_POSITION, 0, 0, 0)
 alSource3f(ALSource, #AL_VELOCITY, 0, 0, 0)
 If AL_ERROR(): Goto exit : EndIf

 *s\ALSource = ALSource
 
 If SBBT::Insert(AUDIO\btSounds, *s) = 0    
    CALLBACK_ERROR (#SOURCE_ERROR_AUDIO$, "Error storing the sound handle in the BTree.")
    Goto exit
 EndIf
    
 ProcedureReturn *s
 
exit:

 If *s : FreeStructure(*s) : EndIf  

 If alIsSource(ALSource) : alDeleteSources(1, @ALSource) : EndIf
 
 ProcedureReturn 0
EndProcedure

Procedure.i CreateSoundFromBuffer (buffer)
;> Create a sound from the passed audio buffer and returns its handle.
; Returns 0 in case of error.
 
 Protected *b.AudioBuffer = buffer
 ASSERT (*b And *b\magic = #MAGIC_BUFFER)
 
 Protected *s.SoundHandle
  
 If *b = #Null Or *b\ALBuffer = 0 Or alIsBuffer(*b\ALBuffer) = #AL_FALSE
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "The passed OpenAL buffer is invalid.", HERE())
    Goto exit
 EndIf
    
 *s = AllocateStructure(SoundHandle)
 ASSERT(*s)
 
 *s\magic = #MAGIC_SOUND
 
 *s\buffer = *b
           
 Protected ALSource
        
 alGenSources(1, @ALSource)
 alSourcef(ALSource, #AL_PITCH, 1.0)
 alSourcef(ALSource, #AL_GAIN, 1.0)
 alSource3f(ALSource, #AL_POSITION, 0, 0, 0)
 alSource3f(ALSource, #AL_VELOCITY, 0, 0, 0)
 If AL_ERROR(): Goto exit : EndIf

 *s\ALSource = ALSource
    
 ; binds the buffer to the source
 alSourcei(*s\ALSource, #AL_BUFFER, *s\buffer\ALBuffer)
 If AL_ERROR() : Goto exit : EndIf
 
 *s\buffer\bindings + 1
 
 If SBBT::Insert(AUDIO\btSounds, *s) = 0    
    CALLBACK_ERROR (#SOURCE_ERROR_AUDIO$, "Error storing the sound handle in the BTree.")
    Goto exit
 EndIf
 
 ProcedureReturn *s
 
exit:

 If *s : FreeStructure(*s) : EndIf  

 If alIsSource(ALSource) : alDeleteSources(1, @ALSource) : EndIf
 
 ProcedureReturn 0
EndProcedure

Procedure.i BindBuffer (sound, buffer)
;> Bind the passed audio buffer to the source and unbinds the previously bound if any.
; This function must be called when the sound is not playing or paused, else the binding of the new buffer will fail.
; Returns 0 in case of error.
 
 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 
 Protected *b.AudioBuffer = buffer
 ASSERT_START
  CompilerIf (#PB_Compiler_Debugger = 1)
    If *b And *b\magic <> #MAGIC_BUFFER
        ASSERT_FAIL()
    EndIf
  CompilerEndIf
 ASSERT_END
 
 ; test if the buffer *b is valid, but a #Null buffer is also OK and pass the test
 If *b And (*b\ALBuffer = 0 Or alIsBuffer(*b\ALBuffer) = #AL_FALSE)
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "The passed OpenAL buffer is invalid.", HERE()) 
    Goto exit
 EndIf
 
 Protected state
 
 alGetSourcei(*s\ALsource, #AL_SOURCE_STATE, @state)
 If AL_ERROR(): Goto exit : EndIf
 
 If state = #AL_PAUSED Or state = #AL_PLAYING
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "The sound is playing or paused, can't unbind the buffer.", HERE())
    Goto exit 
 EndIf
 
 If *s\buffer ; if the sound has a bound buffer
    ; unbind it
    alSourcei(*s\ALSource, #AL_BUFFER, #AL_NONE)
    If AL_ERROR() : Goto exit : EndIf
    *s\buffer\bindings - 1
 EndIf
 
 ; link the new passed buffer
 *s\buffer = *b ; it can be #Null if unbinding
              
 If *s\buffer ; if the new buffer is not #Null
     ; bind it
     alSourcei(*s\ALSource, #AL_BUFFER, *s\buffer\ALBuffer)
     If AL_ERROR() : Goto exit : EndIf     
     *s\buffer\bindings + 1
 EndIf
 
 ProcedureReturn 1
 
exit:

 ProcedureReturn 0
EndProcedure

Procedure DestroySound (sound)
;> Destroy a sound releasing its own resources.

; Note this function never destroys the associated buffer, simply decrements its bindings counter.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)

 *s\magic = #MAGIC_CLEAR

 alSourceStop(*s\ALSource)
 AL_ERROR()
 
 ; detach the buffer bound to the sound
 alSourcei(*s\ALSource, #AL_BUFFER, #AL_NONE)
 AL_ERROR()
 
 If *s\buffer
    *s\buffer\bindings - 1
 EndIf   
 
 ; destroy the source bound to the sound
 alDeleteSources(1, @*s\ALSource)
 AL_ERROR()

 If SBBT::Delete(AUDIO\btSounds, *s) = 0
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "Error deleting the sound handle from the BTree.", HERE())
 EndIf    
 
 ; destroy the sound object 
 FreeStructure(*s)

EndProcedure

Procedure DestroyBuffer (buffer)
;> Destroy a buffer releasing its own resource.

; Buffers which are attached to a source can not be deleted, so call this only when all the sounds using this buffer has been destroyed,
; else an error will be reported to the error callback and the buffer will be left untouched.

; You can use IsBufferBound() to check if the buffer is stil bound to a sound.

 Protected *b.AudioBuffer = buffer
 ASSERT (*b And *b\magic = #MAGIC_BUFFER)
 
 If *b\bindings = 0        
    *b\magic = #MAGIC_CLEAR
    
    ; destroy the buffer 
    alDeleteBuffers(1, @*b\ALBuffer)
    AL_ERROR()
    
    ; destroy the buffer object 
    FreeStructure(*b)
    
    If SBBT::Delete(AUDIO\btBuffers, *b) = 0
        CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "Error deleting the buffer handle from the BTree.", HERE())
    EndIf    
 Else
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "Some instances of the buffer are still bound.", HERE())
 EndIf  
EndProcedure

Procedure.i GetAudioDataSize (sound)
;> Returns the size in bytes of the audio data stored in memory for the sound.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 ProcedureReturn *s\buffer\bytes
EndProcedure

Procedure.s GetFormatString (sound)
;> Returns the audio format string of the loaded audio file.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 ProcedureReturn *s\buffer\srcMajFmt$
EndProcedure

Procedure.s GetSubFormatString (sound)
;> Returns the sub-audio format string of the loaded audio file.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 ProcedureReturn *s\buffer\srcSubFmt$
EndProcedure

Procedure.i GetChannels (sound)
;> Returns the number of channels of the sound (1 = mono, 2 = stereo).

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 ProcedureReturn *s\buffer\channels
EndProcedure

Procedure.i GetSampleRate (sound)
;> Returns the sample rate in Hz of the sound.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND) 
 ASSERT (*s\buffer)
 
 ProcedureReturn *s\buffer\samplerate
EndProcedure

Procedure.i GetLength (sound, format)
;> Returns the length of the sound expressed in milliseconds or frames.
; format: #Milliseconds or #Frames

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 Select format 
    Case #Milliseconds
        ProcedureReturn (1000 * *s\buffer\length) / *s\buffer\samplerate
    Case #Frames
        ProcedureReturn *s\buffer\length
    Default
        ASSERT_FAIL() ; wrong time format
 EndSelect
 
 ProcedureReturn 0
EndProcedure

Procedure SetLooping (sound, loop)
; Set the looping state for the specified sound.

; loop should be set to 0 or 1

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 alSourcei(*s\ALsource, #AL_LOOPING, Bool(loop))
 AL_ERROR() 
EndProcedure

Procedure.i GetState (sound)
;> Returns the current state of the sound.
; The possibile returned values are #Ready, #Playing, #Paused, #Stopped

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 Protected state, ret

 alGetSourcei(*s\ALsource, #AL_SOURCE_STATE, @state)
 If AL_ERROR(): Goto exit : EndIf
 
 Select state
    Case #AL_INITIAL
        ret = #Ready
    Case #AL_PLAYING
        ret = #Playing
    Case #AL_PAUSED
        ret = #Paused
    Case #AL_STOPPED
        ret = #Stopped
    Default
        ASSERT_FAIL() ; should never happen
        ret = 0
 EndSelect

 ProcedureReturn ret
  
 exit:
 
 ProcedureReturn 0
 
EndProcedure

Procedure.i GetPos (sound, format)
;> Returns the current position in milliseconds or frames for the specified sound.
; format: #Milliseconds or #Frames

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 Protected frames
 
 alGetSourcei(*s\ALSource, #AL_SAMPLE_OFFSET, @frames)
 If AL_ERROR(): Goto exit : EndIf
 
 Select format 
    Case #Milliseconds
        ProcedureReturn FRAMES_TO_MILLISECONDS (frames, *s\buffer\samplerate)
    Case #Frames
        ProcedureReturn (frames)
    Default
        ASSERT_FAIL() ; wrong time format
 EndSelect
 
 exit:
    ProcedureReturn 0   
EndProcedure

Procedure SetPos (sound, position, format)
;> Sets the sound current position in milliseconds or frames.

; format: #Milliseconds or #Frames
; if position is outside a valid range nothing happens

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 Protected frames
 
 Select format 
    Case #Milliseconds
        frames = (position / 1000.0) * (*s\buffer\samplerate)
    Case #Frames
        frames = position
    Default
        ASSERT_FAIL() ; wrong time format
 EndSelect
  
 If frames < 0 Or frames >= *s\buffer\length
    ProcedureReturn 
 EndIf
 
 alSourcei(*s\ALSource, #AL_SAMPLE_OFFSET, frames) 
 AL_ERROR()
 
 ProcedureReturn
 
EndProcedure

Procedure Play (sound, loop = #False)
;> Start playing the specified audio file.
; If loop = #True the state of the sound is set to infinite looping until explicitly stopped.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 If alIsBuffer(*s\buffer\ALBuffer) = #AL_FALSE
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "The associated OpenAL buffer is invalid.", HERE())
    ProcedureReturn 
 EndIf
 
 alSourcei(*s\ALSource, #AL_LOOPING, Bool(loop))
 AL_ERROR() 
 
 alSourcePlay(*s\ALSource)
 AL_ERROR()
EndProcedure

Procedure Pause (sound)
;> Pause the reproduction of the specified audio file.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)

 alSourcePause(*s\ALSource)
 AL_ERROR()
EndProcedure

Procedure Resume (sound)
;> Resume the reproduction of specified sound if it was paused, else do nothing.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 Protected state
 
 alGetSourcei(*s\ALSource, #AL_SOURCE_STATE, @state)
 AL_ERROR()

 If state = #AL_PAUSED  
    alSourcePlay(*s\ALSource)
    AL_ERROR()
 EndIf
EndProcedure 

Procedure Stop (sound)
;> Stop the reproduction of the specified audio file.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 ASSERT (*s\buffer)
 
 alSourceStop(*s\ALSource)
 AL_ERROR()

 alSourcei(*s\ALSource, #AL_LOOPING, 0)
 AL_ERROR()
EndProcedure

Procedure PlayArray (Array sounds(1))
;> Start playing the sounds listed in the array while guaranteeing synchronized operation.

 Protected *s.SoundHandle
 Protected i, count = ArraySize(sounds())

 Dim sources.l(count)

 For i = 0 To count 
    *s = sounds(i)
    ASSERT (*s And *s\magic = #MAGIC_SOUND)
    ASSERT (*s\buffer)
    
    sources(i) =  *s\ALSource    
 Next

 alSourcePlayv(count + 1, @sources())
 AL_ERROR()
EndProcedure

Procedure PauseArray (Array sounds(1))
;> Pause the reproduction of the sounds listed in the array while guaranteeing synchronized operation.

 Protected *s.SoundHandle
 Protected i, count = ArraySize(sounds())

 Dim sources.l(count)

 For i = 0 To count 
    *s = sounds(i)
    ASSERT (*s And *s\magic = #MAGIC_SOUND)
    ASSERT (*s\buffer)
      
    sources(i) =  *s\ALSource    
 Next

 alSourcePausev(count + 1, @sources())
 AL_ERROR()
EndProcedure

Procedure ResumeArray (Array sounds(1))
;> Resume the reproduction of the sounds listed in the array which are currently paused while guaranteeing synchronized operation.

 Protected *s.SoundHandle
 Protected i, count = ArraySize(sounds())
 Protected state, pausedCount

 Dim sources.l(count)

 pausedCount = 0
 
 For i = 0 To count 
    *s = sounds(i)
    ASSERT (*s And *s\magic = #MAGIC_SOUND)
    ASSERT (*s\buffer)

    alGetSourcei(*s\ALSource, #AL_SOURCE_STATE, @state)
    AL_ERROR()

    If state = #AL_PAUSED  
        sources(pausedCount) =  *s\ALSource
        pausedCount + 1
    EndIf      
 Next

 alSourcePlayv(pausedCount, @sources())
 AL_ERROR()
EndProcedure

Procedure StopArray (Array sounds(1))
;> Stop the reproduction of the sounds listed in the array while guaranteeing synchronized operation.

 Protected *s.SoundHandle
 Protected i, count = ArraySize(sounds())

 Dim sources.l(count)

 For i = 0 To count 
    *s = sounds(i)
    ASSERT (*s And *s\magic = #MAGIC_SOUND)
    ASSERT (*s\buffer)
      
    sources(i) =  *s\ALSource    
 Next

 alSourceStopv(count + 1, @sources())
 AL_ERROR()
EndProcedure

Procedure PauseAll()
;> Pause the reproduction of every sound currently playing.

 Protected soundsCount, state, pausedCount
 Protected *s.SoundHandle
   
 soundsCount = SBBT::Count(AUDIO\btSounds)
  
 If soundsCount
    Dim sources.l (soundsCount - 1)
        
    SBBT::EnumStart(AUDIO\btSounds)    
    pausedCount = 0
        
    While SBBT::EnumNext(AUDIO\btSounds)
        *s = SBBT::GetKey(AUDIO\btSounds)
        ASSERT (*s And *s\magic = #MAGIC_SOUND)
        
        alGetSourcei(*s\ALSource, #AL_SOURCE_STATE, @state)
        AL_ERROR()
        
        If state = #AL_PLAYING
            sources(pausedCount) = *s\ALSource
            pausedCount + 1
        EndIf
    Wend
    
    SBBT::EnumEnd(AUDIO\btSounds)
 EndIf

 alSourcePausev(pausedCount, @sources())
 AL_ERROR()
EndProcedure

Procedure ResumeAll()
;> Resume the reproduction of every sound currently paused.

 Protected soundsCount, state, pausedCount
 Protected *s.SoundHandle
  
 soundsCount = SBBT::Count(AUDIO\btSounds)
  
 If soundsCount
    Dim sources.l (soundsCount - 1)
        
    SBBT::EnumStart(AUDIO\btSounds)    
    pausedCount = 0
        
    While SBBT::EnumNext(AUDIO\btSounds)
        *s = SBBT::GetKey(AUDIO\btSounds)
        ASSERT (*s And *s\magic = #MAGIC_SOUND)
        
        alGetSourcei(*s\ALSource, #AL_SOURCE_STATE, @state)
        AL_ERROR()
        
        If state = #AL_PAUSED
            sources(pausedCount) = *s\ALSource
            pausedCount + 1
        EndIf
    Wend
    
    SBBT::EnumEnd(AUDIO\btSounds)
 EndIf

 alSourcePlayv(pausedCount, @sources())
 AL_ERROR()
EndProcedure

Procedure StopAll()
;> Stop every sound currently playing or paused.

 Protected soundsCount, state, i
 Protected *s.SoundHandle
   
 soundsCount = SBBT::Count(AUDIO\btSounds)
  
 If soundsCount
    Dim sources.l (soundsCount - 1)
        
    SBBT::EnumStart(AUDIO\btSounds)
    i = 0
        
    While SBBT::EnumNext(AUDIO\btSounds)
        *s = SBBT::GetKey(AUDIO\btSounds)
        ASSERT (*s And *s\magic = #MAGIC_SOUND)

        alGetSourcei(*s\ALSource, #AL_SOURCE_STATE, @state)
        AL_ERROR()
        
        If state = #AL_PLAYING Or state = #AL_PAUSED
            sources(i) = *s\ALSource
            i + 1
        EndIf
                        
        sources(i) = *s\ALSource        
    Wend
    
    SBBT::EnumEnd(AUDIO\btSounds)
 EndIf

 alSourceStopv(i, @sources())
 AL_ERROR()
EndProcedure

Procedure SetVolume (sound, volume.f)
;> Set the volume of the specified sound (from 0.0 to 1.0)
; The volume can actually be set higher then 1.0 but it may lowered during mixing to avoid clipping.

 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 
 If volume >= 0.0
     alSourcef(*s\ALSource, #AL_GAIN, volume)
     AL_ERROR()
 EndIf
EndProcedure

Procedure SetGlobalVolume (volume.f)
;> Set the global volume (from 0.0 to 1.0)
; The volume can actually be set higher then 1.0 but it may lowered during mixing to avoid clipping.

 If volume >= 0.0
     alListenerf(#AL_GAIN, volume)
     AL_ERROR()
 EndIf
EndProcedure

Procedure SetLocation (sound, *loc.SoundLocation)
 Protected *s.SoundHandle = sound
 ASSERT (*s And *s\magic = #MAGIC_SOUND)
 
 If *s\buffer\channels <> 1 
    CALLBACK_ERROR(#SOURCE_ERROR_AUDIO$, "SetLocation is supported only for mono audio.", HERE())
    ProcedureReturn 
 EndIf
 
EndProcedure

EndModule

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 32
; Markers = 64
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory