@echo off
:start
cd /d %~dp0
setlocal enabledelayedexpansion
if exist CheckDevice.csv del CheckDevice.csv
if not exist Device.log goto END

::------------------------By line Try Run---------------------------
find /i "ACL" D:\TEST_UI\LINE.DAT
if not "%errorlevel%"=="0" GOTO END
cd /d %~dp0

::-------------------------GET Touch-------------------------------
:CheckError
python CheckError.py --input Device.log --output CheckDevice1.csv --include-status Error --exclude-name "HID-compliant touch screen"
python CheckError.py --input Device.log --output CheckDevice2.csv --include-status Unknown --exclude-name "Microsoft Streaming Clock Proxy"
copy CheckDevice1.csv + CheckDevice2.csv CheckDevice.csv /y

::-------------------------Check-------------------------------
:Check
if not exist CheckDevice.csv goto end
find /i "Device name" CheckDevice.csv
if @%errorlevel%==@0 goto Fail

::-------------------------Result--------------------------------------
:PASS
ECHO OK>D:\log\YB_Check.OK
exit /b 0

:END
exit /b 0

:Fail
cd /d %~dp0
if not exist D:\log\UpDeviceYB.OK start /min UpNgLog.bat
ECHO OK>D:\log\UpDeviceYB.OK
exit /b 0

ShowJPG.exe DeviceYB.png
GOTO START