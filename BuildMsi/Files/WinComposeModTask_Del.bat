@echo off

rem This should allow to run WinCompose from the startup menu without triggering
rem the UAC window. Running with high privileges is necessary to inject keyboard
rem events into other high level processes, such as cmd.exe run as Administrator.

pushd %~dp0

%windir%\system32\schtasks.exe /delete /f /tn WinComposeMod

popd
