; Convenient and optimized import macros
; v1.00
; for flat assembler by Grom PE

; Usage:
; import kernel32.dll, lstrlenW, GlobalUnlock, GlobalLock, GlobalAlloc, GetCommandLineW
; import user32.dll, SetClipboardData, OpenClipboard, EmptyClipboard, CloseClipboard
; importend

macro import_part1 library, [api]
{
  common
    library#_str: db `library
  forward
    api#_str: db 0, 0, `api
  common
    db 0
}

import_part2_first = 0

macro import_part2 library, [api]
{
  common
    if import_part2_first = 0
      align 4
      import_part2_first = 1
    else
      dd 0
    end if
    library#_import:
  forward
    api dd rva api#_str
}

macro import_part3 [library]
{
  common
    data import
  forward
    dd 0, 0, 0, rva library#_str, rva library#_import
  common
    rd 5
    end data
}

import_list equ
import_libraries equ

macro import library,[api]
{
  common
    import_list equ import_list import_#library
    import_#library equ library,api
    import_libraries equ import_libraries,library
}
 
macro importend
{
  match a, import_list
  \{
    irps b, a \\{ match c, b \\\{ import_part1 c \\\} \\}
    irps b, a \\{ match c, b \\\{ import_part2 c \\\} \\}
  \}
  match =,a,import_libraries \{ import_part3 a \}
}
