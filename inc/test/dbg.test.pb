IncludeFile "../dbg.pb"
UseModule dbg

For k = 1 To 3
 DBG_TEXT_ONCE("Only once")
 DBG_TEXT("Once every 100 ms", 100)
 DBG_TEXT("Hello World")
 DBG_TEXT_IF("Hello World [TRUE]", #True) 
 DBG_TEXT_IF("Hello World [FALSE]", #False) 
 Delay(1000)
 Debug ""
Next

ASSERT_START
 CompilerIf (#PB_Compiler_Debugger = 1)
 ; complex checks here
 If Random(10) > 5
    ASSERT_FAIL()
 EndIf
 CompilerEndIf
ASSERT_END

ASSERT(1=1)

ASSERT(1=0)

; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 16
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory