::-------------------------Set Env-------------------------------------
@echo off
:start
cd /d %~dp0
call D:\SFCS\Info.bat
::-------------------------Test-------------------------------

if not exist Device.log goto PASS

:CheckNetWork
cd /d %~dp0
IF EXIST M:\NUL goto GetTime

:linkAP
CALL D:\FA_PRO\IOTEST\LINKIO\LinkIO.bat
ipconfig|find /i " Default Gateway . . . . . . . . . : 1"> IP.TXT
if errorlevel 1 goto linkAP
for /f "tokens=2 delims=:" %%a in (ip.txt) do echo %%a>ip.tmp
for /f "tokens=1 delims= " %%a in (ip.tmp) do set Server_IP=%%a
if @%Server_IP%==@ goto linkAP

net use /d * /y
echo Y |net use P: \\%server_IP%\PDLINE /user:pdline ndk800
if not exist P:\nul goto test
echo Y |net use M: \\%server_IP%\MESSAGE /user:pdline ndk800
if not exist M:\nul goto test



:GetTime
cd /d %~dp0
SET MODEL=%MODEL: =%
SAFETIME /g >CurrentTime.bat
call CurrentTime.bat

set "date1=%DATETIME:~0,4%"
set "date2=%DATETIME:~5,2%"
set "date3=%DATETIME:~8,2%"
set CurDate=%date1%%date2%%date3%

:uplog
ping 127.0.0.1 -n 1
IF NOT EXIST M:\DeviceYB\NUL mkdir M:\DeviceYB 
IF NOT EXIST M:\DeviceYB\%CurDate% mkdir M:\DeviceYB\%CurDate% 
IF NOT EXIST M:\DeviceYB\%CurDate%\%MODEL% mkdir M:\DeviceYB\%CurDate%\%MODEL%

copy Device.log M:\DeviceYB\%CurDate%\%MODEL%\%SVCTAG%_Device.log. /y


:PASS
exit