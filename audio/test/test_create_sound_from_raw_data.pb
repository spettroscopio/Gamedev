EnableExplicit

IncludeFile "../audio.pb"

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure


Procedure.i CreateRawData (tone, duration, bits, samplerate, channels, *dataptr, *datalen) 
 Protected count = duration * samplerate * channels * (bits / 8) / 1000
 Protected *buffer = AllocateMemory(count)   
 Protected w.f = (2 * #PI * tone) / channels / (bits / 8)
 
 If (bits = 8 Or bits = 16) And (channels = 1 Or channels = 2)
     Protected i, j
     
     If bits = 8
         For j = 0 To count - 1
            PokeB(*buffer + i, 127 + 127 * Sin(j * w / samplerate)) : i + 1
         Next
     ElseIf bits = 16
          For j = 0 To count - 1 Step 2
            PokeW(*buffer + i, 32767 * Sin(j * w / samplerate)) : i + 2
         Next
     EndIf 
     
     PokeI(*datalen, count)
     PokeI(*dataptr, *buffer)
     
     ProcedureReturn 1
  EndIf
  
  ProcedureReturn 0
EndProcedure

Procedure test()
 
 Protected tone = 440 ; 440 Hz = La
 Protected duration = 2000 ; Ms
 Protected bits = 8
 Protected samplerate = 22050 ; Hz
 Protected channels = 1
 
 Protected buffer, *dataptr, datalen
 
 If CreateRawData (tone, duration, bits, samplerate, channels, @*dataptr, @datalen)

    buffer = audio::CreateBufferFromRawData(bits, samplerate, channels, *dataptr, datalen)
 
    FreeMemory(*dataptr)
 EndIf
 
 If buffer
 
    Protected sound = audio::CreateSoundFromBuffer(buffer)
    
     If sound
        Debug "Sound from RAW PCM"
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
        Debug "Play the sound created on the fly and read from memory ..."
        
        audio::Play(sound)
                    
        While audio::GetState(sound) = audio::#Playing
            Debug "Current position: " + audio::GetPos(sound, audio::#Milliseconds)
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
; IDE Options = PureBasic 6.02 LTS (Linux - x64)
; CursorPosition = 55
; FirstLine = 42
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory
; EnablePurifier