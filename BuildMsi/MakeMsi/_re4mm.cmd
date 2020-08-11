@echo off
@REM ***
@REM *** Called via Explorer context menu option for ".reg" files
@REM ***

@rem $Header:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/_re4mm.cmd.pvcs   1.3   08 Feb 2005 19:45:38   USER "Dennis"  $
SetLocal
set Re4File=%*


del "%Re4File%.RE4MM" >nul 2>&1
"%MAKEMSI_DIR%reg4mm.exe" "%MAKEMSI_DIR%PpWiz4MM.4MM" '%MAKEMSI_DIR%RE4MM.P' '/output:%Re4File%.RE4MM' '/Define:RE4=%Re4File%' /DeleteOnError:N /Sleep:2,4
if errorlevel 1 goto Error
   start notepad "%Re4File%.RE4MM"
   goto EndBatch
:ERROR
   echo.
   echo Will now display the registry file in notepad....
   echo.
   start notepad "%Re4File%"
   pause
:ENDBATCH

