IncludeFile "../std.pb"

Debug std::#MIN_INTEGER
Debug std::#MAX_INTEGER
Debug std::#MIN_LONG
Debug std::#MAX_LONG
Debug std::#MIN_QUAD
Debug std::#MAX_QUAD

Debug Hex(std::ALIGN($7fff, 4))
Debug Hex(std::ALIGN($8000, 4))

Debug Hex(std::HiWord($F00DBEEF))
Debug Hex(std::LoWord($F00DBEEF))
Debug Hex(std::HiByte($ACDC))
Debug Hex(std::LoByte($ACDC))

Debug std::IIF (#True, 1, 2) + std::IIF (#False, 1, 2)
Debug std::IIFq (#True, 1, 2) + std::IIFq (#False, 1, 2)
Debug std::IIFf (#True, 1.0, 2.0) + std::IIFf (#False, 1.0, 2.0)
Debug std::IIFs (#True, "1", "2") + std::IIFs (#False, "1", "2")


; IDE Options = PureBasic 6.01 LTS beta 3 (Windows - x86)
; EnableXP
; EnableUser
; CPU = 1
; CompileSourceDirectory