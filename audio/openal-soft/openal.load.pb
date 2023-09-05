; *********************************************************************************************************************
; openal.load.pb
; by luis
;
; Bindings for OpenaAL Soft 1.3.
; Must be used in conjunction of openal.pbi (where the symbols and constants are defined).
;
; Tested on: Windows (x86, x64)
;
; 1.0, Jul 28 2023, PB 6.02
; *********************************************************************************************************************

DeclareModule openal_load

EnableExplicit
 
Declare.i    Load()
Declare      Shutdown()

;- OPENAL LOAD ERROR CONSTANTS 

#LOAD_OK = 0
#LOAD_DLL_NOT_FOUND = 1
#LOAD_MISSING_IMPORTED_FUNCS = 2

EndDeclareModule

Module openal_load

UseModule openal
 
#DLL_PATH_LOOKUP$   = ".,./lib,./bin"

Structure OPENAL_OBJ
 hdll.i
 MissingEntries.i
EndStructure : Global OPENAL.OPENAL_OBJ

Procedure InsideIDE()
 ; Checks if the program is running inside the PB IDE or not.
 If FindString(GetFilePart(ProgramFilename()),"PureBasic_Compilation", 1, #PB_String_NoCase)
    ProcedureReturn 1
 EndIf
 ProcedureReturn 0
EndProcedure

Procedure.i OpenDll (dll$)
 Protected h, i, d$, p$
 
 Repeat
    i + 1
    d$ = StringField(#DLL_PATH_LOOKUP$, i, ",") 
    
    If d$ = #Empty$ : Break : EndIf
    
    ; try for the dynamic library in the specified dir
    p$ = d$ + "/" + dll$
    
    h = OpenLibrary(#PB_Any, p$) 
    
    If h : Break : EndIf    
 ForEver
 
 ; try dynamic library from the predefined directory for the development environment
 If h = 0 And InsideIDE()    
    p$ = #PB_Compiler_FilePath + "lib/" + dll$    
    h = OpenLibrary(#PB_Any, p$)
 EndIf
 
 ProcedureReturn h
EndProcedure

Procedure.i GPA (func$) ; get address from the name of the func
 Protected *fp = GetFunction(OPENAL\hdll, func$) 
 If *fp = 0
    OPENAL\MissingEntries + 1    
    DebuggerWarning("glfw function " + #DQUOTE$ + func$ + #DQUOTE$ + " not found.")
 EndIf
 ProcedureReturn *fp
EndProcedure

;- DYNAMIC LINKING

CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
 CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
  #OAL_LIBRARY_NAME$ = "oal.soft.x86.dll"
 CompilerElse   
  #OAL_LIBRARY_NAME$ = "oal.soft.x64.dll"
 CompilerEndIf
CompilerEndIf

CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
 CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
  CompilerError "On Linux the library has been built for x64 only."
 CompilerElse   
  #OAL_LIBRARY_NAME$ = "oal.soft.x64.so"
 CompilerEndIf
CompilerEndIf

Procedure.i Load()

 OPENAL\hdll = OpenDll (#OAL_LIBRARY_NAME$)
  
 If OPENAL\hdll    
    alEnable = GPA("alEnable")
    alDisable = GPA("alDisable")
    alIsEnabled = GPA("alIsEnabled")
    alDopplerFactor = GPA("alDopplerFactor")
    alDopplerVelocity = GPA("alDopplerVelocity")
    alSpeedOfSound = GPA("alSpeedOfSound")
    alDistanceModel = GPA("alDistanceModel")
    alGetString = GPA("alGetString")
    alGetBooleanv = GPA("alGetBooleanv")
    alGetIntegerv = GPA("alGetIntegerv")
    alGetFloatv = GPA("alGetFloatv")
    alGetDoublev = GPA("alGetDoublev")
    alGetBoolean = GPA("alGetBoolean")
    alGetInteger = GPA("alGetInteger")
    alGetFloat = GPA("alGetFloat")
    alGetDouble = GPA("alGetDouble")
    alGetError = GPA("alGetError")
    alIsExtensionPresent = GPA("alIsExtensionPresent")
    alGetProcAddress = GPA("alGetProcAddress")
    alGetEnumValue = GPA("alGetEnumValue")
    alListenerf = GPA("alListenerf")
    alListener3f = GPA("alListener3f")
    alListenerfv = GPA("alListenerfv")
    alListeneri = GPA("alListeneri")
    alListener3i = GPA("alListener3i")
    alListeneriv = GPA("alListeneriv")
    alGetListenerf = GPA("alGetListenerf")
    alGetListener3f = GPA("alGetListener3f")
    alGetListenerfv = GPA("alGetListenerfv")
    alGetListeneri = GPA("alGetListeneri")
    alGetListener3i = GPA("alGetListener3i")
    alGetListeneriv = GPA("alGetListeneriv")
    alGenSources = GPA("alGenSources")
    alDeleteSources = GPA("alDeleteSources")
    alIsSource = GPA("alIsSource")
    alSourcef = GPA("alSourcef")
    alSource3f = GPA("alSource3f")
    alSourcefv = GPA("alSourcefv")
    alSourcei = GPA("alSourcei")
    alSource3i = GPA("alSource3i")
    alSourceiv = GPA("alSourceiv")
    alGetSourcef = GPA("alGetSourcef")
    alGetSource3f = GPA("alGetSource3f")
    alGetSourcefv = GPA("alGetSourcefv")
    alGetSourcei = GPA("alGetSourcei")
    alGetSource3i = GPA("alGetSource3i")
    alGetSourceiv = GPA("alGetSourceiv")
    alSourcePlay = GPA("alSourcePlay")
    alSourceStop = GPA("alSourceStop")
    alSourceRewind = GPA("alSourceRewind")
    alSourcePause = GPA("alSourcePause")
    alSourcePlayv = GPA("alSourcePlayv")
    alSourceStopv = GPA("alSourceStopv")
    alSourceRewindv = GPA("alSourceRewindv")
    alSourcePausev = GPA("alSourcePausev")
    alSourceQueueBuffers = GPA("alSourceQueueBuffers")
    alSourceUnqueueBuffers = GPA("alSourceUnqueueBuffers")
    alGenBuffers = GPA("alGenBuffers")
    alDeleteBuffers = GPA("alDeleteBuffers")
    alIsBuffer = GPA("alIsBuffer")
    alBufferData = GPA("alBufferData")
    alBufferf = GPA("alBufferf")
    alBuffer3f = GPA("alBuffer3f")
    alBufferfv = GPA("alBufferfv")
    alBufferi = GPA("alBufferi")
    alBuffer3i = GPA("alBuffer3i")
    alBufferiv = GPA("alBufferiv")
    alGetBufferf = GPA("alGetBufferf")
    alGetBuffer3f = GPA("alGetBuffer3f")
    alGetBufferfv = GPA("alGetBufferfv")
    alGetBufferi = GPA("alGetBufferi")
    alGetBuffer3i = GPA("alGetBuffer3i")
    alGetBufferiv = GPA("alGetBufferiv")
    
    alcCreateContext = GPA("alcCreateContext")
    alcMakeContextCurrent = GPA("alcMakeContextCurrent")
    alcProcessContext = GPA("alcProcessContext")
    alcSuspendContext = GPA("alcSuspendContext")
    alcDestroyContext = GPA("alcDestroyContext")
    alcGetCurrentContext = GPA("alcGetCurrentContext")
    alcGetContextsDevice = GPA("alcGetContextsDevice")
    alcOpenDevice = GPA("alcOpenDevice")
    alcCloseDevice = GPA("alcCloseDevice")
    alcGetError = GPA("alcGetError")
    alcIsExtensionPresent = GPA("alcIsExtensionPresent")
    alcGetProcAddress = GPA("alcGetProcAddress")
    alcGetEnumValue = GPA("alcGetEnumValue")
    alcGetString = GPA("alcGetString")
    alcGetIntegerv = GPA("alcGetIntegerv")
    alcCaptureOpenDevice = GPA("alcCaptureOpenDevice")
    alcCaptureCloseDevice = GPA("alcCaptureCloseDevice")
    alcCaptureStart = GPA("alcCaptureStart")
    alcCaptureStop = GPA("alcCaptureStop")
    alcCaptureSamples = GPA("alcCaptureSamples")
    
   CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
    ; windows only
   CompilerEndIf

   CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
    ; linux only
   CompilerEndIf
       
   If OPENAL\MissingEntries > 0
        ProcedureReturn #LOAD_MISSING_IMPORTED_FUNCS
    EndIf
     
    ProcedureReturn #LOAD_OK
 EndIf
 
 ProcedureReturn #LOAD_DLL_NOT_FOUND
EndProcedure

Procedure Shutdown()
 If OPENAL\hdll   
    CloseLibrary(OPENAL\hdll)
 EndIf
EndProcedure

EndModule
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 2
; Folding = ---
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory