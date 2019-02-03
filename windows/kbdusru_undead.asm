="utf8"
; kbdasm by Grom PE. Public domain.
; kbdusru_undead - US/RU hybrid keyboard layout with Caps Lock set to switch
;                  languages and "undead keys" for additional symbols

include "detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 5ffffff0000h on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 5fff0000h on "nul" as "dll" ; Build for 32-bit Windows or WOW64
end if

MAKE_DLL equ 1

include "base.inc"

WOW64 = 0 ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)
USE_LIGATURES = 1 ; There is a bug in Firefox, if ligatures contain more than
                  ; 4 characters, it won't start up if that layout is default;
                  ; if the layout is switched to, Firefox then hangs.
                  ; See also:
                  ; http://www.unicode.org/mail-arch/unicode-ml/y2015-m08/0012.html
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

keynamesDead:
    dp "´ACUTE"
    dp "˝DOUBLE ACUTE"
    dp "`GRAVE"
    dp "^CIRCUMFLEX"
    dp '¨UMLAUT'
    dp "~TILDE"
    dp "ˇCARON"
    dp "°RING"
    dp "¸CEDILLA"
    dp "¯MACRON"
    dp 0

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
;  if ligatureMaxChars > 16
;    err "16 characters is max for a ligature on Windows 7"
;  end if
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
    dp deadkeys
    dp keynames         ; Names of keys
    dp keynamesExt
    dp keynamesDead
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
    db 0            ; ---- --- ---- -----
    db 1            ; ---- --- ---- SHIFT
    db 4            ; ---- --- CTRL -----
    db 5            ; ---- --- CTRL SHIFT
    db SHFT_INVALID ; ---- ALT ---- -----
    db SHFT_INVALID ; ---- ALT ---- SHIFT
    db 2            ; ---- ALT CTRL ----- (Alt+Ctrl = AltGr)
    db 3            ; ---- ALT CTRL SHIFT
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
    dw 0, 0, 0

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
    vkrow4 VK_GRAVE,      SGCAPS, "`",      "~",      "`",      "~"
    vkrow4 -1,            0,      "ё",      "Ё",      WCH_NONE, WCH_NONE
    vkrow4 "1",           SGCAPS, "1",      "!",      "¡",      "¹"
    vkrow4 "1",           0,      "1",      "!",      WCH_NONE, WCH_NONE
    vkrow4 "2",           SGCAPS, "2",      "@",      "@",      "²"
    vkrow4 "2",           0,      "2",      '"',      WCH_NONE, WCH_NONE
    vkrow4 "3",           SGCAPS, "3",      "#",      "#",      "³"
    vkrow4 "3",           0,      "3",      "№",      WCH_NONE, WCH_NONE
    vkrow4 "4",           SGCAPS, "4",      "$",      "$",      "£"
    vkrow4 "4",           0,      "4",      ";",      WCH_NONE, WCH_NONE
    vkrow4 "5",           SGCAPS, "5",      "%",      "€",      "‰"
    vkrow4 "5",           0,      "5",      "%",      WCH_NONE, WCH_NONE
    vkrow4 "6",           SGCAPS, "6",      "^",      "^",      "↑"
    vkrow4 -1,            0,      "6",      ":",      WCH_NONE, WCH_NONE
    vkrow4 "7",           SGCAPS, "7",      "&",      "&",      "＆"
    vkrow4 "7",           0,      "7",      "?",      WCH_NONE, WCH_NONE
    vkrow4 "8",           SGCAPS, "8",      "*",      "∞",      "×"
    vkrow4 "8",           0,      "8",      "*",      WCH_NONE, WCH_NONE
    vkrow4 "9",           SGCAPS, "9",      "(",      "«",      "“"
    vkrow4 "9",           0,      "9",      "(",      WCH_NONE, WCH_NONE
    vkrow4 "0",           SGCAPS, "0",      ")",      "»",      "”"
    vkrow4 "0",           0,      "0",      ")",      WCH_NONE, WCH_NONE
    vkrow4 VK_MINUS,      0,      "-",      "_",      "—",      "–"
    vkrow4 VK_EQUALS,     0,      "=",      "+",      "≠",      "±"
    vkrow4 "Q",           SGCAPS, "q",      "Q",      WCH_DEAD, WCH_DEAD
    vkrow4 "Q",           0,      "й",      "Й",      "q",      "Q"
    vkrow4 "W",           SGCAPS, "w",      "W",      WCH_DEAD, WCH_DEAD
    vkrow4 "W",           0,      "ц",      "Ц",      "w",      "W"
    vkrow4 "E",           SGCAPS, "e",      "E",      WCH_DEAD, WCH_DEAD
    vkrow4 "E",           0,      "у",      "У",      "e",      "E"
    vkrow4 "R",           SGCAPS, "r",      "R",      WCH_DEAD, WCH_DEAD
    vkrow4 "R",           0,      "к",      "К",      "r",      "R"
    vkrow4 "T",           SGCAPS, "t",      "T",      WCH_DEAD, WCH_DEAD
    vkrow4 "T",           0,      "е",      "Е",      "t",      "T"
    vkrow4 "Y",           SGCAPS, "y",      "Y",      WCH_DEAD, WCH_DEAD
    vkrow4 "Y",           0,      "н",      "Н",      "y",      "Y"
    vkrow4 "U",           SGCAPS, "u",      "U",      WCH_DEAD, WCH_DEAD
    vkrow4 "U",           0,      "г",      "Г",      "u",      "U"
    vkrow4 "I",           SGCAPS, "i",      "I",      WCH_DEAD, WCH_DEAD
    vkrow4 "I",           0,      "ш",      "Ш",      "i",      "I"
    vkrow4 "O",           SGCAPS, "o",      "O",      WCH_DEAD, WCH_DEAD
    vkrow4 "O",           0,      "щ",      "Щ",      "o",      "O"
    vkrow4 "P",           SGCAPS, "p",      "P",      WCH_DEAD, WCH_DEAD
    vkrow4 "P",           0,      "з",      "З",      "p",      "P"
    vkrow4 "A",           SGCAPS, "a",      "A",      WCH_DEAD, WCH_DEAD
    vkrow4 "A",           0,      "ф",      "Ф",      "a",      "A"
    vkrow4 "S",           SGCAPS, "s",      "S",      WCH_DEAD, WCH_DEAD
    vkrow4 "S",           0,      "ы",      "Ы",      "s",      "S"
    vkrow4 "D",           SGCAPS, "d",      "D",      WCH_DEAD, WCH_DEAD
    vkrow4 "D",           0,      "в",      "В",      "d",      "D"
    vkrow4 "F",           SGCAPS, "f",      "F",      WCH_DEAD, WCH_DEAD
    vkrow4 "F",           0,      "а",      "А",      "f",      "F"
    vkrow4 "G",           SGCAPS, "g",      "G",      WCH_DEAD, WCH_DEAD
    vkrow4 "G",           0,      "п",      "П",      "g",      "G"
    vkrow4 "H",           SGCAPS, "h",      "H",      WCH_DEAD, WCH_DEAD
    vkrow4 "H",           0,      "р",      "Р",      "h",      "H"
    vkrow4 "J",           SGCAPS, "j",      "J",      WCH_DEAD, WCH_DEAD
    vkrow4 "J",           0,      "о",      "О",      "j",      "J"
    vkrow4 "K",           SGCAPS, "k",      "K",      WCH_DEAD, WCH_DEAD
    vkrow4 "K",           0,      "л",      "Л",      "k",      "K"
    vkrow4 "L",           SGCAPS, "l",      "L",      WCH_DEAD, WCH_DEAD
    vkrow4 "L",           0,      "д",      "Д",      "l",      "L"
    vkrow4 VK_SEMICOLON,  SGCAPS, ";",      ":",      "°",      "¶"
    vkrow4 -1,            0,      "ж",      "Ж",      WCH_NONE, WCH_NONE
    vkrow4 VK_APOSTROPHE, SGCAPS, "'",      '"',      "'",      "́" ; combining acute
    vkrow4 -1,            0,      "э",      'Э',      WCH_NONE, WCH_NONE
    vkrow4 "Z",           SGCAPS, "z",      "Z",      WCH_DEAD, WCH_DEAD
    vkrow4 "Z",           0,      "я",      "Я",      "z",      "Z"
    vkrow4 "X",           SGCAPS, "x",      "X",      WCH_DEAD, WCH_DEAD
    vkrow4 "X",           0,      "ч",      "Ч",      "x",      "X"
    vkrow4 "C",           SGCAPS, "c",      "C",      WCH_DEAD, WCH_DEAD
    vkrow4 "C",           0,      "с",      "С",      "c",      "C"
    vkrow4 "V",           SGCAPS, "v",      "V",      WCH_DEAD, WCH_DEAD
    vkrow4 "V",           0,      "м",      "М",      "v",      "V"
    vkrow4 "B",           SGCAPS, "b",      "B",      WCH_DEAD, WCH_DEAD
    vkrow4 "B",           0,      "и",      "И",      "b",      "B"
    vkrow4 "N",           SGCAPS, "n",      "N",      WCH_DEAD, WCH_DEAD
    vkrow4 "N",           0,      "т",      "Т",      "n",      "N"
    vkrow4 "M",           SGCAPS, "m",      "M",      WCH_DEAD, WCH_DEAD
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
    dp vk2wchar1, 0401h
    dp vk2wchar2, 0602h
    dp vk2wchar4, 0A04h
    dp vk2wchar5, 0C05h
    dp 0, 0

palign

e1scancode2vk:
    dw 1Dh, VK_PAUSE
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
    du 0FFh, VK_ESCAPE, "1234567890", VK_MINUS, VK_EQUALS, VK_BACK
    du VK_TAB, "QWERTYUIOP", VK_LBRACKET, VK_RBRACKET, VK_RETURN
    du VK_LCONTROL, "ASDFGHJKL", VK_SEMICOLON, VK_APOSTROPHE, VK_GRAVE
    du VK_LSHIFT, VK_BACKSLASH, "ZXCVBNM", VK_COMMA, VK_PERIOD, VK_SLASH
    du KBDEXT+VK_RSHIFT, KBDMULTIVK+VK_MULTIPLY
    du VK_LMENU, " ", VK_CAPITAL
    du VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10
    du KBDEXT+KBDMULTIVK+VK_NUMLOCK, KBDMULTIVK+VK_SCROLL
    du KBDSPECIAL+KBDNUMPAD+VK_HOME, KBDSPECIAL+KBDNUMPAD+VK_UP, KBDSPECIAL+KBDNUMPAD+VK_PGUP, VK_SUBTRACT
    du KBDSPECIAL+KBDNUMPAD+VK_LEFT, KBDSPECIAL+KBDNUMPAD+VK_CLEAR, KBDSPECIAL+KBDNUMPAD+VK_RIGHT, VK_ADD
    du KBDSPECIAL+KBDNUMPAD+VK_END, KBDSPECIAL+KBDNUMPAD+VK_DOWN, KBDSPECIAL+KBDNUMPAD+VK_PGDN
    du KBDSPECIAL+KBDNUMPAD+VK_INSERT, KBDSPECIAL+KBDNUMPAD+VK_DELETE
    du VK_SNAPSHOT, 0FFh, VK_OEM_102, VK_F11, VK_F12, VK_CLEAR, VK_OEM_WSCTRL
    du VK_OEM_FINISH, VK_OEM_JUMP, VK_EREOF, VK_OEM_BACKTAB, VK_OEM_AUTO
    du 0FFh, 0FFh, VK_ZOOM, VK_HELP, VK_F13, VK_F14, VK_F15, VK_F16, VK_F17
    du VK_F18, VK_F19, VK_F20, VK_F21, VK_F22, VK_F23
    du VK_OEM_PA3, 0FFh, VK_OEM_RESET, 0FFh, VK_ABNT_C1, 0FFh, 0FFh, VK_F24
    du 0FFh, 0FFh, 0FFh, 0FFh, VK_OEM_PA1, VK_TAB, 0FFh, VK_ABNT_C2
.size = $ - .

palign

deadkeys:
    du "'AÁ", 0, "'aá", 0
    du "'ÆǼ", 0, "'æǽ", 0
    du "'CĆ", 0, "'cć", 0
    du "'EÉ", 0, "'eé", 0
    du "'GǴ", 0, "'gǵ", 0
    du "'IÍ", 0, "'ií", 0
    du "'KḰ", 0, "'kḱ", 0
    du "'LĹ", 0, "'lĺ", 0
    du "'MḾ", 0, "'mḿ", 0
    du "'NŃ", 0, "'nń", 0
    du "'OÓ", 0, "'oó", 0
    du "'ØǾ", 0, "'øǿ", 0
    du "'PṔ", 0, "'pṕ", 0
    du "'RŔ", 0, "'rŕ", 0
    du "'SŚ", 0, "'sś", 0
    du "'UÚ", 0, "'uú", 0
    du "'WẂ", 0, "'wẃ", 0
    du "'YÝ", 0, "'yý", 0
    du "'ZŹ", 0, "'zź", 0
    du '"OŐ', 0, '"oő', 0
    du '"UŰ', 0, '"uű', 0
    du "oAÅ", 0, "oaå", 0
    du "oUŮ", 0, "ouů", 0
    du ".AȦ", 0, ".aȧ", 0
    du ".BḂ", 0, ".bḃ", 0
    du ".CĊ", 0, ".cċ", 0
    du ".DḊ", 0, ".dḋ", 0
    du ".EĖ", 0, ".eė", 0
    du ".FḞ", 0, ".fḟ", 0
    du ".GĠ", 0, ".gġ", 0
    du ".HḢ", 0, ".hḣ", 0
    du ".Iİ", 0, ".iı", 0
    du ".MṀ", 0, ".mṁ", 0
    du ".NṄ", 0, ".nṅ", 0
    du ".OȮ", 0, ".oȯ", 0
    du ".PṖ", 0, ".pṗ", 0
    du ".RṘ", 0, ".rṙ", 0
    du ".SṠ", 0, ".sṡ", 0
    du ".TṪ", 0, ".tṫ", 0
    du ".WẆ", 0, ".wẇ", 0
    du ".XẊ", 0, ".xẋ", 0
    du ".YẎ", 0, ".yẏ", 0
    du ".ZŻ", 0, ".zż", 0
    du ':AÄ', 0, ':aä', 0
    du ':EË', 0, ':eë', 0
    du ':HḦ', 0, ':hḧ', 0
    du ':IÏ', 0, ':iï', 0
    du ':OÖ', 0, ':oö', 0
    du ':UÜ', 0, ':uü', 0
    du ':WẄ', 0, ':wẅ', 0
    du ':XẌ', 0, ':xẍ', 0
    du ':YŸ', 0, ':yÿ', 0
    du "^AÂ", 0, "^aâ", 0
    du "^CĈ", 0, "^cĉ", 0
    du "^EÊ", 0, "^eê", 0
    du "^GĜ", 0, "^gĝ", 0
    du "^HĤ", 0, "^hĥ", 0
    du "^IÎ", 0, "^iî", 0
    du "^JĴ", 0, "^jĵ", 0
    du "^OÔ", 0, "^oô", 0
    du "^SŜ", 0, "^sŝ", 0
    du "^UÛ", 0, "^uû", 0
    du "^WŴ", 0, "^wŵ", 0
    du "^YŶ", 0, "^yŷ", 0
    du "^ZẐ", 0, "^zẑ", 0
    du "vAǍ", 0, "vaǎ", 0
    du "vCČ", 0, "vcč", 0
    du "vDĎ", 0, "vdď", 0
    du "vEĚ", 0, "veě", 0
    du "vGǦ", 0, "vgǧ", 0
    du "vHȞ", 0, "vhȟ", 0
    du "vIǏ", 0, "viǐ", 0
    du "vKǨ", 0, "vkǩ", 0
    du "vLĽ", 0, "vlľ", 0
    du "vNŇ", 0, "vnň", 0
    du "vOǑ", 0, "voǒ", 0
    du "vRŘ", 0, "vrř", 0
    du "vSŠ", 0, "vsš", 0
    du "vTŤ", 0, "vtť", 0
    du "vUǓ", 0, "vuǔ", 0
    du "vZŽ", 0, "vzž", 0
    du "uAĂ", 0, "uaă", 0
    du "uEĔ", 0, "ueĕ", 0
    du "uGĞ", 0, "ugğ", 0
    du "uIĬ", 0, "uiĭ", 0
    du "uOŎ", 0, "uoŏ", 0
    du "uUŬ", 0, "uuŭ", 0
    du "`AÀ", 0, "`aà", 0
    du "`EÈ", 0, "`eè", 0
    du "`IÌ", 0, "`iì", 0
    du "`NǸ", 0, "`nǹ", 0
    du "`OÒ", 0, "`oò", 0
    du "`UÙ", 0, "`uù", 0
    du "`WẀ", 0, "`wẁ", 0
    du "`YỲ", 0, "`yỳ", 0
    du "~AÃ", 0, "~aã", 0
    du "~EẼ", 0, "~eẽ", 0
    du "~IĨ", 0, "~iĩ", 0
    du "~NÑ", 0, "~nñ", 0
    du "~OÕ", 0, "~oõ", 0
    du "~UŨ", 0, "~uũ", 0
    du "~VṼ", 0, "~vṽ", 0
    du "~YỸ", 0, "~yỹ", 0
; ogonek:  ˛ Ąą    Ęę    Įį      Ǫǫ      Ųų
; cedilla: ¸   ÇçḐḑ  ĢģḨḩ  ĶķĻļŅņ  ŖŗŞşŢţ
    du ",AĄ", 0, ",aą", 0
    du ",CÇ", 0, ",cç", 0
    du ",DḐ", 0, ",dḑ", 0
    du ",EĘ", 0, ",eę", 0
    du ",GĢ", 0, ",gģ", 0
    du ",HḨ", 0, ",hḩ", 0
    du ",IĮ", 0, ",iį", 0
    du ",KĶ", 0, ",kķ", 0
    du ",LĻ", 0, ",lļ", 0
    du ",NŅ", 0, ",nņ", 0
    du ",OǪ", 0, ",oǫ", 0
    du ",RŖ", 0, ",rŗ", 0
    du ",SŞ", 0, ",sş", 0
    du ",TŢ", 0, ",tţ", 0
    du ",UŲ", 0, ",uų", 0
    du "/AȺ", 0, "/aⱥ", 0
    du "/BɃ", 0, "/bƀ", 0
    du "/CȻ", 0, "/cȼ", 0
    du "/DĐ", 0, "/dđ", 0
    du "/EɆ", 0, "/eɇ", 0
    du "/FꞘ", 0, "/fꞙ", 0
    du "/GǤ", 0, "/gǥ", 0
    du "/HĦ", 0, "/hħ", 0
    du "/IƗ", 0, "/iɨ", 0
    du "/JɈ", 0, "/jɉ", 0
    du "/KꝀ", 0, "/kꝁ", 0
    du "/LŁ", 0, "/lł", 0
    du "/OØ", 1, "/oø", 1, " ØØ", 0, " øø", 0
    du "/PⱣ", 0, "/pᵽ", 0
    du "/RɌ", 0, "/rɍ", 0
    du "/TŦ", 0, "/tŧ", 0
    du "/YɎ", 0, "/yɏ", 0
    du "/ZƵ", 0, "/zƶ", 0
    du "mAĀ", 0, "maā", 0
    du "mÆǢ", 0, "mæǣ", 0
    du "mEĒ", 0, "meē", 0
    du "mGḠ", 0, "mgḡ", 0
    du "mIĪ", 0, "miī", 0
    du "mYȲ", 0, "myȳ", 0
    du "eAÆ", 1, "eaæ", 1, "EAÆ", 1, " ÆÆ", 0, " ææ", 0
    du "eOŒ", 0, "eoœ", 0, "EOŒ", 0
    du "oc©", 0
    du "or®", 0
    du "mt™", 0
    du "hTÞ", 0, "htþ", 0, "HTÞ", 0
    du "sSẞ", 0, "ssß", 0, "SSẞ", 0
    du "tEÐ", 0, "teð", 0, "TEÐ", 0
    du "umµ", 0
    du "mOΩ", 0, "moω", 0, "MOΩ", 0
    du "op£", 0
    du "ec¢", 0
    du "ey¥", 0
    du "ee€", 0
    du "ur₽", 0
    du "ifﬁ", 0
    du "ffﬀ", 0
    du "lfﬂ", 0
    du "ni∫", 0
    du "ufƒ", 0
    du "oo•", 0
    du "es§", 0
	du "ap¶", 0
    du "ipπ", 0
	du "qs√", 0
    du "hs", 0ADh, 0 ; soft hyphen
    du "lr", 202Eh, 0 ; right-to-left override
    du "rl", 202Dh, 0 ; left-to-right override
    du "sh☭", 0
	du "ks☠", 0
	du "ar☢", 0
	du "ib☣", 0
	du "ep☮", 0
	du "iy☯", 0
	du "ns❄", 0
    du "aw⚠", 0
    du "eh♥", 0
	du "ts★", 0
    du "mm¯", 0
    du "0oಠ", 0

    du "`q̀", 0 ; combining grave
    du "'q́", 0 ; combining acute
    du "эq́", 0 ; combining acute (RU layout)
    du "^q̂", 0 ; combining circumflex
    du "~q̃", 0 ; combining tilde
    du "mq̄", 0 ; combining macron
    du "uq̆", 0 ; combining breve
    du ".q̇", 0 ; combining dot above
    du ":q̈", 0 ; combining diaeresis
    du "oq̊", 0 ; combining ring
    du '"q̋', 0 ; combining double acute
    du "vq̌", 0 ; combining caron
    du ",q̧", 0 ; combining cedilla
    du "-q̶", 0 ; combining long stroke overlay
    du "/q̸", 0 ; combining solidus

    du "2f½", 0
    du "3f⅓", 0
    du "4f¼", 0
    du "5f⅕", 0
    du "6f⅙", 0
    du "7f⅐", 0
    du "8f⅛", 0
    du "9f⅑", 0
    du "0f⅒", 0

    du "fb█", 0, "Fb▓", 0, "FB▓", 0
    du "gb░", 0, "Gb▒", 0, "GB▒", 0
    du "hb▀", 0, "Hb▌", 0, "HB▌", 0
    du "jb▄", 0, "Jb▐", 0, "JB▐", 0
    du "vb↓", 0
	du "*b✱", 0

    du "bb", 20BFh, 0 ; Bitcoin sign

    dw 4 dup 0

palign

data export
export "kbdusru_undead.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
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
    'CompanyName','by Grom PE',\
    'FileDescription','US+RU+Extra Customized Keyboard Layout',\
    'FileVersion','1.0',\
    'InternalName','kbdusru_undead',\
    'LegalCopyright','Public domain. No rights reserved.',\
    'OriginalFilename','kbdusru_undead.dll',\
    'ProductName','kbdasm',\
    'ProductVersion','1.0'

section '.reloc' data readable discardable fixups
