IncludeFile "../str.pb"

PI.f = 3.1415926535897931
Debug str::Sprintf("PI = [%0.3f]", @PI) 
Debug str::Sprintf("PI = [%-10.3f]", @PI) 
Debug str::Sprintf("PI = [%10.3f]", @PI) 
Debug str::Sprintf("PI = [%-0.2f]", @PI) 

s$ = "Hello"
Debug str::Sprintf("%'*-10s", @s$) 
Debug str::Sprintf("%'*10s", @s$) 

Debug str::PadRight("Hello", 10, "*")
Debug str::PadLeft("Hello", 10, "*")

Debug str::FormatQuad(12345678, ",")

Debug str::TrimEx("***foo***and***bar***", "*")

s$ = "Hello Crazy World !" : Dim a$(0) : Debug "ArraySize IN = " + ArraySize(a$()) : Debug s$
items = str::SplitToArray (s$, " ", a$()) : Debug "items = " + items
For i = 0 To items - 1
    Debug "a$(" + i + ") = " + a$(i)
Next
Debug "ArraySize OUT = " + ArraySize(a$())

s$ = "Hello Crazy World !" : Dim a$(10) : Debug "ArraySize IN = " + ArraySize(a$()) : Debug s$
items = str::SplitToArray (s$, " ", a$()) : Debug "items = " + items
For i = 0 To items - 1
    Debug "a$(" + i + ") = " + a$(i)
Next
Debug "ArraySize OUT = " + ArraySize(a$())

s$ = "Hello,,,World" : Dim a$(0) : Debug "ArraySize IN = " + ArraySize(a$()) : Debug s$
items = str::SplitToArray (s$, ",", a$()) : Debug "items = " + items
For i = 0 To items - 1
    Debug "a$(" + i + ") = " + a$(i)
Next
Debug "ArraySize OUT = " + ArraySize(a$())

q1.q = 123456789123456
Debug "Quad value = " + str::FormatQuad(q1)

bytes.d = Pow(1024, 3) * 32 
Debug "32 gigabytes = " + FormatNumber(bytes, 0)
Debug "IEC    = " + str::FormatBytes(bytes, str::#FormatBytes_IEC) 
Debug "Memory = " + str::FormatBytes(bytes, str::#FormatBytes_Memory)
Debug "Metric = " + str::FormatBytes(bytes, str::#FormatBytes_Metric)

; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 44
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory