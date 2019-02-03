="utf8"
; kbdasm by Grom PE. Public domain.
; kbdunieng — Universal English Layout

include "detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 0x0000000180000000 on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 0x80000000 on "nul" as "dll" ; Build for 32-bit Windows or WOW64
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

ligatures: .:
    dw VK_SEMICOLON
    dw 0x0000
    du 0x003D, 0x003E, WCH_NONE
ligature_size = $ - .

palign

ligatureMaxChars = (ligature_size - 4) / 2
if ligatureMaxChars > 4
  err "4 characters is max for a ligature on Windows XP or if you use Firefox"
end if
ligatureEntry = ligature_size

KbdTables:
    dp modifiers
    dp vk2wchar
    dp deadkeys         ; Dead keys
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
    dp ligatures
    dd 0x00000000       ; Type
    dd 0x00000000       ; Subtype (may contain OEM id)

palign

vk2bits:
    db VK_SHIFT,    KBDSHIFT
    db VK_CONTROL,  KBDCTRL
    db VK_MENU,     KBDALT
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

vk2wchar1_1:
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
    vkrow4 "Q"          , CAPLOK                        , "q" , "Q" , DEAD, DEAD
    vkrow4 "W"          , CAPLOK                        , "w" , "W" , NONE, NONE
    vkrow4 "E"          , CAPLOK                        , "e" , "E" ,  "€", NONE
    vkrow4 "R"          , CAPLOK                        , "r" , "R" ,  "®", NONE
    vkrow4 "T"          , CAPLOK                        , "t" , "T" , NONE, NONE
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
    vkrow4 VK_SEMICOLON , 0                             , LGTR, NONE,  "«",  "←"
    vkrow4 VK_APOSTROPHE, 0                             , "~" , "≈" ,  "»",  "→"
    vkrow4 VK_BACKSLASH , 0                             , "/" , "|" ,  "\", NONE
    vkrow4 VK_OEM_102   , 0                             , "/" , "|" ,  "\", NONE
    vkrow4 "Z"          , CAPLOK                        , "z" , "Z" , NONE, NONE
    vkrow4 "X"          , CAPLOK                        , "x" , "X" ,  "×", NONE
    vkrow4 "C"          , CAPLOK                        , "c" , "C" ,  "¢", NONE
    vkrow4 "V"          , CAPLOK                        , "v" , "V" ,  "√", NONE
    vkrow4 "B"          , CAPLOK                        , "b" , "B" ,  "β", NONE
    vkrow4 "N"          , CAPLOK                        , "n" , "N" , NONE, NONE
    vkrow4 "M"          , CAPLOK                        , "m" , "M" , LGTR, LGTR
    vkrow4 VK_COMMA     , CAPLOK                        , "," , ";" ,  "<",  "≤"
    vkrow4 VK_PERIOD    , CAPLOK                        , "." , ":" ,  ">",  "≥"
    vkrow4 VK_SLASH     , 0                             , "&" , "&" ,  "&", "＆"
    vkrow4 VK_SPACE     , 0                             , " " , " " ,  " ",  " "
    vkrow4 VK_DECIMAL   , 0                             , "." , "," , NONE, NONE
    dw 0, 0, 4 dup 0

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
    dp vk2wchar1_1, 0x0401
    dp vk2wchar1_3, 0x0803
    dp vk2wchar2_4, 0x0A04
    dp vk2wchar4_2, 0x0602
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
    "FileVersion","1.1",\
    "InternalName","kbdunieng",\
    "LegalCopyright","License MIT",\
    "OriginalFilename","kbdunieng.dll",\
    "ProductName","universal_layout",\
    "ProductVersion","1.0"

section ".reloc" data readable discardable fixups
