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
             
 Dim sounds(2)
 Protected f1$ = "30-seconds.wav" 
 Protected b1 = audio::CreateBufferFromFile("../assets/" + f1$)
 Protected s1 = audio::CreateSoundFromBuffer(b1)
 
 Protected f2$ = "sonically.flac" 
 Protected b2 = audio::CreateBufferFromFile("../assets/" + f2$)
 Protected s2 = audio::CreateSoundFromBuffer(b2)

 Protected f3$ = "stereo-24-bits.wav" 
 Protected b3 = audio::CreateBufferFromFile("../assets/" + f3$)
 Protected s3 = audio::CreateSoundFromBuffer(b3)
 
 If s1 And s2 And s3     
    Debug "Playing three sound files at the same time"
    
    audio::SetVolume(s1, 1.0)
    audio::SetVolume(s2, 0.5)
    audio::SetVolume(s3, 0.5)
    
    audio::SetLooping(s2, #True)
    audio::SetLooping(s3, #True)
    
    sounds(0) = s1
    sounds(1) = s2
    sounds(2) = s3
    
    audio::PlayArray(sounds())
 
    Protected j
           
    For j = 1 To 4
        Delay(5000)
            
        Debug "Pause ..."   
        ; alternatively you may use audio::PauseAll() in this example       
        audio::PauseArray(sounds())        
        
        Delay(2000)
            
        Debug "Resume"        
        ; alternatively you may use  audio::ResumeAll() in this example                
        audio::ResumeArray(sounds())        
    Next
    
    While audio::GetState(s1) = audio::#Playing
        Delay(10)
    Wend
    
    audio::StopAll()
  
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
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 80
; FirstLine = 21
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory