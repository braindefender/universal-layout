@echo off
if not "%cd%"\=="%~pd0" cd /d "%~pd0"
set target=%1
set dest=%~nx1

if "%target%"=="" (
  set target=kbdunirus.dll
  set dest=kbdunirus.dll
  set lid=00d0
  set id=07430419
  set shortname="Uni RU"
  set longname="Univesal Layout Russian"
) else (
  set id=07430409
  if not "%2"=="" set id=%2
  set lid=00d1
  if not "%3"=="" set lid=%3
  set shortname="Uni EN"
  if not "%~4"=="" set shortname=%4
  set longname="Univesal Layout English"
  if not "%~5"=="" set longname=%5
)
if not exist %target% goto:notexist
if exist %windir%\system32\%dest% goto:alreadyexist
if exist %windir%\sysnative\cmd.exe goto:relaunch64
call checkdll %target%
if errorlevel 1 goto:eof
net file >nul 2>&1
if not %errorlevel%==0 goto:notadmin
echo Checking keyboard layout IDs, please wait...
call checklid %lid%
if errorlevel 1 goto:eof
set /p answer="Do you want to install %target% in your system? [Y/N] "
if "%answer%"=="" goto:no
if /I "%answer:~0,1%"=="y" goto:yes
:no
echo Cancelled.
goto:eof
:yes
copy %target% %windir%\system32\%dest% >nul 2>&1
if errorlevel 1 goto:cannotcopy
for /f %%i in ('ver ^| %windir%\system32\find "Version 5"') do set nt5=yes
if not exist %windir%\system32\reg.exe goto:manualreg
set key="HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%id%"
reg add %key% /f >nul 2>&1
if errorlevel 1 goto:cannotreg
reg add %key% /f /v "Layout Text" /t REG_SZ /d %shortname% >nul 2>&1
reg add %key% /f /v "Layout Display Name" /t REG_SZ /d %longname% >nul 2>&1
reg add %key% /f /v "Layout File" /t REG_SZ /d "%dest%" >nul 2>&1
reg add %key% /f /v "Layout Id" /t REG_SZ /d %lid% >nul 2>&1
if errorlevel 1 goto:cannotreg
if not x%nt5%==xyes reg_layout r 0x%id:~4,4%:0x%id%
if errorlevel 1 goto:cannotreg2
echo The job is done. Now you should have additional layout called %longname%
goto:eof
:manualreg
echo REGEDIT4>>_install.reg
echo.>>_install.reg
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%id%]>>_install.reg
echo "Layout Text"=%shortname%>>_install.reg
echo "Layout Display Name"=%longname%>>_install.reg
echo "Layout File"="%dest%">>_install.reg
echo "Layout Id"="%lid%">>_install.reg
_install.reg
if errorlevel 1 goto:cannotreg
if not x%nt5%==xyes reg_layout r 0x%id:~4,4%:0x%id%
if errorlevel 1 goto:cannotreg2
echo The job is done. Now you should have additional layout called %longname%
goto:eof
:notexist
echo There is no %target% here, compile it first!
goto:eof
:alreadyexist
echo %target% is already installed in the system!
goto:eof
:cannotcopy
echo Error: unable to copy file to system directory.
goto:eof
:cannotreg
echo Error: unable to register the layout (registry).
goto:eof
:cannotreg2
echo Warning: unable to register the layout (input.dll). Do it manually.
control
goto:eof
:notadmin
echo To install, you must run this command with administrative privilegies.
cscript /nologo /e:javascript elevate.js "%~df0" %* >nul
goto:eof
:relaunch64
%windir%\sysnative\cmd.exe /c "%~df0" %*
goto:eof
