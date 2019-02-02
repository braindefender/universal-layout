="utf8"
include "detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 0x0000000180000000 on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 0x80000000 on "nul" as "dll" ; Build for 32-bit Windows or WOW64
end if

MAKE_DLL equ 1

include "base.inc"

WOW64 = 0 ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)
NONE = WCH_NONE
DEAD = WCH_DEAD
LGTR = WCH_LGTR

section ".data" readable executable

keynames:
    dp 0x01, "Esc"
    dp 0x0E, "Backspace"
    dp 0x0F, "Tab"
    dp 0x1C, "Enter"
    dp 0x1D, "Ctrl"
    dp 0x2A, "Shift"
    dp 0x36, "Right Shift"
    dp 0x37, "Num *"
    dp 0x38, "Alt"
    dp 0x39, "Space"
    dp 0x3A, "Caps Lock"
    dp 0x3B, "F1"
    dp 0x3C, "F2"
    dp 0x3D, "F3"
    dp 0x3E, "F4"
    dp 0x3F, "F5"
    dp 0x40, "F6"
    dp 0x41, "F7"
    dp 0x42, "F8"
    dp 0x43, "F9"
    dp 0x44, "F10"
    dp 0x45, "Pause"
    dp 0x46, "Scroll Lock"
    dp 0x47, "Num 7"
    dp 0x48, "Num 8"
    dp 0x49, "Num 9"
    dp 0x4A, "Num -"
    dp 0x4B, "Num 4"
    dp 0x4C, "Num 5"
    dp 0x4D, "Num 6"
    dp 0x4E, "Num +"
    dp 0x4F, "Num 1"
    dp 0x50, "Num 2"
    dp 0x51, "Num 3"
    dp 0x52, "Num 0"
    dp 0x53, "Num Del"
    dp 0x54, "Sys Req"
    dp 0x57, "F11"
    dp 0x58, "F12"
    dp 0x7C, "F13"
    dp 0x7D, "F14"
    dp 0x7E, "F15"
    dp 0x7F, "F16"
    dp 0x80, "F17"
    dp 0x81, "F18"
    dp 0x82, "F19"
    dp 0x83, "F20"
    dp 0x84, "F21"
    dp 0x85, "F22"
    dp 0x86, "F23"
    dp 0x87, "F24"
    dp 0, 0

palign

keynamesExt:
    dp 0x1C, "Num Enter"
    dp 0x1D, "Right Ctrl"
    dp 0x35, "Num /"
    dp 0x37, "Prnt Scrn"
    dp 0x38, "Right Alt"
    dp 0x45, "Num Lock"
    dp 0x46, "Break"
    dp 0x47, "Home"
    dp 0x48, "Up"
    dp 0x49, "Page Up"
    dp 0x4B, "Left"
    dp 0x4D, "Right"
    dp 0x4F, "End"
    dp 0x50, "Down"
    dp 0x51, "Page Down"
    dp 0x52, "Insert"
    dp 0x53, "Delete"
    dp 0x54, "<00>"
    dp 0x56, "Help"
    dp 0x5B, "Left Windows"
    dp 0x5C, "Right Windows"
    dp 0x5D, "Application"
    dp 0, 0

palign

KbdTables:
    dp modifiers
    dp vk2wchar
    dp 0                ; Dead keys
    dp keynames         ; Names of keys
    dp keynamesExt
    dp 0                ; Names of dead keys
    dp scancode2vk      ; Scan codes to virtual keys
    db scancode2vk.size / 2
    palign
    dp e0scancode2vk
    dp e1scancode2vk
    dw KLLF_ALTGR       ; Locale flags
    dw KBD_VERSION
    db 0                ; Maximum ligature table characters
    db 0                ; Count of bytes in each ligature row
    palign
    dp 0
    dd 0x00000000       ; Type
    dd 0x00000000       ; Subtype (may contain OEM id)

palign

vk2bits:
    db VK_SHIFT, KBDSHIFT
    db VK_CONTROL, KBDCTRL
    db VK_MENU, KBDALT
    db 0, 0

palign

modifiers:
    dp vk2bits
    dw modifiers_max
.start:
    db 0x00         ; 1    ---- --- ---- -----
    db 0x01         ; 2    ---- --- ---- SHIFT
    db 0x04         ;      ---- --- CTRL -----
    db 0x05         ;      ---- --- CTRL SHIFT
    db SHFT_INVALID ;      ---- ALT ---- -----
    db SHFT_INVALID ;      ---- ALT ---- SHIFT
    db 0x02         ; 3    ---- ALT CTRL ----- (Alt+Ctrl = AltGr)
    db 0x03         ; 4    ---- ALT CTRL SHIFT (Alt+Ctrl = AltGr)
modifiers_max = $ - .start - 1

palign

vk2wchar1_3:
    vkrow3 VK_BACK      , 0                             , 0x08, 0x08, ""
    vkrow3 VK_ESCAPE    , 0                             , 0x1B, 0x1B, 0x1B
    vkrow3 VK_RETURN    , 0                             , 0x0D, 0x0D, 0x0A
    vkrow3 VK_CANCEL    , 0                             , 0x03, 0x03, 0x03
    dw 0, 0, 3 dup 0

palign

vk2wchar2_4:
    vkrow4 VK_GRAVE     , CAPLOK                        , "'" , '"' ,  "`",  "•"
    vkrow4 "1"          , 0                             , "!" , "1" ,  "¹",  "¡"
    vkrow4 "2"          , 0                             , '@' , '2' ,  "²",  "½"
    vkrow4 "3"          , 0                             , "#" , "3" ,  "³",  "⅓"
    vkrow4 "4"          , 0                             , "$" , "4" , NONE, NONE
    vkrow4 "5"          , 0                             , "%" , "5" ,  "‰", NONE
    vkrow4 "6"          , 0                             , "^" , "6" ,  "ˇ", NONE
    vkrow4 "7"          , 0                             , "?" , "7" ,  "¿", NONE
    vkrow4 "8"          , 0                             , "*" , "8" ,  "∞", NONE
    vkrow4 "9"          , 0                             , "(" , "9" ,  "‘",  "“"
    vkrow4 "0"          , 0                             , ")" , "0" ,  "’",  "”"
    vkrow4 VK_MINUS     , 0                             , "-" , "_" ,  "–",  "—"
    vkrow4 VK_EQUALS    , 0                             , "=" , "+" ,  "≠",  "±"
    vkrow4 "Q"          , CAPLOK                        , "q" , "Q" , NONE, NONE
    vkrow4 "W"          , CAPLOK                        , "w" , "W" , NONE, NONE
    vkrow4 "E"          , CAPLOK                        , "e" , "E" ,  "€", NONE
    vkrow4 "R"          , CAPLOK                        , "r" , "R" ,  "®", NONE
    vkrow4 "T"          , CAPLOK                        , "t" , "T" ,  "ё",  "Ё"
    vkrow4 "Y"          , CAPLOK                        , "y" , "Y" ,  "¥", NONE
    vkrow4 "U"          , CAPLOK                        , "u" , "U" ,  "ν", NONE
    vkrow4 "I"          , CAPLOK                        , "i" , "I" , NONE, NONE
    vkrow4 "O"          , CAPLOK                        , "o" , "O" ,  "∅",  "θ"
    vkrow4 "P"          , CAPLOK                        , "p" , "P" , NONE, NONE
    vkrow4 VK_LBRACKET  , CAPLOK                        , "[" , "{" ,  "[",  "{"
    vkrow4 VK_RBRACKET  , CAPLOK                        , "]" , "}" ,  "]",  "}"
    vkrow4 "A"          , CAPLOK                        , "a" , "A" ,  "α", NONE
    vkrow4 "S"          , CAPLOK                        , "s" , "S" , NONE, NONE
    vkrow4 "D"          , CAPLOK                        , "d" , "D" , NONE, NONE
    vkrow4 "F"          , CAPLOK                        , "f" , "F" ,  "£", NONE
    vkrow4 "G"          , CAPLOK                        , "g" , "G" , NONE, NONE
    vkrow4 "H"          , CAPLOK                        , "h" , "H" ,  "₽", NONE
    vkrow4 "J"          , CAPLOK                        , "j" , "J" , NONE, NONE
    vkrow4 "K"          , CAPLOK                        , "k" , "K" , NONE, NONE
    vkrow4 "L"          , CAPLOK                        , "l" , "L" , NONE, NONE
    vkrow4 VK_SEMICOLON , CAPLOK                        , "$" , "$" ,  "«",  "←"
    vkrow4 VK_APOSTROPHE, CAPLOK                        , "~" , "≈" ,  "»",  "→"
    vkrow4 VK_BACKSLASH , 0                             , "/" , "|" ,  "\", NONE
    vkrow4 VK_OEM_102   , 0                             , "/" , "|" ,  "\", NONE
    vkrow4 "Z"          , CAPLOK                        , "z" , "Z" , NONE, NONE
    vkrow4 "X"          , CAPLOK                        , "x" , "X" ,  "×", NONE
    vkrow4 "C"          , CAPLOK                        , "c" , "C" ,  "¢", NONE
    vkrow4 "V"          , CAPLOK                        , "v" , "V" ,  "√", NONE
    vkrow4 "B"          , CAPLOK                        , "b" , "B" ,  "β", NONE
    vkrow4 "N"          , CAPLOK                        , "n" , "N" , NONE, NONE
    vkrow4 "M"          , CAPLOK                        , "m" , "M" ,  "ъ",  "Ъ"
    vkrow4 VK_COMMA     , CAPLOK                        , "," , ";" ,  "<",  "≤"
    vkrow4 VK_PERIOD    , CAPLOK                        , "." , ":" ,  ">",  "≥"
    vkrow4 VK_SLASH     , 0                             , "&" , "&" ,  "&", "＆"
    vkrow4 VK_SPACE     , 0                             , " " , " " ,  " ",  " "
    vkrow4 VK_DECIMAL   , 0                             , "." , "," , NONE, NONE
    dw 0, 0, 4 dup 0

palign

vk2wchar4_1:
    vkrow1 VK_NUMPAD0   , 0                             , "0"
    vkrow1 VK_NUMPAD1   , 0                             , "1"
    vkrow1 VK_NUMPAD2   , 0                             , "2"
    vkrow1 VK_NUMPAD3   , 0                             , "3"
    vkrow1 VK_NUMPAD4   , 0                             , "4"
    vkrow1 VK_NUMPAD5   , 0                             , "5"
    vkrow1 VK_NUMPAD6   , 0                             , "6"
    vkrow1 VK_NUMPAD7   , 0                             , "7"
    vkrow1 VK_NUMPAD8   , 0                             , "8"
    vkrow1 VK_NUMPAD9   , 0                             , "9"
    dw 0, 0, 1 dup 0

palign

vk2wchar4_2:
    vkrow2 VK_TAB       , 0                             , 0x09, 0x09
    vkrow2 VK_ADD       , 0                             , "+" , "+"
    vkrow2 VK_DIVIDE    , 0                             , "/" , "/"
    vkrow2 VK_MULTIPLY  , 0                             , "*" , "*"
    vkrow2 VK_SUBTRACT  , 0                             , "-" , "-"
    dw 0, 0, 2 dup 0

palign

vk2wchar:
    dp vk2wchar1_3, 0x0803
    dp vk2wchar2_4, 0x0A04
    dp vk2wchar4_2, 0x0602
    dp vk2wchar4_1, 0x0401
    dp 0, 0

palign

e1scancode2vk:
    dw 0x001D, VK_PAUSE
    dw 0, 0

palign

e0scancode2vk:
    dw 0x0010, KBDEXT+VK_MEDIA_PREV_TRACK
    dw 0x0019, KBDEXT+VK_MEDIA_NEXT_TRACK
    dw 0x001D, KBDEXT+VK_RCONTROL
    dw 0x0020, KBDEXT+VK_VOLUME_MUTE
    dw 0x0021, KBDEXT+VK_LAUNCH_APP2
    dw 0x0022, KBDEXT+VK_MEDIA_PLAY_PAUSE
    dw 0x0024, KBDEXT+VK_MEDIA_STOP
    dw 0x002E, KBDEXT+VK_VOLUME_DOWN
    dw 0x0030, KBDEXT+VK_VOLUME_UP
    dw 0x0032, KBDEXT+VK_BROWSER_HOME
    dw 0x0035, KBDEXT+VK_DIVIDE
    dw 0x0037, KBDEXT+VK_SNAPSHOT
    dw 0x0038, KBDEXT+VK_RMENU
    dw 0x0047, KBDEXT+VK_HOME
    dw 0x0048, KBDEXT+VK_UP
    dw 0x0049, KBDEXT+VK_PGUP
    dw 0x004B, KBDEXT+VK_LEFT
    dw 0x004D, KBDEXT+VK_RIGHT
    dw 0x004F, KBDEXT+VK_END
    dw 0x0050, KBDEXT+VK_DOWN
    dw 0x0051, KBDEXT+VK_PGDN
    dw 0x0052, KBDEXT+VK_INSERT
    dw 0x0053, KBDEXT+VK_DELETE
    dw 0x005B, KBDEXT+VK_LWIN
    dw 0x005C, KBDEXT+VK_RWIN
    dw 0x005D, KBDEXT+VK_APPS
    dw 0x005F, KBDEXT+VK_SLEEP
    dw 0x0065, KBDEXT+VK_BROWSER_SEARCH
    dw 0x0066, KBDEXT+VK_BROWSER_FAVORITES
    dw 0x0067, KBDEXT+VK_BROWSER_REFRESH
    dw 0x0068, KBDEXT+VK_BROWSER_STOP
    dw 0x0069, KBDEXT+VK_BROWSER_FORWARD
    dw 0x006A, KBDEXT+VK_BROWSER_BACK
    dw 0x006B, KBDEXT+VK_LAUNCH_APP1
    dw 0x006C, KBDEXT+VK_LAUNCH_MAIL
    dw 0x006D, KBDEXT+VK_LAUNCH_MEDIA_SELECT
    dw 0x001C, KBDEXT+VK_RETURN
    dw 0x0046, KBDEXT+VK_CANCEL
    dw 0, 0

palign

scancode2vk: .:
    dw 0FFh
    dw VK_ESCAPE
    dw "1"
    dw "2"
    dw "3"
    dw "4"
    dw "5"
    dw "6"
    dw "7"
    dw "8"
    dw "9"
    dw "0"
    dw VK_MINUS
    dw VK_EQUALS
    dw VK_BACK
    dw VK_TAB
    dw "Q"
    dw "W"
    dw "E"
    dw "R"
    dw "T"
    dw "Y"
    dw "U"
    dw "I"
    dw "O"
    dw "P"
    dw VK_LBRACKET
    dw VK_RBRACKET
    dw VK_RETURN
    dw VK_LCONTROL
    dw "A"
    dw "S"
    dw "D"
    dw "F"
    dw "G"
    dw "H"
    dw "J"
    dw "K"
    dw "L"
    dw VK_SEMICOLON
    dw VK_APOSTROPHE
    dw VK_GRAVE
    dw VK_LSHIFT
    dw VK_BACKSLASH
    dw "Z"
    dw "X"
    dw "C"
    dw "V"
    dw "B"
    dw "N"
    dw "M"
    dw VK_COMMA
    dw VK_PERIOD
    dw VK_SLASH
    dw KBDEXT+VK_RSHIFT
    dw KBDMULTIVK+VK_MULTIPLY
    dw VK_LMENU
    dw VK_SPACE
    dw VK_CAPITAL
    dw VK_F1
    dw VK_F2
    dw VK_F3
    dw VK_F4
    dw VK_F5
    dw VK_F6
    dw VK_F7
    dw VK_F8
    dw VK_F9
    dw VK_F10
    dw KBDEXT+KBDMULTIVK+VK_NUMLOCK
    dw KBDMULTIVK+VK_SCROLL
    dw KBDSPECIAL+KBDNUMPAD+VK_HOME
    dw KBDSPECIAL+KBDNUMPAD+VK_UP
    dw KBDSPECIAL+KBDNUMPAD+VK_PGUP
    dw VK_SUBTRACT
    dw KBDSPECIAL+KBDNUMPAD+VK_LEFT
    dw KBDSPECIAL+KBDNUMPAD+VK_CLEAR
    dw KBDSPECIAL+KBDNUMPAD+VK_RIGHT
    dw VK_ADD
    dw KBDSPECIAL+KBDNUMPAD+VK_END
    dw KBDSPECIAL+KBDNUMPAD+VK_DOWN
    dw KBDSPECIAL+KBDNUMPAD+VK_PGDN
    dw KBDSPECIAL+KBDNUMPAD+VK_INSERT
    dw KBDSPECIAL+KBDNUMPAD+VK_DELETE
    dw VK_SNAPSHOT
    dw 0FFh
    dw VK_OEM_102
    dw VK_F11
    dw VK_F12
    dw VK_CLEAR
    dw VK_OEM_WSCTRL
    dw VK_OEM_FINISH
    dw VK_OEM_JUMP
    dw VK_EREOF
    dw VK_OEM_BACKTAB
    dw VK_OEM_AUTO
    dw 0FFh
    dw 0FFh
    dw VK_ZOOM
    dw VK_HELP
    dw VK_F13
    dw VK_F14
    dw VK_F15
    dw VK_F16
    dw VK_F17
    dw VK_F18
    dw VK_F19
    dw VK_F20
    dw VK_F21
    dw VK_F22
    dw VK_F23
    dw VK_OEM_PA3
    dw 0FFh
    dw VK_OEM_RESET
    dw 0FFh
    dw VK_ABNT_C1
    dw 0FFh
    dw 0FFh
    dw VK_F24
    dw 0FFh
    dw 0FFh
    dw 0FFh
    dw 0FFh
    dw VK_OEM_PA1
    dw VK_TAB
    dw 0FFh
    dw VK_ABNT_C2
.size = $ - .

palign

data export
export "kbdunieng.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
end data

palign

KbdLayerDescriptor:
if detected_32bit
    mov    eax,KbdTables
    cdq
else
    lea    rax,[KbdTables]
end if
    ret

palign

store_strings

section ".rsrc" data readable resource

directory RT_VERSION,versions
resource versions,1,LANG_NEUTRAL,version
versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_DRV_KEYBOARD,0,1200,\
    "CompanyName","Shirokov Nikita / @braindefender",\
    "FileDescription","Universal Layout English",\
    "FileVersion","1.0",\
    "InternalName","kbdunieng",\
    "LegalCopyright","Public domain. No rights reserved.",\
    "OriginalFilename","kbdunieng.dll",\
    "ProductName","Microsoft® Windows® Operating System",\
    "ProductVersion","1.0"

section ".reloc" data readable discardable fixups
