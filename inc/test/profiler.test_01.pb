#PROFILER_ENABLED = 1

XIncludeFile "../profiler.pb"

UseModule profiler


PROFILER_START("NOP")
 ; NOP
PROFILER_STOP("NOP")


PROFILER_START("Global")
Delay(100)
PROFILER_STOP("Global")

PROFILER_REPORT()

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 12
; Optimizer
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory