'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 16.059
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Sunday, 28 Feb 2016 3:44:29pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\_Mangled.V
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\_Mangled.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
dim MsgBoxTitle : MsgBoxTitle = "GUID Mangler/Unmangler (04.020)"
Guid = ""
do
T =      "This utility will ""mangle"" an MSI GUID or reverse the operation." & vbCRLF & vbCRLF
T = T & "Please enter one of these two forms!"
Guid = InputBox(T, MsgBoxTitle, Guid)
if  Guid = "" then
exit do
end if
if  left(Guid, 1) = "{" then
if  len(Guid) <> 38 then
error("The MSI GUID """ & Guid & """ appears to be corrupt as it is not 38 characters long!")
else
Guid = GuidMangle(Guid)
end if
else
if  len(Guid) <> 32 then
error("The mangled GUID """ & Guid & """ appears to be corrupt as it is not 32 characters long!")
else
Guid = GuidMangleReverse(Guid)
end if
end if
loop

'=====================================================================
sub Error(ByVal Text)
'=====================================================================
MsgBox Text, vbCritical, "ERROR: " & MsgBoxTitle
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
