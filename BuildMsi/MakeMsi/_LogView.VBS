'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:29pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\_LogView.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\_LogView.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim MsgBoxTitle : MsgBoxTitle = "Explorer MAKEMSI Log Viewer (03.334)"
dim oShell      : set oShell  = WScript.CreateObject("WScript.Shell")
dim oFS         : set oFs     = CreateObject("Scripting.FileSystemObject")
dim ScriptDir   : ScriptDir   = oFS.GetParentFoldername(wscript.ScriptFullName)
dim WiLogUtl
WiLogUtl = ScriptDir & "\WiLogUtl.EXE"
if  not oFS.FileExists(WiLogUtl) then
WiLogUtl = GetEnv("MAKEMSI_WILOGUTL_EXE")
if  WiLogUtl <> "" then
if  not oFS.FileExists(WiLogUtl) then
WiLogUtl = ""
end if
end if
if  WiLogUtl = "" then
Error "The MS SDK tool ""WiLogUtl.EXE"" is not in the MAKEMSI directory and was not found using the environment variable ""MAKEMSI_WILOGUTL_EXE""."
end if
end if
if  wscript.arguments.count <> 1 then
Error "Expected the full name of a verbose log to be viewed."
end if
dim MsiLog : MsiLog = wscript.arguments(0)
if  not oFS.FileExists(MsiLog) then
Error "Could not find the log file """ & MsiLog & """!"
end if
dim LogDirBase : LogDirBase = "Verbose.TMP"
if  oFS.FolderExists(LogDirBase) then
on error resume next
oFS.DeleteFolder(LogDirBase)
on error goto 0
end if
oFS.CreateFolder(LogDirBase)
dim oFolder  : set oFolder = oFS.GetFolder(LogDirBase)
dim oFile    : set oFile   = oFS.GetFile(MsiLog)
dim TmpDir83 : TmpDir83 = oFolder.ShortPath
dim MsiLog83 : MsiLog83 = oFile.ShortName
set oFolder = Nothing
set oFile   = Nothing
dim Cmd
Cmd = """" & WiLogUtl & """ /q /l " & MsiLog83 & " /o " & TmpDir83
CmdRc = oShell.run("%comspec% /c " & Cmd, 0, true)
if  CmdRc <> 0 then
Error "Received a non zero return code of " & CmdRc & " from the command:" & vbCRLF & vbCRLF & Cmd
else
Cmd = "start """" """ & TmpDir83 & "\DETAILS_" & MsiLog83 & ".htm"""
CmdRc = oShell.run("%comspec% /c " & Cmd, 0, true)
end if
wscript.quit 99

'=====================================================================
function CompareWithThisMsi(ByVal MsiToCompare, ByVal DefaultTemplate)
'=====================================================================
dim Title, T
Title = "Compare the database (""" & oFS.GetBaseName(MsiToCompare) & "." & oFS.GetExtensionName(MsiToCompare) & """) with what?"
on error resume next
set oMAKEMSI = CreateObject("MAKEMSI.Tools")
if  err.number <> 0 then
CompareWithThisMsi = InputBox(Title, Title, DefaultTemplate)
else
dim InitialDir : InitialDir = oFs.GetParentFolderName(MsiToCompare)
CompareWithThisMsi = oMAKEMSI.ChooseWindowsInstallerDatabaseFile(Title, InitialDir)
set oMAKEMSI = Nothing
end if
end function

'=====================================================================
function GetEnv(EnvVar)
'=====================================================================
on error goto 0
GetEnv = ""
dim Try : Try = "%" & EnvVar & "%"
on error resume next
GetEnv = oShell.ExpandEnvironmentStrings(Try)
on error goto 0
if  GetEnv = Try then
GetEnv = ""
end if
end function

'=====================================================================
sub Error(ByVal Text)
'=====================================================================
MsgBox Text, vbCritical, MsgBoxTitle
wscript.quit 888
end sub
