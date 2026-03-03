::-------------------------Set Env-------------------------------
@echo off
:START
set count=0
cd /d %~dp0
if exist time.bat del time.bat
if exist Device.log del Device.log
ping 127.0.0.1 -n 1

::--------------------------test-------------------------------
:CheckYB
cd /d %~dp0
ping 127.0.0.1 -n 2
DeviceStatus.exe /FAIL >>Device.log

:Retry
set /a count=count+1
echo %count%
echo SET NUM=%count% >time.bat

:WaitIO
ECHO Wait IO test......
tasklist|Find /I "IoAutoTest.exe" & if not errorlevel 1 goto WaitIO
goto CheckYB

::-------------------------Result------------------------------
:PASS
exit /b 0