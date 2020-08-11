'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:22pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\OrcaView.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\OrcaView.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
on error resume next
dim MsgBoxTitle : MsgBoxTitle = "OrcaView.VBS (05.211)"
dim oShell      : set oShell  = MkObject("WScript.Shell")
dim oFS         : set oFs     = MkObject("Scripting.FileSystemObject")
if  wscript.arguments.count = 0 then
error true, "Expected the full name of at least one MSI as parameter (MSI will be viewed in ORCA)"
end if
dim CmdKey      : CmdKey      = "HKCR\Msi.Package\shell\edit\command\"
dim OrcaCommand : OrcaCommand = oShell.RegRead(CmdKey)
if  err.number <> 0 then
dim OrcaEXE : OrcaEXE = GetEnv("ProgramFiles") & "\Orca\Orca.exe"
if  not oFS.FileExists(OrcaEXE) then
error true, "I'm sorry but we could not determine how to invoke ORCA." & vbCRLF & "The registry key """ & CmdKey & """ does not exist!"& vbCRLF & "We also tried to find """ & OrcaEXE & """!" & vbCRLF & vbCRLF & "Is it installed? Try repairing or reinstalling ORCA..."
end if
OrcaCommand = """" & OrcaEXE & """ ""%1"""
end if
for ParmI = 0 to wscript.arguments.count-1
ViewMsi wscript.arguments(ParmI)
next
set oShell = Nothing
set oFS    = Nothing
wscript.quit(0)


'=====================================================================
function MkObject(ByVal AutomationClass)
'=====================================================================
on error resume next
set MkObject = CreateObject(AutomationClass)
if  err.number <> 0 then
Error true, "Failed loading the automation class """ & AutomationClass & """." & vbCRLF & "This is likely to be due to a Windows configuration problem of some type." & vbCRLF & vbCRLF & "Reason 0x" & hex(err.number) & " - " & err.description
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
sub ViewMsi(ByVal MsiName)
'=====================================================================
if  not oFS.FileExists(MsiName) then
error false, "The file """ & MsiName & """ does not exist!"
exit sub
end if
dim Cmd, CmdRc
Cmd = "attrib +r """ & MsiName & """"
CmdRc = oShell.run("%comspec% /c " & Cmd, 0, True)
Cmd = Replace(OrcaCommand, "%1", MsiName)
CmdRc = oShell.run("%comspec% /c start /wait """" " & Cmd, 0, True)
Cmd = "attrib -r """ & MsiName & """"
CmdRc = oShell.run("%comspec% /c " & Cmd, 0, True)
end sub


'=====================================================================
sub Error(ByVal Fatal, ByVal Text)
'=====================================================================
dim Title : Title = MsgBoxTitle
if  CurrentMsi <> "" then
Title = Title & " - " & CurrentMsi
end if
MsgBox Text, vbCritical, Title
if   Fatal then
ExitRc 999
end if
end sub


'=====================================================================
sub ExitRc(ReturnCode)
'=====================================================================
on error resume next
wscript.quit ReturnCode
end sub
