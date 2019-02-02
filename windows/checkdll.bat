@echo off
setlocal enabledelayedexpansion
if not "%cd%"\=="%~pd0" cd /d "%~pd0"
set target=%1
if not "%target%"=="" goto:skipdefault
set target=kbdusru_undead.dll
:skipdefault
if not exist %target% goto:notexist
set d=################################
echo %d%%d%%d%%d%%d%%d%%d%%d%>__dummy__.txt
for /f "tokens=3" %%i in ('fc /b __dummy__.txt %target% ^| %windir%\system32\find "003C:"') do set pe=%%i
for /f "tokens=3" %%i in ('fc /b __dummy__.txt %target% ^| %windir%\system32\find "00%pe%:"') do set sig=%%i
if not %sig%==50 goto:notvalid
set /a h=0x%pe%+4
call:tohex %h%
for /f "tokens=3" %%i in ('fc /b __dummy__.txt %target% ^| %windir%\system32\find "00%hex%:"') do set arch=%%i
if exist "%programfiles(x86)%" goto:amd64
:x86
if not %arch%==4C goto:badarch_need_x86
goto:cleanup
:amd64
if not %arch%==64 goto:badarch_need_amd64
:cleanup
del __dummy__.txt
exit /b 0
:tohex
set lookup=0123456789ABCDEF
set hex=
set /a a=%1
:tohex_loop
set /a b=!a! %% 16
set /a a=!a! / 16
set hex=!lookup:~%b%,1!%hex%
if %a% gtr 0 goto:tohex_loop
goto:eof
:badarch_need_x86
echo %target% is 64-bit, but your Windows is 32-bit^^!
echo Modify its source and recompile.
del __dummy__.txt
exit /b 1
:badarch_need_amd64
echo %target% is 32-bit, but your Windows is 64-bit^^!
echo Modify its source and recompile.
del __dummy__.txt
exit /b 1
:notvalid
echo %target% is not a valid PE file^^!
del __dummy__.txt
exit /b 1
:notexist
echo There is no %target% here, compile it first^^!
exit /b 1
