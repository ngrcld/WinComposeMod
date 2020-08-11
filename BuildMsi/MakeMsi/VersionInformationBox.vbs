'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:19pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\VersionInformationBox.v
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\VersionInformationBox.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
on error resume next
set oInstaller = CreateObject("WindowsInstaller.Installer")
if err.number <> 0 then
Title = "Is Windows Installer Installed?"
T     = "We had an error loading the Windows Installer object, it may not be installed." & vbCRLF & vbCRLF
T = T & "The error code was 0x" & hex(Err.number) & " (" & err.number & ") - " & err.description
MsgBox T, vbCritical, Title
wscript.quit 1000+36
end if
const PGM_VERSION = "06.153"
const ForReading = 1
dim oShell : set oShell = CreateObject("Wscript.Shell")
on error resume next
dim WinVer      : WinVer = ""
dim Base        : Base = "HKLM\Software\Microsoft\Windows NT\CurrentVersion\"
dim ProductName : ProductName = oShell.RegRead(Base & "ProductName")
if  Err.Number <> 0 then
WinVer = "?"
else
dim CurrentVersion     : CurrentVersion     = oShell.RegRead(Base & "CurrentVersion")
dim CurrentBuildNumber : CurrentBuildNumber = oShell.RegRead(Base & "CurrentBuildNumber")
dim CSDVersion         : CSDVersion         = oShell.RegRead(Base & "CSDVersion")
WinVer = ProductName & " (" & CurrentVersion & "." & CurrentBuildNumber & " " & CSDVersion & ")"
end if
err.clear()
dim WshVersion : WshVersion = wscript.version
if  err.number <> 0 then WshVersion = "?:" & err.description
dim MmVer : MmVer = GetMakemsiVersion()
dim Msg
Msg =       "This computer has Windows Installer " & oInstaller.Version
Msg = Msg & " and WSH "  & WshVersion & " on " & WinVer
Msg = Msg & vbCRLF & vbCRLF
Msg = Msg & "MAKEMSI is at version " & MmVer
dim Line : Line = "MAKEMSI Version " & MmVer & " & Windows Installer " & oInstaller.Version & " & WSH " & WshVersion & " on " & WinVer
if  ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "W" Then
Response = InputBox(Msg, "Version Information Box v" & PGM_VERSION, Line)
else
wscript.echo vbCRLF & Msg
end if
wscript.quit 9876

function GetMakemsiVersion()
on error resume next
dim VerFile : VerFile = GetEnv("MAKEMSI_DIR")
if  VerFile = "" then
GetMakemsiVersion = "?:The environment variable ""MAKEMSI_DIR"" is missing!"
exit function
end if
VerFile = VerFile & "MmVersion.mmh"
dim oFS : set oFS = CreateObject("Scripting.FileSystemObject")
if  not oFS.FileExists(VerFile) then
GetMakemsiVersion = "?:The file """ & VerFile & """ is missing!"
exit function
end if
dim ReadStream : set ReadStream = oFS.OpenTextFile(VerFile, ForReading)
dim Contents   : Contents       = ReadStream.readall()
ReadStream.Close()
if  err.number <> 0 then
GetMakemsiVersion = "?:Error reading """ & VerFile & """:" & err.description
exit function
end if
dim oRE : set oRE = New RegExp
if  err.number <> 0 then
GetMakemsiVersion = "?:VBSCRIPT registration problem with regular expresssions:" & err.description
exit function
end if
oRE.IgnoreCase = True   ' Set case insensitivity.
oRE.Global     = True   ' Set global applicability.
oRE.MultiLine  = True
oRE.Pattern    = "#define\+[ \t]+[^ \t]+[ \t]+([^\s]+)"
if  err.number <> 0 then
GetMakemsiVersion = "?:VBSCRIPT problem with regular expresssion object:" & err.description
exit function
end if
dim oMatches, oMatch
set oMatches = oRE.Execute(Contents)
GetMakemsiVersion = "?Could not locate the version number!"
for each oMatch in oMatches
GetMakemsiVersion = oMatch.SubMatches(0)
next
end function

function GetEnv(EnvVar)
on error resume next
dim Try : Try = "%" & EnvVar & "%"
GetEnv = oShell.ExpandEnvironmentStrings(Try)
on error goto 0
if  GetEnv = Try then
GetEnv = ""
end if
end function
