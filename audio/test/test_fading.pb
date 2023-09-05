EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure


Procedure test08 (sound)
 Debug ""   
 Debug "Plays the sound looped, while rising and lowering the volume"
 Delay(1000)

 Protected time, delta, timerPrint, timerVolume
 Protected volume.f, inc.f

 Protected length = audio::GetLength(sound, audio::#Milliseconds) * 3

 audio::Play(sound, #True)

 timerPrint = ElapsedMilliseconds()
 timerVolume = timerPrint

 While delta < length                 
    If ElapsedMilliseconds() - timerVolume  >= 100 ; ms
        timerVolume = ElapsedMilliseconds() 
        inc + 0.01
        If inc > 1.0
            inc = 0.0
        EndIf
        volume = inc
        Debug volume
        ;volume = inc
        audio::SetVolume(sound, volume)
    EndIf
    
    If ElapsedMilliseconds() - timerPrint  >= 100 ; ms
        timerPrint = ElapsedMilliseconds() 
        ;Debug StrF(volume,2)
    EndIf
    
    delta = ElapsedMilliseconds() - time
 Wend
 
 audio::Stop(sound)
 
 Debug "Done."
EndProcedure

Procedure Main() 
 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion() 
 
 Protected device = audio::OpenDevice()
 
 Debug ""
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 Protected file$ = "sonically.flac" 
  
 Protected buffer = audio::CreateBufferFromFile("../assets/" + file$)
 
 If buffer
 
    Protected sound = audio::CreateSoundFromBuffer(buffer)
    
     If sound
 
        Debug file$ + " successfully opened"
        Debug ""
        
        Debug "Format             : " + audio::GetFormatString(sound)
        Debug "SubFormat          : " + audio::GetSubFormatString(sound)
        Debug "Channels           : " + audio::GetChannels(sound)
        Debug "Samplerate         : " + audio::GetSampleRate(sound)
        Debug "Length (frames)    : " + audio::GetLength(sound, audio::#Frames)
        Debug "Length (ms)        : " + audio::GetLength(sound, audio::#Milliseconds)
        Debug "Audio data (bytes) : " + audio::GetAudioDataSize(sound)
        Debug "State              : " + audio::GetState(sound)
        
        test08(sound)
    
    EndIf
 EndIf

 If sound  : audio::DestroySound(sound)   : EndIf 
 If buffer : audio::DestroyBuffer(buffer) : EndIf 

 audio::CloseDevice(device)
EndProcedure
 
audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 33
; FirstLine = 6
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory