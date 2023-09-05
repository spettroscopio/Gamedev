EnableExplicit

IncludeFile "../audio.pb"

UseModule openal

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure test01 (sound)
 Debug ""   
 Debug "Plays the sound with variable delays in the loop and jumping around"
 Delay(1000)
 
 Protected newPos
 Protected length = audio::GetLength(sound, audio::#Milliseconds)
 
 audio::Play(sound)
 
 While audio::GetStatus(sound) = audio::#Playing
 
     If Random(100) > 95
        newPos = Random(length)
        Debug "Jumping to: " + newpos  
        audio::SetPos(sound, newPos, audio::#Milliseconds)
    EndIf

    If Random(100) > 95
        audio::Pause(sound)
        Debug "Pausing... current position: " + audio::GetPos(sound, audio::#Milliseconds) 
        Delay(1500)
        Debug "Resuming ..."
        audio::Play(sound)
    EndIf
    
    Debug "Current position: " + audio::GetPos(sound, audio::#Milliseconds) 
        
    Delay(Random(500))
 Wend
     
 Debug "Exit position: " + audio::GetPos(sound, audio::#Milliseconds) 

 Debug "Done."
EndProcedure

Procedure Main() 
 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion() 
 
 Protected device = audio::OpenDevice()
 
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 Protected file$ = "30-seconds.wav"

 Protected sound = audio::LoadSoundFile("../assets/" + file$)
  
 If sound
    Debug file$ + " successfully opened"
    Debug ""
    
    Debug "Format         : " + audio::GetFormatString(sound)
    Debug "SubFormat      : " + audio::GetSubFormatString(sound)
    Debug "Channels       : " + audio::GetChannels(sound)
    Debug "Samplerate     : " + audio::GetSampleRate(sound)
    Debug "Length (frames): " + audio::GetLength(sound, audio::#Frames)
    Debug "Length (ms)    : " + audio::GetLength(sound, audio::#Milliseconds)
    Debug "Status         : " + audio::GetStatus(sound)
    Debug "Audio Data     : " + audio::GetAudioDataSize(sound)
    
    Protected i
    
    For i = 1 To 5
        Debug ""
        Debug "Test n." + i
        test01(sound)
    Next
    
    audio::DestroySound(sound)  
 EndIf

 audio::CloseDevice(device)
EndProcedure
 
audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 71
; FirstLine = 43
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory