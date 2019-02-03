#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#InstallKeybdHook

F1::
Send {RWin down}
Send {Left}
Send {RWin up}
return
F2::
Send {RWin down}
Send {Right}
Send {RWin up}
return
F3::Media_Prev
F4::Media_Next
F5::Media_Play_Pause
F6::Volume_Mute
F7::Volume_Down
F8::Volume_Up
F9::Rwin
F10::#Tab
F12::#a

AppsKey & F1::F1
AppsKey & F2::F2
AppsKey & F3::F3
AppsKey & F4::F4
AppsKey & F5::F5
AppsKey & F6::F6
AppsKey & F7::F7
AppsKey & F8::F8
AppsKey & F9::F9
AppsKey & F10::F10
AppsKey & F11::F11
AppsKey & F12::F12