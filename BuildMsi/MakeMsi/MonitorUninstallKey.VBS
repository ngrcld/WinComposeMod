'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:28pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MonitorUninstallKey.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MonitorUninstallKey.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2004. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim oBefore  : set oBefore = CreateObject("Scripting.Dictionary") : DieOnErr("Could not create a dictionary object!")
dim DiffCnt  : DiffCnt     = 0
dim TotalCnt : TotalCnt    = 0
const HKEY_LOCAL_MACHINE  = &H80000002
const RegUninstallBase    = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
const OnComputer          = "."
ScanUninstallRegistry(true)
MsgBox "BEFORE STATE (of uninstall registry keys) captured." & vbCRLF & vbCRLF & "Start install and press OK on this dialog when it completes!", vbInformation, "MonitorUninstallKey.VBS (ver 07.214)!"
ScanUninstallRegistry(false)
if DiffCnt = 0 then
MsgBox TotalCnt & " registry entries found but no new ones detected!" & vbCRLF & vbCRLF & "Did you actually install a new product? Did it appear in the add-remove applet?", vbCritical, "OOPS - NO NEW UNINSTALL KEYS FOUND!"
end if
wscript.quit 666

sub ScanUninstallRegistry(Before)
set oRegistry = GetObject("winmgmts://" & OnComputer & "/root/default:StdRegProv")
DieOnErr("Could not get Registry object (via winmgmts). Probably security permissions...")
dim UiSubKeys(), T, Title
Rc = oRegistry.EnumKey(HKEY_LOCAL_MACHINE, RegUninstallBase, UiSubKeys)
DieOnErr("Could not enumerate the registry key """ & RegUninstallBase & """")
for i = lbound(UiSubKeys) to ubound(UiSubKeys)
UiSubKey = UiSubKeys(i)
if  Before then
oBefore.add UiSubKey, ""
else
if not oBefore.exists(UiSubKey) then
DiffCnt = DiffCnt + 1
Title= "FOUND: " & UiSubKey
err.clear()
dim DisplayName : Rc = oRegistry.GetStringValue(HKEY_LOCAL_MACHINE, RegUninstallBase & "\" & UiSubKey, "DisplayName", DisplayName)
if   Rc <> 0 or err.number <> 0 then DisplayName = "?"
err.clear()
dim DisplayVersion : Rc = oRegistry.GetStringValue(HKEY_LOCAL_MACHINE, RegUninstallBase & "\" & UiSubKey, "DisplayVersion", DisplayVersion)
if   Rc <> 0 or err.number <> 0 then DisplayVersion = "?"
err.clear()
dim WindowsInstaller : Rc = oRegistry.GetDWordValue(HKEY_LOCAL_MACHINE, RegUninstallBase & "\" & UiSubKey, "WindowsInstaller", WindowsInstaller)
if  Rc <> 0 or err.number <> 0 or WindowsInstaller = "0" then
WindowsInstaller = vbCRLF & vbCRLF & "This product is not Windows Installer based."
else
WindowsInstaller = vbCRLF & vbCRLF & "This product is Windows Installer based."
end if
T =     "Found new key!" & vbCRLF & vbCRLF
T = T & "This is for version " & DisplayVersion & " of """ & DisplayName & """." & WindowsInstaller & vbCRLF
Response = InputBox(T, Title, UiSubKey)
end if
end if
next
set oRegistry = Nothing
TotalCnt = ubound(UiSubKeys) - lbound(UiSubKeys) + 1
end sub

sub DieOnErr(Doing)
if err.number <> 0 then
D = err.Description
R = hex(err.number)
T = ""
if  D = "" then
D = "Windows bug #101,357,201 - no description for the error"
end if
if  Doing <> "" then
T = T & Doing & vbCrLF & vbCrLF
end if
T = T & "The error code was " & R & vbCrLF & vbCrLF & D
CscriptSay T
MsgBox T, vbCritical, "DUMPSOFT.VBS FAILED"
wscript.quit 999
end if
end sub
