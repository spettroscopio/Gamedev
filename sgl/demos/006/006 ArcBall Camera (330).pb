﻿; This is the very similar to the previous program, but modified to use an ArcBall instead of a FPS camera.

EnableExplicit

IncludeFile "../../sgl.pbi"
IncludeFile "../../sgl.pb"

IncludeFile "../../extras/RenderText/RenderText.pb"
IncludeFile "../../extras/Camera/ArcBall.pb"

UseModule gl

#TITLE$ = "ArcBall Camera"
#WIN_WIDTH = 1024
#WIN_HEIGHT = 768
#VSYNC = 1

Global gWin
Global gVSync = #VSYNC 
Global gShader
Global gFon
Global gFonHelp
Global gTimer
Global gVao
Global Dim gTextures(5)

Declare   CallBack_WindowRefresh (win)
Declare   CallBack_Error (source$, desc$)
Declare   SetupData()
Declare   SetupContext()
Declare   ShutDown()
Declare   Render()
Declare   MainLoop()
Declare   Main()
 
Procedure CallBack_WindowRefresh (win)
 Render()
EndProcedure 

Procedure CallBack_Error (source$, desc$)
 Debug "[" + source$ + "] " + desc$
EndProcedure

Procedure.i RandomColor()
 Protected r, g, b
 r = Random(255, 64)
 g = Random(255, 64)
 b = Random(255, 64)
 ProcedureReturn RGB(r,g,b)
EndProcedure

Procedure.i BuildTex (id)
 Protected *td.sgl::TexelData
 Protected img, texid
 Protected maxAnisotropy.f
 
 Select id
    Case 0 
        img = sgl::CreateImage_DiceFace(512, 512, 1, RGB(0, 0, 0), RandomColor()) ; front 
    Case 1         
        img = sgl::CreateImage_DiceFace(512, 512, 6, RGB(0, 0, 0), RandomColor()) ; back
    Case 2 
        img = sgl::CreateImage_DiceFace(512, 512, 5, RGB(0, 0, 0), RandomColor()) ; top 
    Case 3 
        img = sgl::CreateImage_DiceFace(512, 512, 2, RGB(0, 0, 0), RandomColor()) ; bottom
    Case 4 
        img = sgl::CreateImage_DiceFace(512, 512, 3, RGB(0, 0, 0), RandomColor()) ; right
    Case 5 
        img = sgl::CreateImage_DiceFace(512, 512, 4, RGB(0, 0, 0), RandomColor()) ; left
 EndSelect
  
 *td = sgl::CreateTexelData (img)
  
 glGenTextures_(1, @texid) 
 glBindTexture_(#GL_TEXTURE_2D, texid)
 
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE) 
 
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR_MIPMAP_LINEAR)
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
 
 If sgl::IsExtensionAvailable("GL_EXT_texture_filter_anisotropic") Or sgl::IsExtensionAvailable("GL_ARB_texture_filter_anisotropic")
    glGetFloatv_(#GL_MAX_TEXTURE_MAX_ANISOTROPY, @maxAnisotropy)
    glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAX_ANISOTROPY, maxAnisotropy)
 EndIf
  
 glTexImage2D_(#GL_TEXTURE_2D, 0, *td\internalTextureFormat, *td\imageWidth, *td\imageHeight, 0, *td\imageFormat, #GL_UNSIGNED_BYTE, *td\pixels)
 glGenerateMipmap_(#GL_TEXTURE_2D)
 
 FreeImage(img)
 sgl::DestroyTexelData(*td)
 
 ProcedureReturn texid
EndProcedure

Procedure SetupData()
  Protected vbo, ibo

 Protected *vertex = sgl::StartData()   
  ; 3 * vertex_pos + 2 * texture_coord + 1 * texture_unit
  
  Data.f -1.0, -1.0,  1.0,   0.0, 0.0,   0.0 ; front 
  Data.f  1.0, -1.0,  1.0,   1.0, 0.0,   0.0
  Data.f  1.0,  1.0,  1.0,   1.0, 1.0,   0.0
  Data.f -1.0,  1.0,  1.0,   0.0, 1.0,   0.0
                  
  Data.f -1.0, -1.0, -1.0,   0.0, 1.0,   1.0 ; back 
  Data.f -1.0,  1.0, -1.0,   0.0, 0.0,   1.0
  Data.f  1.0,  1.0, -1.0,   1.0, 0.0,   1.0
  Data.f  1.0, -1.0, -1.0,   1.0, 1.0,   1.0
                  
  Data.f -1.0,  1.0, -1.0,   0.0, 1.0,   2.0 ; top
  Data.f -1.0,  1.0,  1.0,   0.0, 0.0,   2.0
  Data.f  1.0,  1.0,  1.0,   1.0, 0.0,   2.0
  Data.f  1.0,  1.0, -1.0,   1.0, 1.0,   2.0
                  
  Data.f -1.0, -1.0, -1.0,   0.0, 0.0,   3.0 ; bottom
  Data.f  1.0, -1.0, -1.0,   1.0, 0.0,   3.0
  Data.f  1.0, -1.0,  1.0,   1.0, 1.0,   3.0
  Data.f -1.0, -1.0,  1.0,   0.0, 1.0,   3.0
                  
  Data.f  1.0, -1.0, -1.0,   1.0, 0.0,   4.0 ; right
  Data.f  1.0,  1.0, -1.0,   1.0, 1.0,   4.0
  Data.f  1.0,  1.0,  1.0,   0.0, 1.0,   4.0
  Data.f  1.0, -1.0,  1.0,   0.0, 0.0,   4.0
                  
  Data.f -1.0, -1.0, -1.0,   0.0, 0.0,   5.0 ; left
  Data.f -1.0, -1.0,  1.0,   1.0, 0.0,   5.0
  Data.f -1.0,  1.0,  1.0,   1.0, 1.0,   5.0
  Data.f -1.0,  1.0, -1.0,   0.0, 1.0,   5.0
 sgl::StopData()
    
 ; using indices to draw a quad
 Protected *indices = sgl::StartData()
  Data.l  0,  1,  2,  2,  3,  0
  Data.l  4,  5,  6,  6,  7,  4
  Data.l  8,  9, 10, 10, 11,  8
  Data.l 12, 13, 14, 14, 15, 12
  Data.l 16, 17, 18, 18, 19, 16
  Data.l 20, 21, 22, 22, 23, 20
 sgl::StopData()
 
 ; vertex array
 glGenVertexArrays_(1, @gVao)
 glBindVertexArray_(gVao)
 
 ; vertex buffer
 glGenBuffers_(1, @vbo)
 glBindBuffer_(#GL_ARRAY_BUFFER, vbo)
 ; 24 vertices made by 6 floats each
 glBufferData_(#GL_ARRAY_BUFFER, 24 * 6 * SizeOf(Float), *vertex, #GL_STATIC_DRAW)

 glEnableVertexAttribArray_(0) ; point coords
 glVertexAttribPointer_(0, 3, #GL_FLOAT, #GL_FALSE, 6 * SizeOf(Float), 0)
 
 glEnableVertexAttribArray_(1) ; texture coords
 glVertexAttribPointer_(1, 2, #GL_FLOAT, #GL_FALSE, 6 * SizeOf(Float), 3 * SizeOf(Float))

 glEnableVertexAttribArray_(2) ; texture unit
 glVertexAttribPointer_(2, 1, #GL_FLOAT, #GL_FALSE, 6 * SizeOf(Float), 5 * SizeOf(Float))

 ; index buffer
 glGenBuffers_(1, @ibo)
 glBindBuffer_(#GL_ELEMENT_ARRAY_BUFFER, ibo)
 
 ; 36 indices made by 1 long each
 glBufferData_(#GL_ELEMENT_ARRAY_BUFFER, 36  * SizeOf(Long), *indices, #GL_STATIC_DRAW)

 glBindVertexArray_(0) ; we are done
 
 ; Textures
 
 gTextures(0) = BuildTex(0)
 gTextures(1) = BuildTex(1)
 gTextures(2) = BuildTex(2)
 gTextures(3) = BuildTex(3)
 gTextures(4) = BuildTex(4)
 gTextures(5) = BuildTex(5)
 
 ; Shaders
  
 Protected objects.sgl::ShaderObjects
 Protected vs, fs
 
 vs = sgl::CompileShaderFromFile("006.vs", #GL_VERTEX_SHADER) 
 sgl::AddShaderObject(@objects, vs) 
 ASSERT(vs)
 
 fs = sgl::CompileShaderFromFile("006.fs", #GL_FRAGMENT_SHADER) 
 sgl::AddShaderObject(@objects, fs) 
 ASSERT(fs)
 
 gShader = sgl::BuildShaderProgram(@objects) ; link and build the program using the specified shader objects 
 ASSERT(gShader)
  
 ; Timers
 
 gTimer = sgl::CreateTimer()

 ; Fonts 
 
 Dim ranges.sgl::BitmapFontRange(0)
 ; Latin (ascii)
 ranges(0)\firstChar  = 32
 ranges(0)\lastChar   = 128               
 gFon = RenderText::CreateBitmapFont("Arial", 10, #Null, ranges()) 
 ASSERT(gFon)
 
 Dim ranges.sgl::BitmapFontRange(0)
 ; Latin (ascii)
 ranges(0)\firstChar  = 32
 ranges(0)\lastChar   = 128               
 gFonHelp = RenderText::CreateBitmapFont("Consolas", 10, #PB_Font_Bold, ranges()) 
 ASSERT(gFonHelp)
  
EndProcedure

Procedure SetupContext() 
 sgl::RegisterErrorCallBack(@CallBack_Error())
 
 If sgl::Init()
     sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MAJOR, 3)
     sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MINOR, 3)
     sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_PROFILE, sgl::#PROFILE_CORE)     
     sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_DEBUG, 1)
           
     gWin = sgl::CreateWindow(#WIN_WIDTH, #WIN_HEIGHT, #TITLE$)
     
     If gWin
        sgl::MakeContextCurrent(gWin)
        
        sgl::RegisterWindowCallBack(gWin, sgl::#CALLBACK_WINDOW_REFRESH, @CallBack_WindowRefresh())     
     
        If gl_load::Load() = 0
            Debug gl_load::GetErrString()
        EndIf
     
        sgl::LoadExtensionsStrings()
         
        If sgl::IsDebugContext() = 0 Or sgl::EnableDebugOutput()  = 0 
            Debug "OpenGL debug output is not available !"
        EndIf   
             
        sgl::EnableVSYNC(#VSYNC)
        
        ProcedureReturn 
    EndIf
 EndIf
  
 sgl::Shutdown()
 
 End 
EndProcedure

Procedure ShutDown()
 sgl::DestroyTimer(gTimer)
 sgl::Shutdown()
EndProcedure

Procedure Render()
 Protected w, h, text$ 
 Protected delta.d
 Protected.m4x4::m4x4 model, projection, view
 Protected u_model, u_view, u_projection, u_texUnits
 
 Static firstRun = 1
 Static *camera.ArcBall::ArcBall
 
 If firstRun
    firstRun = 0   
    *camera = ArcBall::Create(gWin, 5.0)
 EndIf 
 
 Protected *units = sgl::StartData()
  Data.l 0, 1, 2, 3, 4, 5
 sgl::StopData()
 
 glClearColor_(0.25,0.25,0.5,1.0)
 glEnable_(#GL_DEPTH_TEST) 
 glClear_(#GL_COLOR_BUFFER_BIT | #GL_DEPTH_BUFFER_BIT)
  
 sgl::GetWindowFrameBufferSize (gWin, @w, @h)
 glViewport_(0, 0, w, h)

 delta = sgl::GetDeltaTime(gTimer)
 
 ; model
 m4x4::Identity(model)

 ; view
 ArcBall::Update(*camera, delta)
 
 m4x4::Copy( ArcBall::GetMatrix(*camera), view)
 
 ; projection
 m4x4::Perspective(projection, 60.0, Math::Float(w)/Math::Float(h), 0.1, 100.0)
  
 sgl::BindShaderProgram(gShader)
 
 u_model = sgl::GetUniformLocation(gShader, "u_model")
 sgl::SetUniformMatrix4x4(u_model, @model)
 
 u_view = sgl::GetUniformLocation(gShader, "u_view")
 sgl::SetUniformMatrix4x4(u_view, @view)
 
 u_projection = sgl::GetUniformLocation(gShader, "u_projection")
 sgl::SetUniformMatrix4x4(u_projection, @projection)

 u_texUnits = sgl::GetUniformLocation(gShader, "u_texUnits")
 sgl::SetUniformLongs(u_texUnits, *units, 6)
 
 glActiveTexture_(#GL_TEXTURE0)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(0))
 glActiveTexture_(#GL_TEXTURE1)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(1))
 glActiveTexture_(#GL_TEXTURE2)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(2))
 glActiveTexture_(#GL_TEXTURE3)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(3))
 glActiveTexture_(#GL_TEXTURE4)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(4))
 glActiveTexture_(#GL_TEXTURE5)
 glBindTexture_(#GL_TEXTURE_2D, gTextures(5))
 
 glBindVertexArray_(gVao)
 
 glDrawElements_(#GL_TRIANGLES, 36, #GL_UNSIGNED_INT, 0) ; 36 indices to build the quads 
  
 ; text info
 
 Protected x, y 
 Protected.vec3::vec3 color 
 
 ; top
 vec3::Set(color, 1.0, 1.0, 1.0)
 x = 1 : y = 0
 If sgl::GetFPS()    
    RenderText::Render(gWin, gFon, "FPS: " + sgl::GetFPS(), x, y, color)
 EndIf

 vec3::Set(color, 0.7, 0.8, 1.0)
 y + RenderText::GetFontHeight(gFonHelp) * 2.1
 text$ = "ArcBall            = Right Mouse Button" 
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)
 
 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = "ZOOM IN / OUT      = Mouse Wheel"
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)
 
 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = "Up/Down/Left/Right = Middle Button"
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)

 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = "RESET CAMERA       = R" 
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)

 y + RenderText::GetFontHeight(gFonHelp) * 1.5
 text$ = "ArcBall virtual (X,Y,Z)"
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)
 
 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = str::Sprintf("X = %6.3f", @*camera\sphere\x)
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)
 
 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = str::Sprintf("Y = %6.3f", @*camera\sphere\y)
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)

 y + RenderText::GetFontHeight(gFonHelp) * 1.1
 text$ = str::Sprintf("Z = %6.3f", @*camera\sphere\z)
 RenderText::Render(gWin, gFonHelp, text$, x, y, color)

 ; bottom
 vec3::Set(color, 1.0, 1.0, 1.0)
 x = 1 : y = h - RenderText::GetFontHeight(gFon)  
 text$ = sgl::GetRenderer()
 RenderText::Render(gWin, gFon, text$, x, y, color)
 
 sgl::SwapBuffers(gWin)
EndProcedure

Procedure MainLoop()

 While sgl::WindowShouldClose(gWin) = 0
 
    If sgl::GetKeyPress(sgl::#Key_ESCAPE)
        sgl::SetWindowShouldClose(gWin, 1)
    EndIf

    If sgl::GetKeyPress(sgl::#Key_V)
        gVSync ! 1
        sgl::EnableVSync(gVSync)
    EndIf
    
    If sgl::IsWindowMinimized(gWin) = 0
        Render()
        sgl::TrackFPS()
    EndIf     
   
    sgl::PollEvents()          
 Wend
EndProcedure

Procedure Main()
 SetupContext()
 SetupData()
 MainLoop()    
 ShutDown()
EndProcedure : Main()
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 3
; Folding = --
; EnableXP
; EnableUser
; Executable = C:\Users\luis\Desktop\Share\sgl\dubbioso.exe
; CPU = 1
; CompileSourceDirectory