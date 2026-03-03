::-------------------------Set time-------------------------------
@echo off
:START
cd /d %~dp0
if exist time.bat call time.bat
if defined NUM (
set count=%NUM: =%
) else (
set count=0
)
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

:WaitWater
if exist D:\TEST_UI\log\TSThread4_Kiểm_tra_gợn_sóng_nước_LCD_LCD水波纹.OK goto PASS
goto CheckYB


::-------------------------Result------------------------------
:PASS
exit /b 0