'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:30pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\_MM.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\_MM.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
'on error resume next
dim MsgBoxTitle : MsgBoxTitle = "MAKEMSI BUILD MSI (05.144)"
dim oShell      : set oShell  = MkObject("WScript.Shell")
dim oFS         : set oFs     = MkObject("Scripting.FileSystemObject")
dim ScriptDir   : ScriptDir   = oFS.GetParentFoldername(wscript.ScriptFullName)
if  wscript.arguments.count <> 2 then
Error "Expected the name of an MM script and build mode to be supplied."
end if
dim Script : Script = wscript.arguments(0)
dim Mode   : Mode   = wscript.arguments(1)
if  not oFS.FileExists(Script) then
Error "The MM file """ & Script & """ does not exist!"
end if
dim Comspec
Comspec = GetEnv("COMSPEC")
if  Comspec = "" then
Error("The ""COMSPEC"" environment variable does not exist! Any windows operating system should have this...")
end if
if  not oFS.FileExists(Comspec) then
Error("The ""COMSPEC"" environment variable contained """ & Comspec & """ which does not appear to point to a valid windows command processor (please let me know if you get this error)!")
end if
if  left(Script, 2) = "\\" then
Error("The script """ & Script & """ is in a directory with a UNC formatted name." & vbCRLF & "Unfortunately Windows doesn't fully support UNC." & vbCRLF & vbCRLF & "You could use the ""subst"" or ""net use"" commands to create a drive letter to the directory containing it.")
end if
'--- Is this DOS or WINDOWS? ------------------------------------------------
dim MmDir, Cmd, CmdRc, MmCmd, MmDos
MmDir = GetEnv("MAKEMSI_DIR")
if  MmDir = "" then
Error("The environment variable ""MAKEMSI_DIR"" does not exist! Have you just installed MAKEMSI? If so try restarting windows.")
end if
MmCmd = MmDir & "MM.CMD"
MmBat = MmDir & "MM.BAT"
if  oFS.FileExists(MmCmd) then
IsDos = false
Cmd   = "title " & oFS.GetFileName(Script) & " - Build Mode """ & Mode & """"
Cmd   = Cmd & " & "
Cmd   = Cmd & "MM.CMD """ & oFS.GetFileName(Script) & """ " & Mode & " & pause"
CmdRc = oShell.run("%comspec% /c " & Cmd, 1, False)
else
if  oFS.FileExists(MmBat) then
dim BaseName : BaseName = oFS.GetBaseName(Script)
if  instr(BaseName, " ") <> 0 then
dim oFile : set oFile = oFS.GetFile(Script)
BaseName  = oFS.GetBaseName(oFile.ShortPath)
set oFile = Nothing
end if
Cmd   = "MM.BAT " & BaseName & " " & Mode & " PAUSE"
CmdRc = oShell.run("%comspec% /c " & Cmd, 1, False)
else
Error("I can't find """ & MmCmd & """ or """ & MmBat & """!")
end if
end if

function MkObject(ByVal AutomationClass)
on error resume next
set MkObject = CreateObject(AutomationClass)
if  err.number <> 0 then
Error "Failed loading the automation class """ & AutomationClass & """." & vbCRLF & "This is likely to be due to a Windows configuration problem of some type." & vbCRLF & vbCRLF & "Reason 0x" & hex(err.number) & " - " & err.description
end if
end function

sub Error(ByVal Text)
MsgBox Text, vbCritical, MsgBoxTitle
wscript.quit 888
end sub

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
