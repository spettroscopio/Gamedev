IncludeFile "../logfile.pb"

Define file$, lf

Debug LogFile::GetProgramDirectory()

Debug LogFile::GetProgramName()

file$ = LogFile::GetProgramDirectory() + "logfile.test.txt" ; in the same directory of the process (portable apps only)

lf = LogFile::Open(file$, LogFile::#TimeStamp)

LogFile::Write(lf, "With time only.")
LogFile::Write(lf, "Hello World 1 !")
LogFile::Write(lf, "Hello World 2 !")
LogFile::Write(lf, "Hello World 3 !")

LogFile::Close(lf)

lf = LogFile::Open(file$, LogFile::#FileAppend)

LogFile::Write(lf, "Appending ... just text")
LogFile::Write(lf, "Hello World 1 !")
LogFile::Write(lf, "Hello World 2 !")
LogFile::Write(lf, "Hello World 3 !")

LogFile::Close(lf)

lf = LogFile::Open(file$, LogFile::#FileAppend | LogFile::#DateStamp | LogFile::#TimeStamp)

LogFile::Write(lf, "Appending ... with date and time.")
LogFile::Write(lf, "Hello World 1 !")
LogFile::Write(lf, "Hello World 2 !")
LogFile::Write(lf, "Hello World 3 !")

LogFile::Close(lf)
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 21
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory
; EnablePurifier
; EnableExeConstant