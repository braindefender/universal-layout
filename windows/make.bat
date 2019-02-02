@echo off
set include=%~pd0fasm\include
set arch=x86
if exist "%programfiles(x86)%" set arch=AMD64
if "%1"=="" goto:make
"%~pd0fasm\fasm.exe" %*
goto:eof
:make
"%~pd0fasm\fasm.exe" kbdusru.asm
"%~pd0fasm\fasm.exe" kbdusru_undead.asm
"%~pd0fasm\fasm.exe" reg_layout.asm
goto:eof
