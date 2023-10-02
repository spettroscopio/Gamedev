#PROFILER_ENABLED = 1

XIncludeFile "../profiler.pb"

UseModule profiler


Procedure zoo()
PROFILER_START()
 Delay(10)
PROFILER_STOP()
EndProcedure


Procedure bar()
PROFILER_START()
 Delay(5)
PROFILER_STOP()
EndProcedure


Procedure foo()    
PROFILER_START()

 Protected j
 
 For j = 1 To 10
    bar()
    zoo() 
 Next
     
PROFILER_STOP()
EndProcedure


foo()

PROFILER_REPORT()

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 16
; Optimizer
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory