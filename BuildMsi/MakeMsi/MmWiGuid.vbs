'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+
' Generator   : PPWIZARD version 15.106
'             : FREE tool for Windows, OS/2, DOS and UNIX by Dennis Bareis (dbareis@gmail.com)
'             : http://dennisbareis.com/ppwizard.htm
' Time        : Wednesday, 22 Apr 2015 7:34:20pm
' Input File  : D:\DBAREIS\Projects\Win32\MakeMsi\MmWiGuid.v
' Output File : D:\DBAREIS\Projects\Win32\MakeMsi\out\MmWiGuid.VBS
'*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+



'************************************************************************
'*** Simple tool (C)opyright Dennis Bareis 2003. All rights reserved. ***
'************************************************************************
if Wscript.Arguments.Count = 1 then if Wscript.Arguments(0) = "!CheckSyntax!" then wscript.quit(21924)
LastGuid = ""
do
set oGuidGen = CreateObject("Scriptlet.Typelib")
NewGuid = oGuidGen.Guid
set oGuidGen = Nothing
NewGuid = ucase(left(NewGuid, 38))
if  NewGuid = LastGuid then     'Windows bug?
exit do
else
LastGuid = NewGuid
end if
if  ucase(mid(wscript.FullName, len(wscript.Path) + 2, 1)) = "C" and wscript.Arguments.Count <> 0 then
wscript.echo "GUID=""" & NewGuid & """"
exit do
else
Response = InputBox("The new GUID follows..." & vbCRLF & vbCRLF & "Cut and paste into your code:", "NEW GUID (Windows Installer formatted)", NewGuid)
if  Response = "" then
exit do
end if
end if
loop
