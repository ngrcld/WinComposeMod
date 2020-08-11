'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:17pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MmMD5.v
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MmMD5.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'*****************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003-2010. All rights reserved. ***
'*****************************************************************************
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
Title = "MD5"
if wscript.arguments.count = 0 then
T =     "Expected at least one filename!" & vbCRLF & vbCRLF
T = T & "Anti-Spyware bugs have been known to cause this (for example in the Microsoft beta), did you get prompted? "
T = T & "If you did and are permanently allowing this script to run then it will work next time!"
MsgBox T, vbCritical, Title
wscript.quit 1000+47
end if
set oFs = CreateObject("Scripting.FileSystemObject")
if err.number <> 0 then
Title = "Security issue?"
T     = "Could not load the File system object." & vbCRLF & vbCRLF
T = T & "The error code was 0x" & hex(Err.number) & " (" & err.number & ") - " & err.description
MsgBox T, vbCritical, Title
wscript.quit 1000+57
end if
for FileNumber = 0 to wscript.arguments.count-1
if  wscript.arguments.count = 1 then
MessagePrefix = ""
else
MessagePrefix = "File " & FileNumber+1 & " of " & wscript.arguments.count & "." & vbCRLF & vbCRLF
end if
DisplayMd5 wscript.arguments(FileNumber), MessagePrefix
next
wscript.quit 0
sub DisplayMd5(FileName, T)
if  not oFs.FileExists(FileName) then
T = T & "The file """ & FileName & """ does not exist!"
MsgBox T, vbCritical, Title
exit sub
end if
BaseName = oFS.GetFileName(FileName)
if  Left(oInstaller.Version, 2) = "1." then
T = T & "Windows Installer version " & oInstaller.Version & " can not generate MD5 checksums."
MsgBox T, vbCritical, Title
wscript.quit 1000+87
end if
err.clear()
set oMd5 = oInstaller.FileHash(FileName, 0)
if  err.number <> 0 then
Title = "Could not generate MD5 hash!"
T = T & "Failed generating an MD5 hash for the file """ & BaseName & """." & vbCRLF & vbCRLF
T = T & "The error code was 0x" & hex(Err.number) & " (" & err.number & ") - " & err.description
MsgBox T, vbCritical, Title
exit sub
end if
Md5Pretty = PrettyHash(oMd5)
set oFile = oFS.getfile(FileName)
Title = "MD5 for """ & BaseName & """ (MMMD5.VBS version 10.079)"
T = T & "The file """ & BaseName & """ is " & oFile.size & " bytes long, "
T = T & "dated " & FormatDateTime(oFile.DateLastModified, vbLongDate) & " at " & FormatDateTime(oFile.DateLastModified, vbLongTime) & "." & vbCRLF & vbCRLF & "It has an MD5 of:"
Response = InputBox(T, Title, Md5Pretty)
end sub

'=========================================================================
function PrettyHash(ByVal UglyHash)
'=========================================================================
PrettyHash = Hex8(UglyHash.IntegerData(1)) & "-" & Hex8(UglyHash.IntegerData(2)) & "-" & Hex8(UglyHash.IntegerData(3)) & "-" & Hex8(UglyHash.IntegerData(4))
end function

'=========================================================================
function Hex8(Value)
'=========================================================================
Hex8 = hex(Value)
Hex8 = right(string(8, "0") & Hex8, 8)
Hex8 = mid(Hex8,7,2) & mid(Hex8,5,2) & mid(Hex8,3,2) & mid(Hex8,1,2)
end function
