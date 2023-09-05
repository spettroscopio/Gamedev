; The minimal SGL program.

EnableExplicit

IncludeFile "../sgl.pbi"
IncludeFile "../sgl.pb"

Define Title$ = "Minimal SGL program"

Define win

If sgl::Init()        
    win = sgl::CreateWindow(640, 480, Title$)
    
    If win                
        sgl::MakeContextCurrent(win)        
        
        While sgl::WindowShouldClose(win) = 0
            sgl::SwapBuffers(win)
            sgl::PollEvents()
        Wend    
    EndIf    
    sgl::Shutdown()
EndIf
 
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 3
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory