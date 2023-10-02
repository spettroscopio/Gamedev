EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure


Procedure play (sound)

 Debug ""              
 Debug "Format             : " + audio::GetFormatString(sound)
 Debug "SubFormat          : " + audio::GetSubFormatString(sound)
 Debug "Channels           : " + audio::GetChannels(sound)
 Debug "Samplerate         : " + audio::GetSampleRate(sound)
 Debug "Length (frames)    : " + audio::GetLength(sound, audio::#Frames)
 Debug "Length (ms)        : " + audio::GetLength(sound, audio::#Milliseconds)
 Debug "Audio data (bytes) : " + audio::GetAudioDataSize(sound)
    
 Debug ""
 Debug "Play the sound with the buffer currently bound ..."
    
 audio::Play(sound)
                
 While audio::GetState(sound) = audio::#Playing
    Debug "Current position: " + audio::GetPos(sound, audio::#Milliseconds)
    Delay(100)
 Wend
                 
EndProcedure

Procedure test()
 
 Protected file$

 file$ = "purebasic-mono-16-bits.wav"
 Protected bufPureBasic = audio::CreateBufferFromFile("../assets/" + file$)
 
 file$ = "ping.wav"
 Protected bufPing = audio::CreateBufferFromFile("../assets/" + file$)

 Protected sound = audio::CreateSound()
  
 If bufPureBasic
    audio::BindBuffer(sound, bufPureBasic)
    play (sound) ; purebasic
 EndIf
 
 If bufPing
    audio::BindBuffer(sound, bufPing)
    play (sound) ; ping 
 EndIf

 If bufPureBasic
    audio::BindBuffer(sound, bufPureBasic)
    play (sound) ; purebasic
 EndIf
 
 If sound : audio::DestroySound(sound) : EndIf 
 If bufPureBasic : audio::DestroyBuffer(bufPureBasic) : EndIf 
 If bufPing : audio::DestroyBuffer(bufPing) : EndIf 
       
 Debug ""
EndProcedure

Procedure Main()

 Protected device

 Debug audio::GetVersion()
 Debug audio::GetOpenALVersion()
 Debug audio::GetLibSndFileVersion() 
 
 device = audio::OpenDevice()
 
 Debug ""
 Debug "Current device name: " + audio::GetCurrentDeviceName()
 Debug ""
             
 test()

 Debug "Done"
 
 audio::CloseDevice(device)
EndProcedure
 
audio::RegisterErrorCallBack(@CallBack_Error())

If audio::Init()
    Main()
    audio::Shutdown()
EndIf
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 59
; FirstLine = 18
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory
; EnablePurifier