; *********************************************************************************************************************
; libsndfile.load.pb
; by luis
;
; Bindings for libsndfile 1.2.0
; Must be used in conjunction of libsndfile.pbi to import the actual functions.
;
; Tested on: Windows (x86, x64)
;
; 1.0, Aug 03 2023, PB 6.02 
; *********************************************************************************************************************

DeclareModule libsndfile_load

EnableExplicit
 
Declare.i    Load()
Declare      Shutdown()

;- ERROR CONSTANTS 

#LOAD_OK = 0
#LOAD_DLL_NOT_FOUND = 1
#LOAD_MISSING_IMPORTED_FUNCS = 2

EndDeclareModule

Module libsndfile_load

UseModule libsndfile
 
#DLL_PATH_LOOKUP$   = ".,./lib,./bin"

Structure LIBSNDFILE_OBJ
 hdll.i
 MissingEntries.i
EndStructure : Global LIBSNDFILE.LIBSNDFILE_OBJ

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
 
 ; try from the predefined directory for the development environment
 If h = 0 And InsideIDE()    
    p$ = #PB_Compiler_FilePath + "lib/" + dll$    
    h = OpenLibrary(#PB_Any, p$)
 EndIf
 
 ProcedureReturn h
EndProcedure

Procedure.i GPA (func$) ; get address from the name of the func
 Protected *fp = GetFunction(LIBSNDFILE\hdll, func$) 
 If *fp = 0
    LIBSNDFILE\MissingEntries + 1    
    DebuggerWarning("glfw function " + #DQUOTE$ + func$ + #DQUOTE$ + " not found.")
 EndIf
 ProcedureReturn *fp
EndProcedure

;- DYNAMIC LINKING

CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
 CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
  #OAL_LIBRARY_NAME$ = "libsndfile.x86.dll"
 CompilerElse   
  #OAL_LIBRARY_NAME$ = "libsndfile.x64.dll"
 CompilerEndIf
CompilerEndIf

CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
 CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
  CompilerError "On Linux the library has been built for x64 only."
 CompilerElse   
  #OAL_LIBRARY_NAME$ = "libsndfile.x64.so"
 CompilerEndIf
CompilerEndIf

Procedure.i Load()

 LIBSNDFILE\hdll = OpenDll (#OAL_LIBRARY_NAME$)
  
 If LIBSNDFILE\hdll    
    sf_open = GPA("sf_open")
    sf_open_fd = GPA("sf_open_fd")
    sf_open_virtual  = GPA("sf_open_virtual")
    sf_error = GPA("sf_error")
    sf_strerror = GPA("sf_strerror")
    sf_error_number = GPA("sf_error_number")
    sf_perror = GPA("sf_perror")
    sf_error_str = GPA("sf_error_str")
    sf_command = GPA("sf_command")
    sf_format_check = GPA("sf_format_check")
    sf_seek = GPA("sf_seek")
    sf_set_string = GPA("sf_set_string")
    sf_get_string = GPA("sf_get_string")
    sf_version_string = GPA("sf_version_string")
    sf_current_byterate = GPA("sf_current_byterate")
    sf_read_raw = GPA("sf_read_raw")
    sf_write_raw = GPA("sf_write_raw")
    sf_readf_short = GPA("sf_readf_short")
    sf_writef_short = GPA("sf_writef_short")
    sf_readf_int = GPA("sf_readf_int")
    sf_writef_int = GPA("sf_writef_int")
    sf_readf_float = GPA("sf_readf_float")
    sf_writef_float = GPA("sf_writef_float")
    sf_readf_double = GPA("sf_readf_double")
    sf_writef_double = GPA("sf_writef_double")
    sf_read_short = GPA("sf_read_short")
    sf_write_short = GPA("sf_write_short")
    sf_read_int = GPA("sf_read_int")
    sf_write_int = GPA("sf_write_int")
    sf_read_float = GPA("sf_read_float")
    sf_write_float = GPA("sf_write_float")
    sf_read_double = GPA("sf_read_double")
    sf_write_double = GPA("sf_write_double")
    sf_close = GPA("sf_close")
    sf_write_sync = GPA("sf_write_sync")
    
    sf_set_chunk = GPA("sf_set_chunk")
    sf_get_chunk_iterator = GPA("sf_get_chunk_iterator")
    sf_next_chunk_iterator = GPA("sf_next_chunk_iterator")
    sf_get_chunk_size = GPA("sf_get_chunk_size")
    sf_get_chunk_data = GPA("sf_get_chunk_data")
    
   CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
    sf_wchar_open = GPA("sf_wchar_open")
   CompilerEndIf

   CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
    ; linux only
   CompilerEndIf
       
   If LIBSNDFILE\MissingEntries > 0
        ProcedureReturn #LOAD_MISSING_IMPORTED_FUNCS
   EndIf
     
    ProcedureReturn #LOAD_OK
 EndIf
 
 ProcedureReturn #LOAD_DLL_NOT_FOUND
EndProcedure

Procedure Shutdown()
 If LIBSNDFILE\hdll    
    CloseLibrary(LIBSNDFILE\hdll)   
 EndIf
EndProcedure

EndModule
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory