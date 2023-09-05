﻿; How to sample and mix two textures in a fragment shader.
; The result is similar to the blending you could get in OpenGL, but done directly in the fragment shader.

EnableExplicit

IncludeFile "../sgl.pbi"
IncludeFile "../sgl.pb"

UseModule gl ; to get autocompletion in the IDE

Define Title$ = "How to sample and mix two textures in a fragment shader."

#VSYNC = 1

Procedure CallBack_Error (Source$, Desc$)
 Debug "[" + Source$ + "] " + Desc$
EndProcedure

Global gShader, gVao
 
Procedure.i BuildTex (img)
 Protected *td.sgl::TexelData
 Protected texid
   
 *td = sgl::CreateTexelData (img)
  
 glGenTextures_(1, @texid) 
 glBindTexture_(#GL_TEXTURE_2D, texid)
 
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_S, #GL_CLAMP_TO_EDGE)
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_WRAP_T, #GL_CLAMP_TO_EDGE) 
 
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
 glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
   
 glTexImage2D_(#GL_TEXTURE_2D, 0, *td\internalTextureFormat, *td\imageWidth, *td\imageHeight, 0, *td\imageFormat, #GL_UNSIGNED_BYTE, *td\pixels)
 
 FreeImage(img)
 
 sgl::DestroyTexelData(*td)
 
 ProcedureReturn texid
EndProcedure

Procedure Render (win)
 Protected w, h
 Protected elapsed.d
 Protected mix.f
 Protected u_Texture1, u_Texture2, u_Mixing
 
 #MIX_TIME_SECONDS = 3.0
 
 Static t1, dir = 1

 If t1 = 0
    t1 = sgl::CreateTimer()
 EndIf
  
 glClearColor_(0.1,0.1,0.25,1.0)
 glClear_(#GL_COLOR_BUFFER_BIT)
 
 sgl::GetWindowFrameBufferSize (win, @w, @h)
 
 glViewport_(0, 0, w, h)
 
 sgl::BindShaderProgram(gShader)
 
 u_Texture1 = sgl::GetUniformLocation(gShader, "u_Texture1")
 sgl::SetUniformLong(u_Texture1, 0) 

 u_Texture2 = sgl::GetUniformLocation(gShader, "u_Texture2")
 sgl::SetUniformLong(u_Texture2, 1) 
 
 elapsed = sgl::GetElapsedTime(t1)
 
 u_Mixing = sgl::GetUniformLocation(gShader, "u_Mixing")
  
 If dir = 1
    mix = elapsed / #MIX_TIME_SECONDS
 Else
    mix = (#MIX_TIME_SECONDS - elapsed) / #MIX_TIME_SECONDS
 EndIf
 
 sgl::SetUniformFloat(u_Mixing, mix)
 
 glBindVertexArray_(gVao)
 
 glDrawElements_(#GL_TRIANGLES, 6, #GL_UNSIGNED_INT, 0) 
 
 If elapsed > #MIX_TIME_SECONDS
    dir = - dir
    sgl::ResetTimer(t1)
 EndIf
EndProcedure

Procedure SetupShaders() 
 Protected vbo, ibo, texture1, texture2

 Protected *vertex = sgl::StartData()
  Data.f  -0.5,-0.5, 0.0, 0.0 ; 0
  Data.f   0.5,-0.5, 1.0, 0.0 ; 1
  Data.f   0.5, 0.5, 1.0, 1.0 ; 2 
  Data.f  -0.5, 0.5, 0.0, 1.0 ; 3
 sgl::StopData()

 ; using indices to draw a quad
 Protected *indices = sgl::StartData()
  Data.l 0, 1, 2, 2, 3, 0
 sgl::StopData()
 
 ; vertex array
 glGenVertexArrays_(1, @gVao)
 glBindVertexArray_(gVao)
 
 ; vertex buffer
 glGenBuffers_(1, @vbo)
 glBindBuffer_(#GL_ARRAY_BUFFER, vbo)
 ; 4 vertices made by 4 floats each
 glBufferData_(#GL_ARRAY_BUFFER, 4 * 4 * SizeOf(Float), *vertex, #GL_STATIC_DRAW)

 glEnableVertexAttribArray_(0) ; point coords
 glVertexAttribPointer_(0, 2, #GL_FLOAT, #GL_FALSE, 4 * SizeOf(Float), 0)
 
 glEnableVertexAttribArray_(1) ; texture coords
 glVertexAttribPointer_(1, 2, #GL_FLOAT, #GL_FALSE, 4 * SizeOf(Float), 2 * SizeOf(Float))

 ; index buffer
 glGenBuffers_(1, @ibo)
 glBindBuffer_(#GL_ELEMENT_ARRAY_BUFFER, ibo)
 ; 6 indices made by 1 long each
 glBufferData_(#GL_ELEMENT_ARRAY_BUFFER, 6 * SizeOf(Long), *indices, #GL_STATIC_DRAW)

 ; build textures
 glActiveTexture_(#GL_TEXTURE0)
 texture1 = BuildTex(sgl::CreateImage_Checkers(256, 256, 32, 32, RGB(255,255,255), RGB(0,0,0)))
  
 glActiveTexture_(#GL_TEXTURE1)
 texture2 = BuildTex(sgl::CreateImage_RGB(256, 256, 0))
 
 Protected objects.sgl::ShaderObjects
 Protected vs, fs
 
 vs = sgl::CompileShaderFromFile("024.vs", #GL_VERTEX_SHADER) 
 sgl::AddShaderObject(@objects, vs) 
 ASSERT(vs)
 
 fs = sgl::CompileShaderFromFile("024.fs", #GL_FRAGMENT_SHADER) 
 sgl::AddShaderObject(@objects, fs) 
 ASSERT(fs)
  
 gShader = sgl::BuildShaderProgram(@objects) ; link and build the program using the specified shader objects 
 ASSERT(gShader)
EndProcedure


Define win

sgl::RegisterErrorCallBack(@CallBack_Error())

If sgl::Init()        
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MAJOR, 3)
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_MINOR, 3)
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_PROFILE, sgl::#PROFILE_CORE)
    
    sgl::SetWindowHint(sgl::#HINT_WIN_OPENGL_DEBUG, 1)
            
    win = sgl::CreateWindow(640, 480, Title$)
    
    If win                
        sgl::MakeContextCurrent(win)        
        
        gl_load::Load()
        
        If sgl::IsDebugContext() = 0 Or sgl::EnableDebugOutput()  = 0 
            Debug "OpenGL debug output is not available !"
        EndIf   
             
        sgl::EnableVSYNC(#VSYNC)
                    
        SetupShaders()
        
        While sgl::WindowShouldClose(win) = 0
            Render(win)  
            sgl::SwapBuffers(win)
            sgl::PollEvents()
        Wend    
    EndIf    
    sgl::Shutdown()
EndIf
 
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 4
; FirstLine = 1
; Folding = -
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory