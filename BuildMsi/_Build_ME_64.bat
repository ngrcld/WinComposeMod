@echo off

set project=ME_64.mm

SET "MAKEMSI_DIR=%~dp0MakeMsi\"

pushd "%~dp0"

path=%MAKEMSI_DIR%;%path%
cmd /c "%MAKEMSI_DIR%\mm.cmd %project%"
if %ERRORLEVEL% NEQ 0 pause
mkdir ..\msi
move .\out\%project%\MSI\* ..\msi\
rd /s /q out

popd
