EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure test01 (sound)
 Debug ""   
 Debug "Plays the sound"
 Delay(1000)
  
 audio::Play(sound)
 
 While audio::GetState(sound) = audio::#Playing
    Delay(1)            
 Wend
 
 Debug "Done."
EndProcedure

Procedure test02 (sound)
 Debug ""   
 Debug "Plays the sound while checking the current position in ms"
 Delay(1000)
      
 audio::Play(sound)    
 
 While audio::GetState(sound) = audio::#Playing
    Debug "Current position: " + audio::GetPos(sound, audio::#Milliseconds)
    Delay(100)
 Wend
 
 Debug "Done."
EndProcedure

Procedure test03 (sound)
 Debug ""   
 Debug "Plays the sound while checking the current position in frames"
 Delay(1000)

 audio::Play(sound)

 While audio::GetState(sound) = audio::#Playing
    Debug "Current position: " + audio::GetPos(sound, audio::#Frames)
    Delay(100)
 Wend
 
 Debug "Done."
EndProcedure

Procedure test04 (sound)
 Debug ""   
 Debug "Plays the sound setting the position to 700 ms"
 Delay(1000)

 audio::SetPos(sound, 700, audio::#Milliseconds) 
 audio::Play(sound)
 
 While audio::GetState(sound) = audio::#Playing
    Delay(100)
 Wend

 Debug "Done."
EndProcedure

Procedure test05 (sound)
 Debug ""   
 Debug "Plays the sound setting the position to 15400 samples"
 Delay(1000)

 audio::SetPos(sound, 15400, audio::#Frames)
 audio::Play(sound)    

 While audio::GetState(sound) = audio::#Playing
    Delay(100)
 Wend

 Debug "Done."
EndProcedure

Procedure test06 (sound)
 Debug ""   
 Debug "Plays the sound looped, wait for 3 times its length and stops it"
 Delay(1000)

 Protected length = audio::GetLength(sound, audio::#Milliseconds) * 3
 
 audio::Play(sound, #True)
 Delay(length)
 audio::Stop(sound)
 
 Debug "Done."
EndProcedure

Procedure test07 (sound)
 Debug ""   
 Debug "Plays the sound, pause and continue"
 Delay(1000)

 audio::Play(sound)
 
 Delay(665)
 
 audio::Pause(sound)
 
 Debug "paused ..."
 Delay(1000)
 Debug "... resuming"
 
 audio::Play(sound)
 
 While audio::GetState(sound) = audio::#Playing
    Delay(100)
 Wend    
 
 Debug "Done."
EndProcedure

Procedure test08 (sound)
 Debug ""   
 Debug "Plays the sound looped, while rising and lowering the volume"
 Delay(1000)

 Protected time, delta, tick
 Protected volume.f, rad.f

 Protected length = audio::GetLength(sound, audio::#Milliseconds) * 3     

 audio::Play(sound, #True)

 time = ElapsedMilliseconds()    

 While delta < length
    rad = (delta / length) * #PI * 3.0
    volume = (Cos(rad) + 1.0) / 2.0
    
    audio::SetVolume(sound, volume)
    
    If ElapsedMilliseconds() - tick >= 100 ; ms
        tick = ElapsedMilliseconds() 
        Debug StrF(volume,2)
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
             
 Protected file$ = "mono-16-bits.wav" 
  
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
        
        test01(sound)
        test02(sound)
        test03(sound)
        test04(sound)
        test05(sound)
        test06(sound)
        test07(sound)
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
; CursorPosition = 170
; FirstLine = 160
; Folding = --
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory