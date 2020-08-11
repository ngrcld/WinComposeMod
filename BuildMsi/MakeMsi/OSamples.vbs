'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:18pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\OSamples.v
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\OSAMPLES.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
public oShell : set oShell = CreateObject("Wscript.Shell")
public oFS    : set oFS    = CreateObject("Scripting.FileSystemObject")
CmdShell  = GetEnv("COMSPEC", true)
SampleDir = GetEnv("MAKEMSI_SAMPLES", false)
if SampleDir = "" then
T = "The samples environment variable ""MAKEMSI_SAMPLES"" was not found..."
T = T & vbCRLF & vbCRLF
T = T & "You should create this environment variable if you wish successful "
T = T & "code to be collected in a single (perhaps network) location. "
T = T & "The directory this variable points to will over time become populated with "
T = T & "quite a bit of code which you can use as samples for a new project (or perhaps you "
T = T & "know you have done something before but can't remember how to do it)!"
MsgBox T, vbCritical, """MAKEMSI_SAMPLES"" not found"
else
if not oFs.FolderExists(SampleDir) then
MsgBox "The samples directory """ & SampleDir & """ does not yet exist!", vbInformation, "NO SAMPLES AVAILABLE (YET)"
else
Cmd  = CmdShell & " /c start """" """ & SampleDir & """"
oShell.Run Cmd, 0
end if
end if

'=====================================================================
function GetEnv(EnvVar, DieIfMissing)
'=====================================================================
on error goto 0
GetEnv = ""
dim Try : Try = "%" & EnvVar & "%"
on error resume next
GetEnv = oShell.ExpandEnvironmentStrings(Try)
on error goto 0
if  GetEnv = Try then
GetEnv = ""
if  DieIfMissing then
on error goto 0
MsgBox "The environment variable """ & EnvVar & """ does not exist", vbCritical, "CAN'T FIND ENVIRONMENT VARIABLE"
wscript.quit 999
end if
end if
end function
