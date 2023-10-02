#PROFILER_ENABLED = 1

XIncludeFile "../profiler.pb"

UseModule profiler

Procedure bar()
PROFILER_START()
 Delay(5)
PROFILER_STOP()
EndProcedure

Procedure foo()    
PROFILER_START()

Static recursion

Delay(10)

recursion + 1
  
If recursion < 100
    foo()
    bar()
EndIf      

PROFILER_STOP()
EndProcedure

foo()

PROFILER_REPORT()

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 17
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory