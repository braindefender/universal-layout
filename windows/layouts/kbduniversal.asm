="utf8"

include "detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 5ffffff0000h on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 5fff0000h on "nul" as "dll" ; Build for 32-bit Windows or WOW64
end if

MAKE_DLL equ 1

include "base.inc"

WOW64 = 0
USE_LIGATURES = 1
DEBUG = 0

section ".data" readable executable

keynames:
    dp 01h, "ESC"
    dp 0Eh, "BACKSPACE"
    dp 0Fh, "TAB"
    dp 1Ch, "ENTER"
    dp 1Dh, "CTRL"
    dp 2Ah, "SHIFT"
    dp 36h, "RIGHT SHIFT"
    dp 37h, "NUMMULT"
    dp 38h, "ALT"
    dp 39h, "SPACE"
    dp 3Ah, "CAPSLOCK"
    dp 3Bh, "F1"
    dp 3Ch, "F2"
    dp 3Dh, "F3"
    dp 3Eh, "F4"
    dp 3Fh, "F5"
    dp 40h, "F6"
    dp 41h, "F7"
    dp 42h, "F8"
    dp 43h, "F9"
    dp 44h, "F10"
    dp 45h, "Pause"
    dp 46h, "SCROLL LOCK"
    dp 47h, "NUM 7"
    dp 48h, "NUM 8"
    dp 49h, "NUM 9"
    dp 4Ah, "NUM SUB"
    dp 4Bh, "NUM 4"
    dp 4Ch, "NUM 5"
    dp 4Dh, "NUM 6"
    dp 4Eh, "NUM PLUS"
    dp 4Fh, "NUM 1"
    dp 50h, "NUM 2"
    dp 51h, "NUM 3"
    dp 52h, "NUM 0"
    dp 53h, "NUM DECIMAL"
    dp 57h, "F11"
    dp 58h, "F12"
    dp 0, 0

palign

keynamesExt:
    dp 1Ch, "NUM ENTER"
    dp 1Dh, "Right Ctrl"
    dp 35h, "NUM DIVIDE"
    dp 37h, "Prnt Scrn"
    dp 38h, "RIGHT ALT"
    dp 45h, "Num Lock"
    dp 46h, "Break"
    dp 47h, "HOME"
    dp 48h, "UP"
    dp 49h, "PGUP"
    dp 4Bh, "LEFT"
    dp 4Dh, "RIGHT"
    dp 4Fh, "END"
    dp 50h, "DOWN"
    dp 51h, "PGDOWN"
    dp 52h, "INSERT"
    dp 53h, "DELETE"
    dp 54h, "<00>"
    dp 56h, "Help"
    dp 5Bh, "Left Windows"
    dp 5Ch, "Right Windows"
    dp 5Dh, "Application"
    dp 0, 0

palign

if used ligatures
ligatures: .:
    dw VK_SLASH ; VKey
    dw 3   ; Modifiers; Shift + AltGr; basically is the column number in vk2wchar* tables that contains WCH_LGTR
    du "/me " ; If less than max characters are used, the rest must be filled with WCH_NONE
ligature_size = $ - .

if DEBUG
    dw VK_CLEAR ; VKey
    dw 0        ; Modifiers
    du "v05."
end if
    db ligatureEntry dup 0

palign
end if

if USE_LIGATURES
  ligatureMaxChars = (ligature_size - 4) / 2
  if ligatureMaxChars > 4
    err "4 characters is max for a ligature on Windows XP or if you use Firefox"
  end if
  ligatureEntry = ligature_size
  ligatures_if_used = ligatures
else
  ligatureMaxChars = 0
  ligatureEntry = 0
  ligatures_if_used = 0
end if

KbdTables:
    dp modifiers
    dp vk2wchar
    dp keynames         ; Names of keys
    dp keynamesExt
    dp scancode2vk      ; Scan codes to virtual keys
    db scancode2vk.size / 2
    palign
    dp e0scancode2vk
    dp e1scancode2vk
    dw KLLF_ALTGR       ; Locale flags
    dw KBD_VERSION
    db ligatureMaxChars ; Maximum ligature table characters
    db ligatureEntry    ; Count of bytes in each ligature row
    palign
    dp ligatures_if_used
    dd 0, 0             ; Type, subtype

palign

vk2bits:
    db VK_SHIFT,   KBDSHIFT
    db VK_CONTROL, KBDCTRL
    db VK_MENU,    KBDALT
    db 0, 0

palign

modifiers:
    dp vk2bits
    dw modifiers_max
.start:
    db 0x00            ; 1 ---- --- ---- -----
    db 0x01            ; 2 ---- --- ---- SHIFT
    db 0x04            ;   ---- --- CTRL -----
    db 0x05            ;   ---- --- CTRL SHIFT
    db SHFT_INVALID    ;   ---- ALT ---- -----
    db SHFT_INVALID    ;   ---- ALT ---- SHIFT
    db 0x02            ; 3 ---- ALT CTRL ----- (Alt+Ctrl = AltGr)
    db 0x03            ; 4 ---- ALT CTRL SHIFT (Alt+Ctrl = AltGr)
modifiers_max = $ - .start - 1

palign

vk2wchar1:
if DEBUG
    vkrow1 VK_CLEAR,   0, WCH_LGTR
end if
    vkrow1 VK_NUMPAD0, 0, "0"
    vkrow1 VK_NUMPAD1, 0, "1"
    vkrow1 VK_NUMPAD2, 0, "2"
    vkrow1 VK_NUMPAD3, 0, "3"
    vkrow1 VK_NUMPAD4, 0, "4"
    vkrow1 VK_NUMPAD5, 0, "5"
    vkrow1 VK_NUMPAD6, 0, "6"
    vkrow1 VK_NUMPAD7, 0, "7"
    vkrow1 VK_NUMPAD8, 0, "8"
    vkrow1 VK_NUMPAD9, 0, "9"
    dw 0, 0, 1 dup 0

palign

vk2wchar2:
    vkrow2 VK_DECIMAL,  SGCAPS, ".", "."
    vkrow2 VK_DECIMAL,  0,      ",", ","
    vkrow2 VK_TAB,      0,      9,   9
    vkrow2 VK_ADD,      0,      "+", "+"
    vkrow2 VK_DIVIDE,   0,      "/", "/"
    vkrow2 VK_MULTIPLY, 0,      "*", "*"
    vkrow2 VK_SUBTRACT, 0,      "-", "-"
    dw 0, 0, 2 dup 0

palign

vk2wchar4:
    vkrow4 VK_GRAVE,      SGCAPS, "'",      '"',      "`",      "•"
    vkrow4 VK_GRAVE,      0,      "'",      '"',      "`",      "•"
    vkrow4 "1",           SGCAPS, "!",      "1",      "¹",      "¡"
    vkrow4 "1",           0,      "!",      "1",      "¹",      "¡"
    vkrow4 "2",           SGCAPS, "@",      "2",      "²",      "½"
    vkrow4 "2",           0,      "@",      "2",      "²",      "½"
    vkrow4 "3",           SGCAPS, "#",      "3",      "³",      "⅓"
    vkrow4 "3",           0,      "#",      "3",      "³",      "⅓"
    vkrow4 "4",           SGCAPS, "$",      "4",      WCH_NONE, WCH_NONE
    vkrow4 "4",           0,      "$",      "4",      WCH_NONE, WCH_NONE
    vkrow4 "5",           SGCAPS, "%",      "5",      "‰",      WCH_NONE
    vkrow4 "5",           0,      "%",      "5",      "‰",      WCH_NONE
    vkrow4 "6",           SGCAPS, "^",      "6",      "ˇ",      WCH_NONE
    vkrow4 "6",           0,      "^",      "6",      "ˇ",      WCH_NONE
    vkrow4 "7",           SGCAPS, "?",      "7",      "¿",      WCH_NONE
    vkrow4 "7",           0,      "?",      "7",      "¿",      WCH_NONE
    vkrow4 "8",           SGCAPS, "*",      "8",      "∞",      "„"
    vkrow4 "8",           0,      "*",      "8",      "∞",      "„"
    vkrow4 "9",           SGCAPS, "(",      "9",      "‘",      "“"
    vkrow4 "9",           0,      "(",      "9",      "‘",      "“"
    vkrow4 "0",           SGCAPS, ")",      "0",      "’",      "”"
    vkrow4 "0",           0,      ")",      "0",      "’",      "”"
    vkrow4 VK_MINUS,      0,      "-",      "_",      "–",      "—"
    vkrow4 VK_EQUALS,     0,      "=",      "+",      "≠",      "±"
    vkrow4 "Q",           SGCAPS, "q",      "Q",      WCH_NONE, WCH_NONE
    vkrow4 "Q",           0,      "й",      "Й",      WCH_NONE, WCH_NONE
    vkrow4 "W",           SGCAPS, "w",      "W",      WCH_NONE, WCH_NONE
    vkrow4 "W",           0,      "ц",      "Ц",      WCH_NONE, WCH_NONE
    vkrow4 "E",           SGCAPS, "e",      "E",      "€",      WCH_NONE
    vkrow4 "E",           0,      "у",      "У",      "€",      WCH_NONE
    vkrow4 "R",           SGCAPS, "r",      "R",      WCH_NONE, WCH_NONE
    vkrow4 "R",           0,      "к",      "К",      "r",      "R"
    vkrow4 "T",           SGCAPS, "t",      "T",      WCH_NONE, WCH_NONE
    vkrow4 "T",           0,      "е",      "Е",      "t",      "T"
    vkrow4 "Y",           SGCAPS, "y",      "Y",      WCH_NONE, WCH_NONE
    vkrow4 "Y",           0,      "н",      "Н",      "y",      "Y"
    vkrow4 "U",           SGCAPS, "u",      "U",      WCH_NONE, WCH_NONE
    vkrow4 "U",           0,      "г",      "Г",      "u",      "U"
    vkrow4 "I",           SGCAPS, "i",      "I",      WCH_NONE, WCH_NONE
    vkrow4 "I",           0,      "ш",      "Ш",      "i",      "I"
    vkrow4 "O",           SGCAPS, "o",      "O",      WCH_NONE, WCH_NONE
    vkrow4 "O",           0,      "щ",      "Щ",      "o",      "O"
    vkrow4 "P",           SGCAPS, "p",      "P",      WCH_NONE, WCH_NONE
    vkrow4 "P",           0,      "з",      "З",      "p",      "P"
    vkrow4 "A",           SGCAPS, "a",      "A",      WCH_NONE, WCH_NONE
    vkrow4 "A",           0,      "ф",      "Ф",      "a",      "A"
    vkrow4 "S",           SGCAPS, "s",      "S",      WCH_NONE, WCH_NONE
    vkrow4 "S",           0,      "ы",      "Ы",      "s",      "S"
    vkrow4 "D",           SGCAPS, "d",      "D",      WCH_NONE, WCH_NONE
    vkrow4 "D",           0,      "в",      "В",      "d",      "D"
    vkrow4 "F",           SGCAPS, "f",      "F",      WCH_NONE, WCH_NONE
    vkrow4 "F",           0,      "а",      "А",      "f",      "F"
    vkrow4 "G",           SGCAPS, "g",      "G",      WCH_NONE, WCH_NONE
    vkrow4 "G",           0,      "п",      "П",      "g",      "G"
    vkrow4 "H",           SGCAPS, "h",      "H",      WCH_NONE, WCH_NONE
    vkrow4 "H",           0,      "р",      "Р",      "h",      "H"
    vkrow4 "J",           SGCAPS, "j",      "J",      WCH_NONE, WCH_NONE
    vkrow4 "J",           0,      "о",      "О",      "j",      "J"
    vkrow4 "K",           SGCAPS, "k",      "K",      WCH_NONE, WCH_NONE
    vkrow4 "K",           0,      "л",      "Л",      "k",      "K"
    vkrow4 "L",           SGCAPS, "l",      "L",      WCH_NONE, WCH_NONE
    vkrow4 "L",           0,      "д",      "Д",      "l",      "L"
    vkrow4 VK_SEMICOLON,  SGCAPS, ";",      ":",      "°",      "¶"
    vkrow4 -1,            0,      "ж",      "Ж",      WCH_NONE, WCH_NONE
    vkrow4 VK_APOSTROPHE, SGCAPS, "'",      '"',      "'",      "́" ; combining acute
    vkrow4 -1,            0,      "э",      'Э',      WCH_NONE, WCH_NONE
    vkrow4 "Z",           SGCAPS, "z",      "Z",      WCH_NONE, WCH_NONE
    vkrow4 "Z",           0,      "я",      "Я",      "z",      "Z"
    vkrow4 "X",           SGCAPS, "x",      "X",      WCH_NONE, WCH_NONE
    vkrow4 "X",           0,      "ч",      "Ч",      "x",      "X"
    vkrow4 "C",           SGCAPS, "c",      "C",      WCH_NONE, WCH_NONE
    vkrow4 "C",           0,      "с",      "С",      "c",      "C"
    vkrow4 "V",           SGCAPS, "v",      "V",      WCH_NONE, WCH_NONE
    vkrow4 "V",           0,      "м",      "М",      "v",      "V"
    vkrow4 "B",           SGCAPS, "b",      "B",      WCH_NONE, WCH_NONE
    vkrow4 "B",           0,      "и",      "И",      "b",      "B"
    vkrow4 "N",           SGCAPS, "n",      "N",      WCH_NONE, WCH_NONE
    vkrow4 "N",           0,      "т",      "Т",      "n",      "N"
    vkrow4 "M",           SGCAPS, "m",      "M",      WCH_NONE, WCH_NONE
    vkrow4 "M",           0,      "ь",      "Ь",      "m",      "M"
    vkrow4 VK_COMMA,      SGCAPS, ",",      "<",      "<",      "←"
    vkrow4 -1,            0,      "б",      "Б",      WCH_NONE, WCH_NONE
    vkrow4 VK_PERIOD,     SGCAPS, ".",      ">",      ">",      "→"
    vkrow4 -1,            0,      "ю",      "Ю",      WCH_NONE, WCH_NONE
    vkrow4 VK_SLASH,      SGCAPS, "/",      "?",      "¿",      WCH_LGTR
    vkrow4 VK_SLASH,      0,      ".",      ",",      WCH_NONE, WCH_NONE
    dw 0, 0, 4 dup 0

palign

vk2wchar5:
    vkrow5 VK_LBRACKET,  SGCAPS, "[", "{", "[",      "{",      01Bh
    vkrow5 VK_LBRACKET,  0,      "х", "Х", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_RBRACKET,  SGCAPS, "]", "}", "]",      "}",      01Dh
    vkrow5 VK_RBRACKET,  0,      "ъ", "Ъ", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_BACKSLASH, SGCAPS, "\", "|", "|",      "¬",      01Ch
    vkrow5 VK_BACKSLASH, 0,      "\", "/", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_OEM_102,   0,      "\", "|", WCH_NONE, WCH_NONE, 01Ch
    vkrow5 VK_BACK,      0,      8,   8,   WCH_NONE, WCH_NONE, 07Fh
    vkrow5 VK_ESCAPE,    0,      27,  27,  WCH_NONE, WCH_NONE, 01Bh
    vkrow5 VK_RETURN,    0,      13,  13,  WCH_NONE, WCH_NONE, 10
    vkrow5 VK_SPACE,     0,      " ", " ", " ",      WCH_NONE, " "
    vkrow5 VK_CANCEL,    0,      3,   3,   WCH_NONE, WCH_NONE, 3
    dw 0, 0, 5 dup 0

palign

vk2wchar:
    dp vk2wchar1, 0x0401
    dp vk2wchar2, 0x0602
    dp vk2wchar4, 0x0A04
    dp vk2wchar5, 0x0C05
    dp 0, 0

palign

e1scancode2vk:
    dw 0x001D, VK_PAUSE
    dw 0, 0

palign

; On scancodes, see: https://www.win.tue.nl/~aeb/linux/kbd/scancodes.html

e0scancode2vk:
    dw 10h, KBDEXT + VK_MEDIA_PREV_TRACK
    dw 19h, KBDEXT + VK_MEDIA_NEXT_TRACK
    dw 1Ch, KBDEXT + VK_RETURN
    dw 1Dh, KBDEXT + VK_RCONTROL
    dw 20h, KBDEXT + VK_VOLUME_MUTE
    dw 21h, KBDEXT + VK_LAUNCH_APP2
    dw 22h, KBDEXT + VK_MEDIA_PLAY_PAUSE
    dw 24h, KBDEXT + VK_MEDIA_STOP
    dw 2Eh, KBDEXT + VK_VOLUME_DOWN
    dw 30h, KBDEXT + VK_VOLUME_UP
    dw 32h, KBDEXT + VK_BROWSER_HOME
    dw 35h, KBDEXT + VK_DIVIDE
    dw 37h, KBDEXT + VK_SNAPSHOT
    dw 38h, KBDEXT + VK_RMENU
    dw 46h, KBDEXT + VK_CANCEL
    dw 47h, KBDEXT + VK_HOME
    dw 48h, KBDEXT + VK_UP
    dw 49h, KBDEXT + VK_PGUP
    dw 4Bh, KBDEXT + VK_LEFT
    dw 4Dh, KBDEXT + VK_RIGHT
    dw 4Fh, KBDEXT + VK_END
    dw 50h, KBDEXT + VK_DOWN
    dw 51h, KBDEXT + VK_NEXT
    dw 52h, KBDEXT + VK_INSERT
    dw 53h, KBDEXT + VK_DELETE
    dw 5Bh, KBDEXT + VK_LWIN
    dw 5Ch, KBDEXT + VK_RWIN
    dw 5Dh, KBDEXT + VK_APPS
    dw 5Eh, KBDEXT + VK_POWER ; You can reassign these two, but they also do
    dw 5Fh, KBDEXT + VK_SLEEP ; their original action unless disabled elsewhere
;    dw 63h, 0FFh ; WakeUp button
    dw 65h, KBDEXT + VK_BROWSER_SEARCH
    dw 66h, KBDEXT + VK_BROWSER_FAVORITES
    dw 67h, KBDEXT + VK_BROWSER_REFRESH
    dw 68h, KBDEXT + VK_BROWSER_STOP
    dw 69h, KBDEXT + VK_BROWSER_FORWARD
    dw 6Ah, KBDEXT + VK_BROWSER_BACK
    dw 6Bh, KBDEXT + VK_LAUNCH_APP1
    dw 6Ch, KBDEXT + VK_LAUNCH_MAIL
    dw 6Dh, KBDEXT + VK_LAUNCH_MEDIA_SELECT
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
export "kbduniversal.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
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

section '.rsrc' data readable resource

directory RT_VERSION,versions
resource versions,1,LANG_NEUTRAL,version
versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_DRV_KEYBOARD,0,1200,\
    'CompanyName','by braindefender',\
    'FileDescription','Universal EN / RU Layout',\
    'FileVersion','1.0',\
    'InternalName','kbduniversal',\
    'LegalCopyright','Public domain. No rights reserved.',\
    'OriginalFilename','kbduniversal.dll',\
    'ProductName','kbdasm',\
    'ProductVersion','1.0'

section '.reloc' data readable discardable fixups
