EnableExplicit

IncludeFile "../audio.pb"

DataSection
start_sound:
IncludeBinary "../assets/purebasic-mono-08-bits.wav"
end_sound:
EndDataSection

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure test()
 
 Protected buffer
 
 buffer = audio::CreateBufferFromMemoryFile(?start_sound, ?end_sound - ?start_sound)
   
 If buffer
 
    Protected sound = audio::CreateSoundFromBuffer(buffer)
    
     If sound
        Debug "Sound from in memory file"
        Debug ""
        
        Debug "Format             : " + audio::GetFormatString(sound)
        Debug "SubFormat          : " + audio::GetSubFormatString(sound)
        Debug "Channels           : " + audio::GetChannels(sound)
        Debug "Samplerate         : " + audio::GetSampleRate(sound)
        Debug "Length (frames)    : " + audio::GetLength(sound, audio::#Frames)
        Debug "Length (ms)        : " + audio::GetLength(sound, audio::#Milliseconds)
        Debug "Audio data (bytes) : " + audio::GetAudioDataSize(sound)
        Debug "State              : " + audio::GetState(sound)
        
        Debug ""
        Debug "Play the sound file read from memory ..."
        
        audio::Play(sound)
                    
        While audio::GetState(sound) = audio::#Playing
            Debug "Current position: " + audio::GetPos(sound, audio::#Milliseconds)
            Delay(250)
        Wend
                 
     EndIf
 EndIf 

 If sound  : audio::DestroySound(sound)   : EndIf 
 If buffer : audio::DestroyBuffer(buffer) : EndIf 
       
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
; CursorPosition = 47
; FirstLine = 6
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory
; EnablePurifier