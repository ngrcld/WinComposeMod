@echo off
@rem $Header:   C:/DBAREIS/Projects.PVCS/Win32/MakeMsi/CmdPrompt.cmd.pvcs   1.3   15 Sep 2007 18:30:58   USER "Dennis"  $

@rem --- Display version of operating system ----------------------------------
cls
ver
set MmDefDir=%~d1%~p1
echo.
echo.

@rem --- Set a TITLE ----------------------------------------------------------
title CMDLINE: %MmDefDir%
echo Default Directory: %MmDefDir%
echo.

@rem --- Change to the directory (swap drives if required) --------------------
cd /d "%MmDefDir%"
if not errorlevel 1 goto ChangedOk
   pushd "%MmDefDir%"
   echo.
   echo =======================================================================
   echo ===               MAKEMSI UNC PATH HANDLER REQUIRED                 ===
   echo =======================================================================
   echo === You should type "exit" to quit and not simply close this window ===
   echo =======================================================================
   echo.
:ChangedOk
echo.
