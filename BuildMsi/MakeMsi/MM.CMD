@echo off
setlocal ENABLEEXTENSIONS
set SayFile=
@REM *** PVCS: $Header:   D:/DBAREIS/Projects.PVCS/Win32/MakeMsi/MM.cmd.pvcs   1.48   09 Jun 2018 11:11:10   USER "Dennis"  $
@REM ************************************
@REM ******** RC = 0 means OK ***********
@REM ************************************
echo.


::--- What version is this script? ------------------------------------------
set MmCmdVer=2018.06.09a


@REM *** Windows is one big bug bag so I need to know the version ***********
@rem *** Get version: Example:  Microsoft Windows [Version 6.1.7601] ********
set WinVersion=0.?
set WinMajorVersion=
for /F "tokens=2 delims=[" %%v in ('ver') do set WinVersion=%%v
for /F "tokens=2 delims=] " %%v in ("%WinVersion%") do set WinVersion=%%v
for /F "tokens=1,2,3* delims=." %%a in ("%WinVersion%") do set WinMajorVersion=%%a&set VerMin=%%b& set VerRest=%%c
set    RootWorks=N
set VistaOnwards=N
    if "%WinMajorVersion%" == "5" set RootWorks=Y
    if /I %WinMajorVersion% GEQ 6 set VistaOnwards=Y

::--- Display the version + environmental info ------------------------------
call :AreWeAlreadyElevated
call :DisplayVersion "           "


@REM *** Initialization *****************************************************
set OrigCmdLine=%0 %*
set MMQ=!%1
set MMQ=%MMQ:"=%
set MMQ=%MMQ:~1%
if not "%MMQ:~0,1%" == "?" goto NormalOperation
   @rem *** Handy command line "shortcuts" **********************************
   @echo MAKEMSI INSTALLED  : %MAKEMSI_DIR%
   if not "%MAKEMSI_SAMPLES%" == "" @echo YOUR Samples Dir : %MAKEMSI_SAMPLES%

   @rem *** Now do what user wants ******************************************
   set MMQ=%MMQ:~1%
   set MMDIR=%MAKEMSI_DIR%
   if /I "%MMQ%" == "" set MMDIR=%MAKEMSI_DIR%Samples\TryMe
   if /I "%MMQ%" == "S" if not "%MAKEMSI_SAMPLES%" == "" set MMDIR=%MAKEMSI_SAMPLES%
   echo OPENING(RootMode=%RootWorks%): %MMDIR%
   echo.
   rem start "" "%MMDIR%"
   rem *** Bug in handling of "/root" command! Seems many symptoms, I've seen opening in wrong dir: http://www.vistax64.com/vista-general/92571-bug-explorer-root.html
   if     "%RootWorks%" == "Y" set CMD=start explorer.exe /e,/root,%MAKEMSI_DIR%,%MMDIR%
   if not "%RootWorks%" == "Y" set CMD=start explorer.exe /e,%MMDIR%
   %cmd%
   goto :EOF
:NormalOperation
cls
call :DisplayVersion
if not exist "out\." md out > nul 2>&1


::---------------------------------------------------------------------------
::--- Make sure we have write access ----------------------------------------
::---------------------------------------------------------------------------
call :SAY "TESTING : Write access to this directory...."
     set TestFilePrefix=.\#TestingAccessToThisLocation
     set TestAccessFile=%TestFilePrefix%[R=%RANDOM%]#.txt
     echo [%DATE% %TIME%] This file can be safely deleted if its somehow left over :-) > "%TestAccessFile%"
     if exist "%TestAccessFile%" goto HaveRequiredPermissions
        :NO_WRITE_ACCESS
        TITLE ### YOU DON'T HAVE WRITE ACCESS ###
        call :SAYBL & call :SAYBL
        call :SAY "ERROR: YOU DON'T HAVE WRITE PERMISSIONS!"
        call :SAY "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        call :SAY "You don't have write access to this location, you have these main options:"
        call :SAYBL
        call :SAY "1. Copy the file to somewhere where you can access the files:"
        call :SAY "   (a) This is the simplest option!
        call :SAY "2. Get the required permissions:
        call :SAY "   (a) You may have access if you use an *ELEVATED* Windows command prompt.
        call :SAY "   (b) You (or your company's support department) may be able to give you the
        call :SAY "       required access, that is, modify the directory's security via the
        call :SAY "       Access Control Lists (ACL) for:
        call :SAY "       '%CD%'
        call :SAYBL
        if "%VistaOnwards%" == "N" goto DontTryElevating
           ::--- Are we already elevated? -----------------------------------
           if "%ELEVATED%" == "Y"  call :SAY "### WE ARE ALREADY ELEVATED ###" & goto DontTryElevating

           ::--- Ask user if we want to elevate -----------------------------
           choice.exe /M "TRY ELEVATING YOUR PERMISSIONS (Y/N)" /T 120 /D Y /C YN /N
           if errorlevel 2 exit 666 & goto DIE_NO_PERMISSIONS
              ::--- OK lets try ---------------------------------------------
              call :SAY "Attempting to elevate your privleges...
              call :Elevate
              call :SAYBL & call :SAYBL
              call :SAY "A new elevated window has opened, this window will now close...
              call :SAYBL & call :SAYBL
              exit 999
              goto DIE_NO_PERMISSIONS
        :DontTryElevating
            pause
        :DIE_NO_PERMISSIONS
        set SetRcCmd=cmd.exe /c ThisCmdWillFailGeneratingANonZeroReturnCode!.ABC
        set MmStatus=FAILED-NO_WRITE_PERMISSIONS
        goto ENDBATCH_NO_ACCESS
     :HaveRequiredPermissions
     call :SAY "          You do have permissions to this directory...
     del "%TestFilePrefix%[R=*.txt" >nul 2>&1


::---------------------------------------------------------------------------
::--- Make sure MAKEMSI is installed ----------------------------------------
::---------------------------------------------------------------------------
call :SAY "TESTING : That makemsi is installed....
     if defined MAKEMSI_DIR goto LooksLikeMakeMsiIsInstalled
        call :SAYBL & call :SAYBL
        call :SAY "ERROR: MAKEMSI IS NOT INSTALLED ('MAKEMSI_DIR' environment variable missing)
        call :SAY "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        call :SAY "Since you are executing the MAKEMSI 'MM.CMD' batch file, it seems likely that
        call :SAY "these are the main possibilities:
        echo.
        call :SAY "1. You haven't rebooted since installing MAKEMSI
        call :SAY "   (a) This is normally only required the first time you install it
        call :SAY "   (b) Its best you reboot and try again.
        call :SAY "2. Windows may have lost the configuration, reinstall MAKEMSI:
        call :SAY "   (a) Sometimes windows loses registry.
        call :SAY "   (b) Perhaps you used a 'System Restore'?
        call :SAY "3. You are manually installing it and forgotten something...
        call :SAYBL
        pause
        set SetRcCmd=cmd.exe /c ThisCmdWillFailGeneratingANonZeroReturnCode!.ABC
        set MmStatus=FAILED-NO_WRITE_PERMISSIONS
        goto ENDBATCH
     :LooksLikeMakeMsiIsInstalled
     call :SAY "          MAKEMSI installed at '%MAKEMSI_DIR%'


@REM *** Get parameters (if .MM not named see if ONLY 1) ********************
echo.
set MmName=%~n1
set MmMode=%2
@REM ***
@REM *** MAKEMSI_MM_PRIORITY
@REM *** ~~~~~~~~~~~~~~~~~~~
@REM *** This environment variable can be used to run MAKEMSI faster or
@REM *** slower than normal. This should contain the text of any priority
@REM *** switch which is valid on the Windows "START" command, for example
@REM *** "BELOWNORMAL" or the less likely "LOW". You would lower the priority
@REM *** where you know MAKEMSI will take a while and you still want your
@REM *** computer to respond quickly to your "other" tasks.
@REM ***
@REM *** MAKEMSI_MM
@REM *** ~~~~~~~~~~
@REM *** The contents of this environment variable is added to the end of
@REM *** the PPWIZARD command line so can override most of the previously
@REM *** mentioned switches as well as allowing you to add others.
@REM *** If you need to modify this batch file then tell me why!
@REM ***
@REM *** MAKEMSI_USER_FILES_PATH
@REM *** ~~~~~~~~~~~~~~~~~~~~~~~
@REM *** The contents of these environment variables are added to the
@REM *** list of directories PPWIZARD/MAKEMSI will search for files (header etc).
@REM *** See the PPWIZARD "/IncludePath" doco for more information.
@REM ***


::--- Change Buffer size, unless told not too -------------------------------
set BuffSize=%MAKEMSI_MM_CONBUFFSIZE%
if     "%BuffSize%" == ""   set BuffSize=32000
if not "%BuffSize%" == "-"  ConSetBuffer.exe /H=%BuffSize%


@Rem *** What modes are supported ([D]evelopment and [P]roduction by default) ***
set MmModeList=%MAKEMSI_MMMODES%
if "%MmModeList%" == "" set MmModeList=DdPp


::--- If no parameters at all then start looking! ---------------------------
if "%MmName%" == ""  goto LookForMm0p


::--- Was MM name omitted so only mode passed? ------------------------------
set MmModeListT=%MmModeList%
:TryNext
   set FC=%MmModeListT:~0,1%
   set MmModeListT=%MmModeListT:~1%
   if "%MmName%" == "%FC%" goto LookForMm1p
   if not "%MmModeListT%" == "" goto TryNext
goto HaveMmName
:LookForMm1p
   set MmMode=%MmName%
:LookForMm0p
   echo @echo off >                  out\MsiTmp.cmd
                                     if not exist "out\MsiTmp.cmd" echo Failed creating "out\MsiTmp.cmd"...& goto NO_WRITE_ACCESS
   echo set NumFiles=%%NumFiles%%#>> out\MsiTmp.cmd
   echo set   MmName=%%~n1>>         out\MsiTmp.cmd
   set MmName=
   set NumFiles=
   for %%f in (*.mm) do call out\MsiTmp.cmd "%%f"
   @rem echo T.MmName   = "%MmName%"
   @rem echo T.MmMode   = "%MmMode%"
   @rem echo T.NumFiles = "%NumFiles%"
   if not "%NumFiles%" == "#" goto ERR_NOPARM
:HaveMmName
del out\MsiTmp.cmd >nul 2>&1
if "%MmName%" == "" goto ERR_NOPARM
if not exist "%MmName%.mm" goto ERR_WHERE


::--- The first mode is the default -----------------------------------------
if  "%MMMODE%" == "" set MMMODE=%MmModeList:~0,1%


::---------------------------------------------------------------------------
::--- Work Out where the output LOG/MSI etc goes ----------------------------
::--- LOOKING FOR MAKEMSI_MM_ROOTDIR.D & MAKEMSI_MM_ROOTDIR.P ---------------
::---------------------------------------------------------------------------
set CanVerifyEf=N
     set RootDir=
echo set RootDir=%%MAKEMSI_MM_ROOTDIR.%MMMODE%%%> "out\MsiTmp.cmd"
                                     if not exist "out\MsiTmp.cmd" echo Failed creating "out\MsiTmp.cmd"...& goto NO_WRITE_ACCESS
                                             call "out\MsiTmp.cmd"
                                              del "out\MsiTmp.cmd" >nul 2>&1
if not "%RootDir%" == "" goto FndRootDirEnvVars
    ::--- Remove SQUARE BRACKETS (make safe for info zip) -------------------
    set MmNameNSB=%MmName%
    set MmNameNSB=%MmNameNSB:[=(%
    set MmNameNSB=%MmNameNSB:]=)%

    ::--- Root dir is defaulting --------------------------------------------
    set     RootDir=out\%MmNameNSB%.mm
    set CanVerifyEf=Y
:FndRootDirEnvVars
set CanVerifyEf=Y&REM *** 2018-06-09: Can't remember why this variable was required (seems it shouldn't be) ***


::--- DBG FILE --------------------------------------------------------------
set DEBUGFILE=out\%MmName%.DBG.TXT
              if "%ELEVATED%" == "Y" set DEBUGFILE=out\%MmName%.[ELEVATED].DBG.TXT
set MaxDbg=%MAKEMSI_DBG_MAX_BACKUP_NUMBER%
           if  not defined MaxDbg set MaxDbg=9
call :BACKUP_CONSOLE_OUTPUT
del "%DEBUGFILE%" >nul 2>&1 &rem Shouldn't need this (play safe)
set MaxDbg=


::--- May be useful for diagnosis -------------------------------------------
set       ShouldBeEmptyFile=%RootDir%\-IgnoreMeUnlessNotEmpty-.txt
set ShouldBeEmptyReportFile=%RootDir%\[ERROR REPORT, NOT EMPTY!]-IgnoreMeUnlessNotEmpty-.txt
del "%ShouldBeEmptyFile%"       >nul 2>&1
del "%ShouldBeEmptyReportFile%" >nul 2>&1
if "%MAKEMSI_MM_SUPPORT_TEXT%" == "" set MAKEMSI_MM_SUPPORT_TEXT=%MAKEMSI_DIR%MM_SUPPORT_TEXT.txt
if     exist "%MAKEMSI_MM_SUPPORT_TEXT%" type "%MAKEMSI_MM_SUPPORT_TEXT%"                                > "%DEBUGFILE%" 2>&1
if not exist "%MAKEMSI_MM_SUPPORT_TEXT%" echo INFO: The file "%MAKEMSI_MM_SUPPORT_TEXT%" doesn't exist!  > "%DEBUGFILE%" 2>&1
echo. >> "%DEBUGFILE%" 2>&1
echo. >> "%DEBUGFILE%" 2>&1
if  not defined SayFile   goto NoSayFile
if  not exist "%SayFile%" goto NoSayFile
    type "%SayFile%" >> "%DEBUGFILE%" 2>&1
    echo. >> "%DEBUGFILE%" 2>&1
    echo. >> "%DEBUGFILE%" 2>&1
:NoSayFile
set DbgCmd=cscript.exe //NoLogo "%MAKEMSI_DIR%VersionInformationBox.vbs"
    echo [%date% %time% - Diagnostic info cmd]: %DbgCmd% >> "%DEBUGFILE%" 2>&1
    %DbgCmd%                         >> "%DEBUGFILE%" 2>&1
    echo.                            >> "%DEBUGFILE%" 2>&1
    echo.                            >> "%DEBUGFILE%" 2>&1
set DbgCmd=set
    echo [%date% %time% - Diagnostic info cmd]: %DbgCmd% >> "%DEBUGFILE%" 2>&1
    %DbgCmd%                         >> "%DEBUGFILE%" 2>&1
    echo.                            >> "%DEBUGFILE%" 2>&1
    echo.                            >> "%DEBUGFILE%" 2>&1


::--- Work out the command line we will use ---------------------------------
SET MakeCmd=reg4mm.exe PPWIZ4MM.4MM '/ConsoleFile:+%DEBUGFILE%' /ErrorFile: /OTHER '%MmName%.mm'
set MakeCmd=%MakeCmd% /Define:MmMode=%MmMode%
set MakeCmd=%MakeCmd% /DeleteOnError:N
set MakeCmd=%MakeCmd% '/Output:%ShouldBeEmptyFile%'
set MakeCmd=%MakeCmd% /Sleep:0,0 '/BuildTitle:/OTHER/Building from {x22}{IS}{x22}'
set MakeCmd=%MakeCmd% /option:Tabs='4'
set MakeCmd=%MakeCmd% /IncludePath=*MAKEMSI_USER_FILES_PATH;*MAKEMSI_COMPANY_SUPPORT_DIR;
set MakeCmd=%MakeCmd% %MAKEMSI_MM%
if     "%MAKEMSI_MM_BEEPS%"    == "N" set MakeCmd=%MakeCmd% /Beep:N
if not "%MAKEMSI_MM_PRIORITY%" == ""  set MakeCmd=START /B /WAIT /%MAKEMSI_MM_PRIORITY% %MakeCmd%

REM *** Change Codepage (log to console Log) ********************************
if  "%MAKEMSI_MM_CODEPAGE%" == ""  set MAKEMSI_MM_CODEPAGE=1252
if  "%MAKEMSI_MM_CODEPAGE%" == "?" goto NoChCp
    set CodePageCmd=chcp %MAKEMSI_MM_CODEPAGE%
    echo [%date% %time% - CMD]: %CodePageCmd% >> "%DEBUGFILE%" 2>&1
    %CodePageCmd%     >> "%DEBUGFILE%" 2>&1
    echo.             >> "%DEBUGFILE%" 2>&1
:NoChCp

REM *** Output the PPWIZARD command line to the console log *****************
echo [%date% %time% - CMD]: %MakeCmd% >> "%DEBUGFILE%" 2>&1
echo.                 >> "%DEBUGFILE%" 2>&1

REM *** "REGINA_MACROS" must include MAKEMSI install dir (set by install, but lets make sure) ***
SET REGINA_MACROS=%MAKEMSI_DIR%;%REGINA_MACROS%

REM *** Want all MAKEMSI Temporary files created in a single directory *****
set REXSYSTM_TMP=%TEMP%\MAKEMSI.TMP
md "%REXSYSTM_TMP%" >nul 2>&1

REM *** Now Run the job *****************************************************
%MakeCmd%
if errorlevel 1 goto ENDBATCH_ERROR
goto ENDBATCH_OK



REM *** Error Handling ******************************************************
:ERR_NOPARM
   @echo.
   @echo ERROR: NO PARAMETER SUPPLIED
   goto SHOW_WI
:ERR_WHERE
   @echo.
   @echo ERROR: Can't find "%MmName%.mm"
   goto SHOW_WI
:SHOW_WI
   @echo.
   @echo AVAILABLE SCRIPTS
   @echo ~~~~~~~~~~~~~~~~~
   dir *.mm /on /b
   set DEBUGFILE=nul
   goto ENDBATCH_ERROR_BEEP
:ENDBATCH_ERROR_BEEP
   if not "%MAKEMSI_MM_BEEPS%" == "N" @echo 
:ENDBATCH_ERROR
   if not "%MAKEMSI_MM_BEEPS%" == "N" @echo 
   set SetRcCmd=cmd.exe /c ThisCmdWillFailGeneratingANonZeroReturnCode!.ABC
   set MmStatus=FAILED
   call :ShouldBeEmptyValidation
   goto ENDBATCH


Rem *** EXIT ****************************************************************
:ENDBATCH_OK
   @echo.
   set SetRcCmd=cmd.exe /c echo This command always works so set RC=0
   set MmStatus=OK
   call :ShouldBeEmptyValidation
   goto ENDBATCH


::===========================================================================
:ShouldBeEmptyValidation
::===========================================================================
    if  "%CanVerifyEf%" == "Y" goto WeKnowWhereTheFileIs
        echo We didn't check that the "empty file" was empty (don't know it's exact location, sorry), this could be improved... >> "%DEBUGFILE%" 2>&1
        goto :EOF
    :WeKnowWhereTheFileIs
        set VerVbs=%MAKEMSI_DIR%ShouldBeEmpty.vbs
        if  exist "%VerVbs%" goto FoundVerVbs
            echo We didn't check that the "empty file" was empty ("%VerVbs%" wasn't found) >> "%DEBUGFILE%" 2>&1
            goto :EOF
        :FoundVerVbs
            echo. >> "%ShouldBeEmptyFile%"& rem VBSCRIPT CAN'T HANDLE 0 LENGTH STDIN
            type     "%ShouldBeEmptyFile%" | cscript.exe //NoLogo "%VerVbs%" > "%ShouldBeEmptyReportFile%"
            set EmptyRc=%ERRORLEVEL%
            if "%EmptyRc%" == "219" del "%ShouldBeEmptyReportFile%"& goto :EOF

            ::--- The file is not empty -------------------------------------
            echo.& echo.
            type "%ShouldBeEmptyReportFile%"
            echo.
            set MmStatus=FAILED
            set SetRcCmd=cmd.exe /c ThisCmdWillFailGeneratingANonZeroReturnCode!.ABC
    goto :EOF


::===========================================================================
:BACKUP_CONSOLE_OUTPUT
::===========================================================================
    for %%X in ("%DEBUGFILE%") do set DbgExtn=%%~xX
    for %%X in ("%DEBUGFILE%") do set DbgBase=%%~nX%
    for /L %%i in (%MaxDbg%,-1,1) do call :BACKUP_CONSOLE_OUTPUT1 "%%i"
    goto :EOF

::===========================================================================
:BACKUP_CONSOLE_OUTPUT1
::===========================================================================
    set TI=%~1
    set /a FI=TI - 1
    if     "%FI%" == "0" set FITXT=
    if not "%FI%" == "0" set FITXT=_#%FI%
    set FFILE=%DbgBase%%FITXT%%DbgExtn%
    set TFILE=%DbgBase%_#%TI%%DbgExtn%

    del               "out\%TFILE%" >nul 2>&1
    ren "out\%FFILE%"     "%TFILE%" >nul 2>&1
    goto :EOF


::===========================================================================
:SAY
::===========================================================================
    echo %~1
    if  not defined SayFile goto :EOF
        echo %~1 >> "%SayFile%" 2>&1
        goto :EOF
::===========================================================================
:SAYBL
::===========================================================================
    echo.
    if  not defined SayFile goto :EOF
        echo. >> "%SayFile%" 2>&1
        goto :EOF


::===========================================================================
:DisplayVersion
::===========================================================================
    set SayFile=%TEMP%\MM.CMD.SayFile.tmp.txt
    del        "%TEMP%\MM.CMD.SayFile.tmp.txt"
    call :SAY "STARTING%~1: "MM.CMD" version %MmCmdVer%
    call :SAY "ENV     %~1: USER: "%USERDOMAIN%\%USERNAME%", WINDOWS: %WinVersion%
    call :SAY "        %~1  ELEVATED: %ELEVATED%
    goto :EOF

::===========================================================================
:AreWeAlreadyElevated
::===========================================================================
    set ELEVATED=Y
    FSUTIL.EXE dirty query %SystemDrive% >nul 2>&1
    if errorlevel 1 set ELEVATED=N
    goto :EOF



::===========================================================================
:Elevate
::===========================================================================
    ::--- Need a small vbscript (delete any previous ones, we want to keep last for debugging) ---
    set VbsPrefix=%TEMP%\MM.CMD[Elevate].
    del "%VbsPrefix%*" >nul 2>&1
    set Vbs=%VbsPrefix%%RANDOM%.vbs
        echo dim oShell        : set oShell       = CreateObject("WScript.Shell")           > "%Vbs%"
        echo dim oApplication  : set oApplication = CreateObject("Shell.Application")      >> "%Vbs%"
        echo dim Try    : Try    = "%%OrigCmdLine%%"                                       >> "%Vbs%"
        echo dim TheCmd : TheCmd = oShell.ExpandEnvironmentStrings(Try)                    >> "%Vbs%"
        echo     TheCmd = "title ### ELEVATED MSI BUILD ### &" ^& TheCmd                   >> "%Vbs%"
        echo     TheCmd = "cd /D ""%CD%"" &" ^& TheCmd                                     >> "%Vbs%"
        echo     TheCmd = TheCmd ^& " & echo. & pause"                                     >> "%Vbs%"
        echo if TheCmd = Try then                                                          >> "%Vbs%"
        echo    TheCmd = "/k cd /D ""%CD%"""                                               >> "%Vbs%"
        echo else                                                                          >> "%Vbs%"
        echo    TheCmd = "/c """ ^& TheCmd ^& """"                                         >> "%Vbs%"
        echo end if                                                                        >> "%Vbs%"
        echo wscript.echo ">> cmd.exe " ^& TheCmd                                          >> "%Vbs%"
        echo oApplication.ShellExecute "cmd.exe", TheCmd, "", "runas", 1                   >> "%Vbs%"
        echo set oApplication = Nothing                                                    >> "%Vbs%"
        echo set oShell       = Nothing                                                    >> "%Vbs%"

    ::--- Execute the elevation vbs ---------------------------------------------
    cscript.exe //NoLogo "%Vbs%"
    goto :EOF


::===========================================================================
:ENDBATCH
::===========================================================================
echo [%date% %time% - Diagnostic info STATUS]: %MmStatus% >> "%DEBUGFILE%" 2>&1
    :ENDBATCH_NO_ACCESS
        %SetRcCmd% >nul 2>&1
