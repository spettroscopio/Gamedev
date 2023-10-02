; *********************************************************************************************************************
; profiler.pb
; by luis 
;
; Some ASM code from idle
; https://www.purebasic.fr/english/viewtopic.php?t=81099
;
; The module is enabled when #PROFILER_ENABLED = 1 is defined before its inclusion and completely removed from 
; the code when #PROFILER_ENABLED = 0 is defined.
;
; The module namespace * MUST * be imported with "Usemodule profiler".
;
; Varius stuff useful for simple profiling.
;
; OS: Windows, Linux
;
; 1.00, Sep 14 2023, PB 6.02
; First release.
; *********************************************************************************************************************

; ---------------------------------------------------------------------------------------------------------------------
; PROFILER_START (section = "")
;  Specify the start of the section of code to be profiled.
;
;  When used inside a procedure, if only one section is defined inside the procedure, the section name can be omitted
;  and will be automatically filled using the procedure name, for example "foo()".
;  If more sections are defined, the other sections must have a unique name manuallly specified.
;  Outside of a procedure, the section name is always required.
; ---------------------------------------------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------------------------------------------
; PROFILER_STOP (section = "")
;  Specify the end of the section of code to be profiled.
; ---------------------------------------------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------------------------------------------
; PROFILER_REPORT (w = 800, h = 400)
;  Shows a window with the timings collected from profiling.
; ---------------------------------------------------------------------------------------------------------------------

; ---------------------------------------------------------------------------------------------------------------------
; PROFILER_RESET()
;  Reset the data structures of the profiler to a clear state.
; ---------------------------------------------------------------------------------------------------------------------

CompilerIf Defined(PROFILER_ENABLED, #PB_Constant) = #False
 CompilerError "The constant #PROFILER_ENABLED is not defined."
CompilerEndIf

CompilerIf #PROFILER_ENABLED = 0

DeclareModule profiler

Macro PROFILER_START (section = "")
EndMacro

Macro PROFILER_STOP (section = "")
EndMacro

Macro PROFILER_REPORT (w = 800, h = 400)
EndMacro

Macro PROFILER_RESET()
EndMacro

EndDeclareModule

Module profiler
 ; NOP
EndModule

CompilerElse

DeclareModule profiler

Macro PROFILER_START (section = "")
 If section <> ""
    _PROFILER_START (section, section)
 Else
    If #PB_Compiler_Procedure <> ""   
        _PROFILER_START (#PB_Compiler_Procedure + "()", _PROFILER_KEY())
    Else
        DebuggerError("A section name must be specified when outside procedures.")
    EndIf
 EndIf
 
EndMacro

Macro PROFILER_STOP (section = "")
 If section <> ""   
    _PROFILER_STOP (section, section)
 Else
    If #PB_Compiler_Procedure <> ""   
        _PROFILER_STOP (#PB_Compiler_Procedure + "()", _PROFILER_KEY())
    Else
        DebuggerError("A section name must be specified when outside procedures.")
    EndIf
 EndIf
EndMacro

Macro PROFILER_REPORT (w = 800, h = 400)
 _PROFILER_REPORT (w, h)
EndMacro

Macro PROFILER_RESET()
 _PROFILER_RESET()
EndMacro

Macro _PROFILER_KEY()
 #PB_Compiler_Filename + "," + #PB_Compiler_Module + "," + #PB_Compiler_Procedure
EndMacro

Declare     _PROFILER_START (section$, key$)
Declare     _PROFILER_STOP (section$, key$)
Declare     _PROFILER_RESET()
Declare     _PROFILER_REPORT (w, h)

EndDeclareModule 

Module profiler

EnableExplicit

Declare.q   RDTSC()
Declare.q   Frequency()
Declare.s   FormatTime (time_ms.f)

Structure PROFILER_RESULT
 section$
 totalCalls.i
 totalTime_ms.f
 averageTime_ms.f
 totalCycles.q
 averageCycles.q
EndStructure

Structure PROFILER_SECTION
 section$
 open.i
 totalCalls.i
 totalCycles.q
EndStructure

Structure PROFILER_OBJ
 frequency.q
 Map sections.PROFILER_SECTION()
 List results.PROFILER_RESULT()
 List stack.q()
EndStructure : Global PROFILER.PROFILER_OBJ

PROFILER\frequency = Frequency()
 
CompilerIf Defined (PB_Compiler_Backend, #PB_Constant) And #PB_Compiler_Backend = #PB_Backend_C

 Procedure.q RDTSC()
  Protected.q out
  ! unsigned h32, l32;
  ! __asm__ __volatile__ ("lfence\n rdtsc\n lfence" : "=d"(h32), "=a"(l32));
  ! v_out = (((unsigned long long) h32) << 32) | ((unsigned long long) l32);
  ProcedureReturn out
 EndProcedure 

CompilerElse

 Procedure.q RDTSC()
  Protected.q h32, l32
  DisableDebugger
  !lfence 
  !rdtsc
  !lfence
  !mov [p.v_h32], edx
  !mov [p.v_l32], eax 
  ProcedureReturn (h32 << 32) | l32
  EnableDebugger
 EndProcedure 

CompilerEndIf

Procedure.q Frequency()
 Protected.q t1, t2
 DisableDebugger  
 t1 = RDTSC()
 Delay(100) ; 1/10 of a second
 t2 = RDTSC()
 EnableDebugger 
 ProcedureReturn (t2-t1) * 10 ; so 10 times to get the Hz
EndProcedure

Procedure.s FormatTime (time_ms.f)
 Protected dec = 0
 
 If time_ms < 100.0
    dec = 2
 EndIf
     
 If time_ms < 1.0
    dec = 3
 EndIf

 If time_ms < 0.01
    dec = 4
 EndIf
 
 ProcedureReturn FormatNumber(time_ms, dec)
EndProcedure

Procedure _PROFILER_START (section$, key$)
 Protected *section.PROFILER_SECTION
 
 *section = FindMapElement(PROFILER\sections(), key$)
 
 If *section = #Null
    *section = AddMapElement(PROFILER\sections(), key$)
    *section\section$ = section$
    *section\open = 0
 EndIf
 
 *section\open + 1
 
 If *section\open = 1
    AddElement(PROFILER\stack())
    PROFILER\stack() = RDTSC()
 EndIf
EndProcedure

Procedure _PROFILER_STOP (section$, key$)
 Protected *section.PROFILER_SECTION
 Protected.q startCycles, stopCycles
 
 startCycles = PROFILER\stack()
 stopCycles = RDTSC()
 
 *section = FindMapElement(PROFILER\sections(), key$)
 
 If *section = #Null
    DebuggerError("Profiler sections are not matching !")
 EndIf
 
 *section\totalCalls + 1
 *section\open - 1
 
 If *section\open = 0
    *section\totalCycles + (stopCycles - startCycles)
    DeleteElement(PROFILER\stack())
 EndIf
EndProcedure

Procedure _PROFILER_RESET ()
 ClearMap(PROFILER\sections())
 ClearList(PROFILER\results())
 ClearList(PROFILER\stack())
EndProcedure

Enumeration  
 #WIN
 #LIST_ICON
 #BTN_CLOSE   
 #BTN_SRT_ASC   
 #BTN_SRT_DESC    
EndEnumeration

Procedure _PROFILER_REFRESH ()
 Protected s$
 
 ClearGadgetItems(#LIST_ICON)

 ForEach PROFILER\results()
    s$ = PROFILER\results()\section$ + Chr(10)
    s$ + FormatNumber(PROFILER\results()\totalCalls, 0) + Chr(10)
    s$ + FormatTime(PROFILER\results()\totalTime_ms) + Chr(10)
    s$ + FormatTime(PROFILER\results()\averageTime_ms) + Chr(10)
    s$ + FormatNumber(PROFILER\results()\totalCycles, 0) + Chr(10)
    s$ + FormatNumber(PROFILER\results()\averageCycles, 0)
    
    AddGadgetItem(#LIST_ICON, -1, s$)
 Next     
EndProcedure

Procedure _PROFILER_RESIZE() 
 Protected w = WindowWidth(#WIN)
 Protected h = WindowHeight(#WIN)
 
 ResizeGadget(#LIST_ICON, #PB_Ignore, #PB_Ignore, w, h - 38)
 ResizeGadget(#BTN_CLOSE, w - 105 , h - 33, #PB_Ignore, #PB_Ignore)
 ResizeGadget(#BTN_SRT_ASC, 5, h - 33, #PB_Ignore, #PB_Ignore)
 ResizeGadget(#BTN_SRT_DESC, 110, h - 33, #PB_Ignore, #PB_Ignore)
EndProcedure

Procedure _PROFILER_REPORT (w, h)
 Protected dbg$, be$   
 Protected event, gadget

 ClearList(PROFILER\results())
 
 ForEach PROFILER\sections()
    ; Debug MapKey(PROFILER\sections())
    
    AddElement(PROFILER\results())
    
    PROFILER\results()\section$ = PROFILER\sections()\section$
      
    PROFILER\results()\totalCalls = PROFILER\sections()\totalCalls
            
    PROFILER\results()\totalTime_ms = PROFILER\sections()\totalCycles / (PROFILER\frequency / 1000.0)
    
    PROFILER\results()\totalCycles = PROFILER\sections()\totalCycles
    
    PROFILER\results()\averageTime_ms = PROFILER\results()\totalTime_ms / PROFILER\sections()\totalCalls 
    
    PROFILER\results()\averageCycles = PROFILER\sections()\totalCycles / PROFILER\sections()\totalCalls
 Next
 
 CompilerIf (#PB_Compiler_Debugger = 1)
  dbg$ = "  (DEBUGGER)"
 CompilerEndIf
 
 CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)
  be$ = "  (ASM backend)"
 CompilerElse
  be$ = "  (C backend)"
 CompilerEndIf

 OpenWindow(#WIN, 0, 0, w, h, "PROFILER" + be$ + dbg$, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
 
 WindowBounds(#WIN, 400, 200, #PB_Ignore, #PB_Ignore)
 
 ListIconGadget(#LIST_ICON, 0, 0, w, h - 38, "Section", 150, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect)
 
 SetGadgetColor(#LIST_ICON, #PB_Gadget_BackColor, RGB(248,248,248))
 SetGadgetColor(#LIST_ICON, #PB_Gadget_LineColor, RGB(220,220,220))
 
 Protected width = w / 6
 
 AddGadgetColumn(#LIST_ICON, 1, "Calls", width - 20)
 AddGadgetColumn(#LIST_ICON, 2, "Time (ms)", width)
 AddGadgetColumn(#LIST_ICON, 3, "Avg Time (ms)", width)
 AddGadgetColumn(#LIST_ICON, 4, "Cycles", width)
 AddGadgetColumn(#LIST_ICON, 5, "Avg Cycles", width - 20)
 
;  ButtonGadget(#BTN_CLOSE, w - 105 , h - 33, 100 , 28, "Close")
;  ButtonGadget(#BTN_SRT_ASC, 5, h - 33, 100 , 28, "Asc")
;  ButtonGadget(#BTN_SRT_DESC, 110, h - 33, 100 , 28, "Desc")

 ButtonGadget(#BTN_CLOSE, 0, 0, 100 , 28, "Close")
 ButtonGadget(#BTN_SRT_ASC, 0, 0, 100 , 28, "Asc")
 ButtonGadget(#BTN_SRT_DESC, 0, 0, 100 , 28, "Desc")

 SortStructuredList(PROFILER\results(), #PB_Sort_Descending, OffsetOf(PROFILER_RESULT\totalCycles), #PB_Quad)
 
 _PROFILER_REFRESH()
 _PROFILER_RESIZE()
 
 BindEvent(#PB_Event_SizeWindow, @_PROFILER_RESIZE(), #WIN)
 
 Repeat 
    event = WaitWindowEvent()
    
    Select event    
      
        Case #PB_Event_Gadget    
            gadget = EventGadget()
                                
            If gadget = #BTN_CLOSE
                Break
            EndIf
            
            If gadget = #BTN_SRT_DESC
                SortStructuredList(PROFILER\results(), #PB_Sort_Descending, OffsetOf(PROFILER_RESULT\totalCycles), #PB_Quad)
                _PROFILER_REFRESH()
            EndIf
            
            If gadget = #BTN_SRT_ASC
                SortStructuredList(PROFILER\results(), #PB_Sort_Ascending, OffsetOf(PROFILER_RESULT\totalCycles), #PB_Quad)
                _PROFILER_REFRESH()
            EndIf
    EndSelect 
    
 Until event = #PB_Event_CloseWindow   

 CloseWindow(#WIN)
 
EndProcedure

EndModule

CompilerEndIf

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 4
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory