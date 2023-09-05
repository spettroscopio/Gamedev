EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure Main() 
 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion() 
 
 Protected device = audio::OpenDevice()
 
 Debug ""
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 Protected f1$ = "30-seconds.wav" 
 Protected b1 = audio::CreateBufferFromFile("../assets/" + f1$)
 Protected s1 = audio::CreateSoundFromBuffer(b1)
 
 Protected f2$ = "sonically.flac" 
 Protected b2 = audio::CreateBufferFromFile("../assets/" + f2$)
 Protected s2 = audio::CreateSoundFromBuffer(b2)

 Protected f3$ = "mono-16-bits.wav" 
 Protected b3 = audio::CreateBufferFromFile("../assets/" + f3$)
 Protected s3 = audio::CreateSoundFromBuffer(b3)
 
 Protected t1
 
 If s1 And s2 And s3 
    audio::SetVolume(s2, 0.3)
    audio::SetVolume(s3, 0.6)
     
    Protected l1 = audio::GetLength(s1, audio::#Milliseconds)
    
    audio::Play(s1)
    audio::Play(s2, #True)
    
    t1 = ElapsedMilliseconds()
        
    While audio::GetState(s1) = audio::#Playing
        If Random(1000) > 995
            If audio::GetState(s3) <> audio::#Playing
                audio::Play(s3)
            EndIf
        EndIf
        Delay(10)
    Wend
    
    audio::Stop(s2)
    
    While audio::GetState(s3) = audio::#Playing
        Delay(10)
    Wend
  
    audio::DestroySound(s1) : audio::DestroyBuffer(b1)
    audio::DestroySound(s2) : audio::DestroyBuffer(b2)
    audio::DestroySound(s3) : audio::DestroyBuffer(b3)
 EndIf

 audio::CloseDevice(device)
EndProcedure
 
audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Linux - x64)
; CursorPosition = 34
; FirstLine = 4
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory