EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure LoadAndPlay (file$)
 
 Protected buffer = audio::CreateBufferFromFile("../assets/" + file$)
 
 If buffer
 
    Protected sound = audio::CreateSoundFromBuffer(buffer)
    
     If sound
        Debug file$ + " successfully opened"
        Debug ""
        
        Debug "Format         : " + audio::GetFormatString(sound)
        Debug "SubFormat      : " + audio::GetSubFormatString(sound)
        Debug "Channels       : " + audio::GetChannels(sound)
        Debug "Samplerate     : " + audio::GetSampleRate(sound)
        Debug "Length (frames): " + audio::GetLength(sound, audio::#Frames)
        Debug "Length (ms)    : " + audio::GetLength(sound, audio::#Milliseconds)
        Debug "State          : " + audio::GetState(sound)
        Debug "Audio Data     : " + audio::GetAudioDataSize(sound)
        
        Debug ""
        Debug "Playing ..."
        
        audio::Play(sound)
                    
        While audio::GetState(sound) = audio::#Playing
            Delay(100)
        Wend
            
     EndIf
 EndIf

 If sound  : audio::DestroySound(sound)   : EndIf
 
 If buffer : audio::DestroyBuffer(buffer) : EndIf 
       
 Debug ""
EndProcedure

Procedure Main()

 Protected device
 Protected file$

 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion() 
 
 device = audio::OpenDevice()
 
 Debug ""
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 file$ = "purebasic-mono-08-bits.wav" 
 LoadAndPlay (file$)

 file$ = "purebasic-mono-16-bits.wav" 
 LoadAndPlay (file$)
 
 file$ = "stereo-24-bits.wav" 
 LoadAndPlay (file$)

 file$ = "sonically.flac" 
 LoadAndPlay (file$)

 file$ = "blues.mp3" 
 LoadAndPlay (file$)

 file$ = "doobie.ogg" 
 LoadAndPlay (file$)
 
 Debug "Done"
 
 audio::CloseDevice(device)
EndProcedure
 
audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 42
; FirstLine = 14
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory