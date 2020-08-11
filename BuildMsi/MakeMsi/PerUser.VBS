'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 16.059
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Sunday, 28 Feb 2016 3:44:23pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\PerUser.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\PerUser.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+

Option Explicit
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim Msg : Msg = ""
dim oPerUser    : set oPerUser = CreateObject("Scripting.Dictionary")


on error resume next
dim b_oInstaller  : set b_oInstaller = CreateObject("WindowsInstaller.Installer")
dim b_oShell      : set b_oShell  = WScript.CreateObject("WScript.Shell")
dim b_oFS         : set b_oFS     = CreateObject("Scripting.FileSystemObject")
dim b_ScriptDir   : b_ScriptDir   = b_oFS.GetParentFoldername(wscript.ScriptFullName)
dim b_M           : b_M     = ""
const b_HKEY_CLASSES_ROOT   = &H80000000
const b_HKEY_CURRENT_USER   = &H80000001
const b_HKEY_LOCAL_MACHINE  = &H80000002
const b_HKEY_b_Users          = &H80000003
const b_ForReading          = 1
const b_SidSystemAccount    = "S-1-5-18"
dim b_OnComputer           : b_OnComputer              = "."
dim b_RegInstallerUserData : b_RegInstallerUserData    = "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData"
dim b_Sid2NameExe : b_Sid2NameExe = b_ScriptDir & "\SidToName.exe"
if  not b_oFS.FileExists(b_Sid2NameExe) then
b_Sid2NameExe = ""
end if
dim b_oRegistry : set b_oRegistry = GetObject("winmgmts://" & b_OnComputer & "/root/default:StdRegProv")
DieOnErr("Could not get Registry object (via winmgmts). Probably security permissions...")
PopulateDictionaryObject()
on error goto 0



sub PopulateDictionaryObject()
on error resume next
dim b_SidKeys, b_Rc
b_Rc = b_oRegistry.EnumKey(b_HKEY_LOCAL_MACHINE, b_RegInstallerUserData, b_SidKeys)
DieOnErr("Could not enumerate the registry key """ & b_RegInstallerUserData & """")
err.Clear
dim b_i
for b_i = lbound(b_SidKeys) to ubound(b_SidKeys)
dim b_Sid
b_Sid = b_SidKeys(b_i)
if  b_Sid <> b_SidSystemAccount then
LoadDictionaryForSpecificUser(b_Sid)
end if
next
end sub

sub LoadDictionaryForSpecificUser(ByVal b_Usersid)
on error resume next
dim b_UsersDetails    : b_UsersDetails    = GetUserDetailsFromSid(b_Usersid)
dim b_UsersProductKey : b_UsersProductKey = b_RegInstallerUserData & "\" & b_Usersid & "\Products"
dim b_ProductKeys, b_Rc
b_Rc = b_oRegistry.EnumKey(b_HKEY_LOCAL_MACHINE, b_UsersProductKey, b_ProductKeys)
DieOnErr("Could not enumerate the registry key """ & b_UsersProductKey & """")
err.Clear
dim b_i
for b_i = lbound(b_ProductKeys) to ubound(b_ProductKeys)
dim b_ProductGuid
b_ProductGuid = GuidMangleReverse(b_ProductKeys(b_i))
if  oPerUser.exists(b_ProductGuid) then
oPerUser.add b_ProductGuid, oPerUser(b_ProductGuid) & ", " & b_UsersDetails
else
oPerUser.add b_ProductGuid, b_UsersDetails
end if
next
end sub

function GetUserDetailsFromSid(ByVal b_Usersid)
on error resume next
GetUserDetailsFromSid = b_Usersid
if  b_Sid2NameExe <> "" then
dim b_TmpFile : b_TmpFile = b_oShell.ExpandEnvironmentStrings("%TEMP%") & "\Sid2Name.TMP"
if  b_oFS.FileExists(b_TmpFile) then
b_oFS.DeleteFile(b_TmpFile)
end if
dim Cmd : Cmd = """" & b_Sid2NameExe & """ """ & b_Usersid & """ > """ & b_TmpFile & """ 2>&1"
b_oShell.run "cmd.exe /c """ & Cmd & """", 0, true
if  b_oFS.FileExists(b_TmpFile) then
dim TmpStream, FileLine
set TmpStream = b_oFS.OpenTextFile(b_TmpFile, b_ForReading)
do  while TmpStream.AtEndOfStream <> true
'--- Read the line -------------------------------------------
FileLine = trim( TmpStream.ReadLine )
if   left(FileLine, 8) = "[User]: " then
GetUserDetailsFromSid = mid(FileLine, 9)
end if
loop
TmpStream.close
end if
end if
end function


'============================================================================
function b_ReverseBits(ByVal GuidStr)
' This function mangles an MSI formatted GUID as performed by Windows
' Installer which uses this process in an attempt to hide the information.
'============================================================================
dim Lengths, i, Length, Fragment
b_ReverseBits = ""
Lengths       = split("8,4,4,2,2,2,2,2,2,2,2", ",")
for i = 0 to ubound(Lengths)
Length = Lengths(i)
Fragment = left(GuidStr, Length)
GuidStr  = mid(GuidStr,  Length+1)
b_ReverseBits = b_ReverseBits & StrReverse(Fragment)
next
end function

'============================================================================
function GuidMangle(ByVal MsiGuid)
' This function mangles an MSI formatted GUID as performed by Windows
' Installer which uses this process in an attempt to hide the information.
'============================================================================
dim Tmp
Tmp = replace(MsiGuid, "{", "")
Tmp = replace(Tmp,     "}", "")
Tmp = replace(Tmp,     "-", "")
GuidMangle = b_ReverseBits(Tmp)
end function

'============================================================================
function GuidMangleReverse(ByVal MangledGuid)
'============================================================================
dim Tmp : Tmp = b_ReverseBits(MangledGuid)
dim Lengths, i, Length, Fragment
GuidMangleReverse = ""
Lengths           = split("8,4,4,4,12", ",")
for i = 0 to ubound(Lengths)
Length = Lengths(i)
Fragment = left(Tmp, Length)
Tmp      = mid(Tmp,  Length+1)
if   i <> 0 then
GuidMangleReverse = GuidMangleReverse & "-"
end if
GuidMangleReverse = GuidMangleReverse & Fragment
next
GuidMangleReverse = "{" & GuidMangleReverse & "}"
end function
dim i, ProdKeys, ProdName, ProdVer, Users
if  oPerUser.count = 0 then
Msg = Msg & "No per-user installed products found!"
else
dim oInstaller  : set oInstaller = CreateObject("WindowsInstaller.Installer")
ProdKeys = oPerUser.keys
for i = 0 to oPerUser.count - 1
ProdName = oInstaller.ProductInfo(ProdKeys(i), "ProductName")
ProdVer  = oInstaller.ProductInfo(ProdKeys(i), "VersionString")
Users    = oPerUser(ProdKeys(i))
Msg = Msg & ProdName & vbCRLF
Msg = Msg & string(len(ProdName), "~") & vbCRLF
Msg = Msg & "Guid   : " & ProdKeys(i)  & vbCRLF
Msg = Msg & "Version: " & ProdVer      & vbCRLF
Msg = Msg & "User(s): " & Users        & vbCRLF
Msg = Msg & vbCRLF
next
end if
Quit(oPerUser.count)

sub DieOnErr(Doing)
if err.number <> 0 then
D = err.Description
R = "0x" & hex(err.number)
T = ""
if  D = "" then
D = "Windows bug #101,357,201 - no description for the error :-)"
end if
if  Doing <> "" then
T = T & Doing & vbCrLF & vbCrLF
end if
T = T & "The error code was " & R & vbCrLF & vbCrLF & D
Msg = Msg & T
Quit(999)
end if
end sub

Sub Quit(ExitRc)
if  Msg <> "" then
if ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
MsgBox Msg, vbInformation, "PerUser.VBS vesion 04.026"
else
wscript.echo Msg
end if
end if
wscript.quit ExitRc
end sub


'============================================================================
function a_ReverseBits(ByVal GuidStr)
' This function mangles an MSI formatted GUID as performed by Windows
' Installer which uses this process in an attempt to hide the information.
'============================================================================
dim Lengths, i, Length, Fragment
a_ReverseBits = ""
Lengths       = split("8,4,4,2,2,2,2,2,2,2,2", ",")
for i = 0 to ubound(Lengths)
Length = Lengths(i)
Fragment = left(GuidStr, Length)
GuidStr  = mid(GuidStr,  Length+1)
a_ReverseBits = a_ReverseBits & StrReverse(Fragment)
next
end function

'============================================================================
function GuidMangle(ByVal MsiGuid)
' This function mangles an MSI formatted GUID as performed by Windows
' Installer which uses this process in an attempt to hide the information.
'============================================================================
dim Tmp
Tmp = replace(MsiGuid, "{", "")
Tmp = replace(Tmp,     "}", "")
Tmp = replace(Tmp,     "-", "")
GuidMangle = a_ReverseBits(Tmp)
end function

'============================================================================
function GuidMangleReverse(ByVal MangledGuid)
'============================================================================
dim Tmp : Tmp = a_ReverseBits(MangledGuid)
dim Lengths, i, Length, Fragment
GuidMangleReverse = ""
Lengths           = split("8,4,4,4,12", ",")
for i = 0 to ubound(Lengths)
Length = Lengths(i)
Fragment = left(Tmp, Length)
Tmp      = mid(Tmp,  Length+1)
if   i <> 0 then
GuidMangleReverse = GuidMangleReverse & "-"
end if
GuidMangleReverse = GuidMangleReverse & Fragment
next
GuidMangleReverse = "{" & GuidMangleReverse & "}"
end function
