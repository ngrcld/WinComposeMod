@echo off
@REM ***
@REM *** Called via Explorer context menu option for ".idt" files
@REM ***

@rem $Header:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/_IDT2DEFN.cmd.pvcs   1.0   15 May 2004 17:17:50   USER "Dennis"  $

rem --- Parm 2 = single idt filename or directory ---------------------------
SetLocal
set IdtFile=%*
set OutputFile=%IdtFile%.MmTable

set PPWIZARD_CONSOLEFILE=
set PPWIZARD_ERRORFILE=
"%MAKEMSI_DIR%reg4mm.exe" "%MAKEMSI_DIR%PpWiz4MM.4MM" '%MAKEMSI_DIR%IDT2DEFN.P' '/output:%OutputFile%' '/Define:IDT=%IdtFile%' /DeleteOnError:N /Sleep:0,0
if errorlevel 1 goto Error
   start notepad "%OutputFile%"
   goto EndBatch
:ERROR
   start notepad "%IdtFile%"
   pause
:ENDBATCH

