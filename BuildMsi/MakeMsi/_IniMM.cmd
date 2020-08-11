@echo off
@REM ***
@REM *** Called via Explorer context menu option for ".ini" files
@REM ***

@rem $Header:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/_IniMM.cmd.pvcs   1.1   02 Aug 2005 17:20:44   USER "Dennis"  $
SetLocal
set IniFile=%*


del "%IniFile%.INIMM" >nul 2>&1
"%MAKEMSI_DIR%reg4mm.exe" "%MAKEMSI_DIR%PpWiz4MM.4MM" '%MAKEMSI_DIR%IniMM.P' '/output:%IniFile%.INIMM' '/Define:INIFILE=%IniFile%' /DeleteOnError:N /Sleep:2,4
if errorlevel 1 goto Error
   start notepad "%IniFile%.INIMM"
   goto EndBatch
:ERROR
   echo.
   echo Will now display the import INI file in notepad....
   echo.
   start notepad "%IniFile%"
   pause
:ENDBATCH
