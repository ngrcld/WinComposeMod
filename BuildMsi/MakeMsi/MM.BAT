@echo off
@REM *** PVCS: $Header:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/MM9X.BAT.pvcs   1.7   07 May 2005 09:10:08   USER "Dennis"  $
cls
md out > nul
cls

@REM *** May be useful for diagnosis ****************************************
echo *******************  > out\EnvInfo.TXT
echo *** ENVIRONMENT *** >> out\EnvInfo.TXT
echo ******************* >> out\EnvInfo.TXT
set >> out\EnvInfo.TXT


@REM *** Now Run the job *****************************************************
reg4mm.exe PPWIZ4MM.4MM %1.mm /ConsoleFile:out\%1.CON @MM9X /Define:MmMode=%2 %MAKEMSI_MM%

@REM *** PAUSE? **************************************************************
if "%3" == "PAUSE" pause
