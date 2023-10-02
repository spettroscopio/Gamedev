EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure GetFileStats (file$)
 Protected sfi.audio::SoundFileInfo
 
 If audio::GetSoundFileInfo("../assets/" + file$, @sfi)
    Debug file$ + " info retrieved"
    Debug ""
    
    Debug "Format             : " + sfi\majFmt$
    Debug "SubFormat          : " + sfi\subFmt$
    Debug "Channels           : " + sfi\channels
    Debug "Samplerate         : " + sfi\samplerate
    Debug "Length (frames)    : " + sfi\frames
    Debug "Length (ms)        : " + sfi\milliseconds
    Debug "Audio Data (bytes) : " + sfi\bytes
 EndIf
     
 Debug ""
EndProcedure

Procedure Main()
 Dim devices$(0)
 Protected i, count, device, sf
 Protected file$

 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion()

 Debug ""
 Debug "Default playback device: " + audio::GetDefaultDeviceName()    
 
 Debug ""
 Debug "Available playback devices:"

 count = audio::GetAllDevicesNames(devices$())

 For i = 0 To count - 1
    Debug devices$(i)
 Next
 
 device = audio::OpenDevice()
 
 Debug ""
 Debug "Opened device handle: " + Str(device)
 Debug "Current device handle: " + audio::GetCurrentDevice()
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 file$ = "purebasic-mono-08-bits.wav" 
 GetFileStats (file$)

 file$ = "purebasic-mono-16-bits.wav" 
 GetFileStats (file$)

 file$ = "stereo-24-bits.wav" 
 GetFileStats (file$)

 file$ = "blues.mp3" 
 GetFileStats (file$)

 file$ = "doobie.ogg" 
 GetFileStats (file$)

 file$ = "sonically.flac" 
 GetFileStats (file$)

 file$ = "missing.wav" : Debug "Opening " + file$ ; this should generate an error
 GetFileStats (file$)
    
 file$ = "invalid.wav" :  Debug "Opening " + file$ ; this should generate an error
 GetFileStats (file$)
    
 audio::CloseDevice(device)
EndProcedure
 

audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 62
; FirstLine = 30
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory