EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure


Procedure test (sound)
 Debug ""   
 Debug "Plays the sound looped, while rising and lowering the volume"
 Delay(1000)

 Protected time, delta, timerVolume, timerInterval = 250 ; ms
 Protected volume.f

 Protected length = audio::GetLength(sound, audio::#Milliseconds) * 3 ; three loops
 Protected inc.f  = 4.0 / (length / timerInterval) ; rise + fall + rise + fall

 audio::SetVolume(sound, 0.0)
 audio::Play(sound, #True)
 
 time = ElapsedMilliseconds()
 timerVolume = time
 
 While delta < length                 
    If ElapsedMilliseconds() - timerVolume  >= timerInterval
        timerVolume = ElapsedMilliseconds()         
        volume + inc
        If volume > 1.0 
            inc = -inc
            volume = 1.0
        EndIf
        If volume < 0.0 
            inc = -inc
            volume = 0.0
        EndIf
        
        Debug "vol = " + StrF(volume, 3)
        audio::SetVolume(sound, volume)
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
        
        test(sound)
    
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
; CursorPosition = 14
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory