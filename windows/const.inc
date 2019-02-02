KBDSHIFT     = 001h
KBDCTRL      = 002h
KBDALT       = 004h
KBDKANA      = 008h ; Key found on Japanese keyboards, with Caps Lock-like toggle
KBDROYA      = 010h
KBDLOYA      = 020h
KBDGRPSELTAP = 080h
KBDEXT       = 100h
KBDMULTIVK   = 200h
KBDSPECIAL   = 400h
KBDNUMPAD    = 800h

KBD_VERSION = 1

KLLF_ALTGR     = 1 ; Use AltGr input method
KLLF_SHIFTLOCK = 2 ; Pressing Shift key turns off Caps Lock. But there is a system setting for that. ???
KLLF_LRM_RLM   = 4

CAPLOK      = 1 ; when Caps Lock is on, SHIFT column is taken
SGCAPS      = 2 ; when Caps Lock is on, the next row is taken
CAPLOKALTGR = 4 ; when Caps Lock is on, SHIFT column is taken
KANALOK     = 8 ; when Kana is on, KANA columns are taken
GRPSELTAP   = 80h

SHFT_INVALID = 0Fh

WCH_NONE = 0F000h ; Nothing happens on key press
WCH_DEAD = 0F001h ; Don't print the character and lookup at dead key table for the next character to combine with
WCH_LGTR = 0F002h ; Print the matching ligature instead; beep if not found

DKF_DEAD = 1 ; Do another dead key table lookup instead of printing the character

; These VKeys weren't defined in FASM\INCLUDE\EQUATES\USER*.INC

VK_KANA                = 015h
VK_JUNJA               = 017h
VK_FINAL               = 018h
VK_KANJI               = 019h
VK_CONVERT             = 01Ch
VK_NONCONVERT          = 01Dh
VK_ACCEPT              = 01Eh
VK_MODECHANGE          = 01Fh

VK_POWER               = 05Eh
VK_SLEEP               = 05Fh

VK_BROWSER_BACK        = 0A6h
VK_BROWSER_FORWARD     = 0A7h
VK_BROWSER_REFRESH     = 0A8h
VK_BROWSER_STOP        = 0A9h
VK_BROWSER_SEARCH      = 0AAh
VK_BROWSER_FAVORITES   = 0ABh
VK_BROWSER_HOME        = 0ACh
VK_VOLUME_MUTE         = 0ADh
VK_VOLUME_DOWN         = 0AEh
VK_VOLUME_UP           = 0AFh
VK_MEDIA_NEXT_TRACK    = 0B0h
VK_MEDIA_PREV_TRACK    = 0B1h
VK_MEDIA_STOP          = 0B2h
VK_MEDIA_PLAY_PAUSE    = 0B3h
VK_LAUNCH_MAIL         = 0B4h
VK_LAUNCH_MEDIA_SELECT = 0B5h
VK_LAUNCH_APP1         = 0B6h
VK_LAUNCH_APP2         = 0B7h

VK_SEMICOLON           = 0BAh
VK_EQUALS              = 0BBh
VK_COMMA               = 0BCh
VK_MINUS               = 0BDh
VK_PERIOD              = 0BEh
VK_SLASH               = 0BFh
VK_GRAVE               = 0C0h
VK_LBRACKET            = 0DBh
VK_BACKSLASH           = 0DCh
VK_RBRACKET            = 0DDh
VK_APOSTROPHE          = 0DEh
VK_BACKTICK            = 0DFh

VK_OEM_SCROLL          = 091h
VK_OEM_1               = 0BAh ; ";:" for US
VK_OEM_PLUS            = 0BBh ; "+" any country/region
VK_OEM_COMMA           = 0BCh ; "," any country/region
VK_OEM_MINUS           = 0BDh ; "-" any country/region
VK_OEM_PERIOD          = 0BEh ; "." any country/region
VK_OEM_2               = 0BFh ; "/?" for US
VK_OEM_3               = 0C0h ; "`~" for US
VK_ABNT_C1             = 0C1h
VK_ABNT_C2             = 0C2h
VK_OEM_4               = 0DBh ; "[{" for US
VK_OEM_5               = 0DCh ; "\|" for US
VK_OEM_6               = 0DDh ; "]}" for US
VK_OEM_7               = 0DEh ; "'"" for US
VK_OEM_8               = 0DFh
VK_OEM_AX              = 0E1h ; AX key on Japanese AX keyboard
VK_OEM_102             = 0E2h ; "<>" or "\|" on RT 102-key keyboard

VK_PROCESSKEY          = 0E5h

VK_OEM_RESET           = 0E9h
VK_OEM_JUMP            = 0EAh
VK_OEM_PA1             = 0EBh
VK_OEM_PA2             = 0ECh
VK_OEM_PA3             = 0EDh
VK_OEM_WSCTRL          = 0EEh
VK_OEM_CUSEL           = 0EFh
VK_OEM_ATTN            = 0F0h
VK_OEM_FINISH          = 0F1h
VK_OEM_COPY            = 0F2h
VK_OEM_AUTO            = 0F3h
VK_OEM_ENLW            = 0F4h
VK_OEM_BACKTAB         = 0F5h

; Taken from USER*.INC

VK_LBUTTON   = 001h
VK_CANCEL    = 003h
VK_RBUTTON   = 002h
VK_MBUTTON   = 004h
VK_BACK      = 008h
VK_TAB	     = 009h
VK_CLEAR     = 00Ch
VK_RETURN    = 00Dh
VK_SHIFT     = 010h
VK_CONTROL   = 011h
VK_MENU      = 012h
VK_PAUSE     = 013h
VK_CAPITAL   = 014h
VK_ESCAPE    = 01Bh
VK_SPACE     = 020h
VK_PRIOR     = 021h
VK_PGUP      = 021h
VK_PGDN      = 022h
VK_NEXT      = 022h
VK_END	     = 023h
VK_HOME      = 024h
VK_LEFT      = 025h
VK_UP	     = 026h
VK_RIGHT     = 027h
VK_DOWN      = 028h
VK_SELECT    = 029h
VK_PRINT     = 02Ah
VK_EXECUTE   = 02Bh
VK_SNAPSHOT  = 02Ch
VK_INSERT    = 02Dh
VK_DELETE    = 02Eh
VK_HELP      = 02Fh
VK_LWIN      = 05Bh
VK_RWIN      = 05Ch
VK_APPS      = 05Dh
VK_NUMPAD0   = 060h
VK_NUMPAD1   = 061h
VK_NUMPAD2   = 062h
VK_NUMPAD3   = 063h
VK_NUMPAD4   = 064h
VK_NUMPAD5   = 065h
VK_NUMPAD6   = 066h
VK_NUMPAD7   = 067h
VK_NUMPAD8   = 068h
VK_NUMPAD9   = 069h
VK_MULTIPLY  = 06Ah
VK_ADD	     = 06Bh
VK_SEPARATOR = 06Ch
VK_SUBTRACT  = 06Dh
VK_DECIMAL   = 06Eh
VK_DIVIDE    = 06Fh
VK_F1	     = 070h
VK_F2	     = 071h
VK_F3	     = 072h
VK_F4	     = 073h
VK_F5	     = 074h
VK_F6	     = 075h
VK_F7	     = 076h
VK_F8	     = 077h
VK_F9	     = 078h
VK_F10	     = 079h
VK_F11	     = 07Ah
VK_F12	     = 07Bh
VK_F13	     = 07Ch
VK_F14	     = 07Dh
VK_F15	     = 07Eh
VK_F16	     = 07Fh
VK_F17	     = 080h
VK_F18	     = 081h
VK_F19	     = 082h
VK_F20	     = 083h
VK_F21	     = 084h
VK_F22	     = 085h
VK_F23	     = 086h
VK_F24	     = 087h
VK_NUMLOCK   = 090h
VK_SCROLL    = 091h
VK_LSHIFT    = 0A0h
VK_RSHIFT    = 0A1h
VK_LCONTROL  = 0A2h
VK_RCONTROL  = 0A3h
VK_LMENU     = 0A4h
VK_RMENU     = 0A5h
VK_ATTN      = 0F6h
VK_CRSEL     = 0F7h
VK_EXSEL     = 0F8h
VK_EREOF     = 0F9h
VK_PLAY      = 0FAh
VK_ZOOM      = 0FBh
VK_NONAME    = 0FCh
VK_PA1	     = 0FDh
VK_OEM_CLEAR = 0FEh

; Taken from KERNEL*.INC

RT_VERSION	= 16
LANG_NEUTRAL		     = 00h
SUBLANG_NEUTRAL          = 00h shl 10
VOS_NT_WINDOWS32  = 00040004h
VFT_DLL        = 00000002h
VFT2_DRV_KEYBOARD	   = 00000002h
