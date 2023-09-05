﻿; With this little program you can create BMF files from an image containing a bitmap font in strip form and a text file.
; See gimp-font\gimp-42.png and gimp-font\gimp-42.txt

EnableExplicit

IncludeFile "../../sgl.pbi"
IncludeFile "../../sgl.pb"


; strip image to be converted to BMF
#BITMAP_STRIP$      = "./gimp-font/gimp-42.png"
#FONT_SIZE          = 42

; the name of the resulting BMF
#BMF_FILE_DIR$      = "./bmf/"
#BMF_FILE_NAME$     = "gimp-" + #FONT_SIZE
#BMF_FILE_EXT$      = ".zip"

If sgl::Init()
    Define *bmf.sgl::BitmapFontData
    
    Define out$ = #BMF_FILE_DIR$ + #BMF_FILE_NAME$ + #BMF_FILE_EXT$
         
    *bmf = sgl::CreateBitmapFontDataFromStrip (#BITMAP_STRIP$, #FONT_SIZE, 384, 384, 2)
    
    If *bmf = 0
        Debug "Bitmap too small ..."
        Goto exit
    EndIf
       
    If sgl::SaveBitmapFontData(out$, *bmf)
        Debug "Saved to " + out$
    Else
        Debug "Something went wrong ..."
    EndIf
    
    sgl::DestroyBitmapFontData(*bmf)
exit:    
    sgl::Shutdown()
EndIf
 
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 4
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory