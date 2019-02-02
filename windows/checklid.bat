@echo off
if "%1"=="" (
  echo Usage: checklid.bat ^<layout_id^> - check if your new Layout ID is unique
  exit /b 2
)
for /F "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"') do (
  for /F "tokens=4" %%j in ('reg query "%%i" /v "Layout Id" 2^>nul ^| %windir%\system32\find "Layout Id"') do (
    if /I %%j==%1 (
      echo Layout Id %1 already exists!
      exit /b 1
    )
  )
)
exit /b 0


